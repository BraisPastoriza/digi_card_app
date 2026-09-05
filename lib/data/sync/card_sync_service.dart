import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/models/card_release.dart';
import '../api/heroi_api.dart';
import '../db/app_database.dart';
import '../db/tables.dart';
import 'bulk_parser.dart';

/// Steps of a card database sync, in the order they run.
enum SyncStage {
  checking('Checking for card updates'),
  releases('Fetching expansions'),
  downloading('Downloading card data'),
  parsing('Reading cards'),
  storing('Saving cards'),
  indexing('Building search index'),
  complete('Up to date'),
  failed('Sync failed');

  const SyncStage(this.label);

  final String label;
}

class SyncProgress {
  const SyncProgress(this.stage, {this.fraction, this.detail, this.error});

  final SyncStage stage;

  /// 0..1 where the step can report it, null while indeterminate.
  final double? fraction;

  final String? detail;
  final Object? error;

  bool get isTerminal =>
      stage == SyncStage.complete || stage == SyncStage.failed;
}

/// Downloads the card database and writes it into local storage.
///
/// The API offers a single bulk dump per language, so a sync always replaces
/// the whole dataset rather than merging: at ~25 MB that is both simpler and
/// faster than reconciling 7,600 cards one by one.
class CardSyncService {
  CardSyncService(this._db, this._api);

  final AppDatabase _db;
  final HeroiApi _api;

  Future<SyncStateRow?> currentState() =>
      _db.select(_db.syncState).getSingleOrNull();

  /// Whether the app has cards to show. False on a fresh install.
  Future<bool> hasCards() async => await _db.cardDao.totalCardCount() > 0;

  /// Runs a sync, reporting progress as it goes. The returned stream always
  /// ends with either [SyncStage.complete] or [SyncStage.failed].
  Stream<SyncProgress> sync({bool force = false}) {
    final controller = StreamController<SyncProgress>();
    unawaited(
      _run(controller, force: force)
          .catchError((Object error, StackTrace stack) {
            controller.add(SyncProgress(SyncStage.failed, error: error));
          })
          .whenComplete(controller.close),
    );
    return controller.stream;
  }

  Future<void> _run(
    StreamController<SyncProgress> controller, {
    required bool force,
  }) async {
    controller.add(const SyncProgress(SyncStage.checking));

    final bulk = await _api.latestEnglishBulk();
    if (bulk == null) {
      throw StateError('The card API is not publishing an English card list.');
    }

    final state = await currentState();
    final upToDate =
        !force &&
        state != null &&
        state.bulkId == bulk.id &&
        state.cardCount > 0;
    if (upToDate) {
      controller.add(const SyncProgress(SyncStage.complete));
      return;
    }

    controller.add(const SyncProgress(SyncStage.releases, fraction: 0));
    final ids = await _api.releaseIds();
    final details = await _api.releaseDetails(
      ids,
      onProgress: (completed, total) => controller.add(
        SyncProgress(
          SyncStage.releases,
          fraction: total == 0 ? null : completed / total,
          detail: '$completed of $total expansions',
        ),
      ),
    );

    final downloadPath = p.join(
      (await getTemporaryDirectory()).path,
      'digicard-bulk-${bulk.updatedAt}.json',
    );
    controller.add(const SyncProgress(SyncStage.downloading, fraction: 0));
    await _api.downloadBulk(
      bulk,
      downloadPath,
      onProgress: (received, total) => controller.add(
        SyncProgress(
          SyncStage.downloading,
          fraction: total <= 0 ? null : received / total,
          detail: '${_megabytes(received)} of ${_megabytes(total)} MB',
        ),
      ),
    );

    try {
      controller.add(const SyncProgress(SyncStage.parsing));
      final cards = await parseBulkFile(downloadPath);

      controller.add(const SyncProgress(SyncStage.storing));
      await _store(cards, details, ids);

      controller.add(const SyncProgress(SyncStage.indexing));
      await _db.rebuildSearchIndex();

      await _db
          .into(_db.syncState)
          .insertOnConflictUpdate(
            SyncStateCompanion.insert(
              id: const Value(1),
              bulkId: Value(bulk.id),
              bulkUpdatedAt: Value(bulk.updatedAt),
              syncedAt: Value(DateTime.now()),
              cardCount: Value(cards.length),
            ),
          );

      controller.add(
        SyncProgress(
          SyncStage.complete,
          fraction: 1,
          detail: '${cards.length} cards',
        ),
      );
    } finally {
      // The dump is only needed until it is in the database.
      final file = File(downloadPath);
      if (file.existsSync()) {
        await file.delete();
      }
    }
  }

  Future<void> _store(
    List<ParsedCard> cards,
    List<ReleaseDetail> details,
    List<String> orderedIds,
  ) async {
    // A card belongs to a release if either side of the API says so: the
    // card's own relationships miss a handful of cards, and a release's card
    // list misses the ones filed only under a promo bucket.
    final links = <String, Set<String>>{};
    for (final card in cards) {
      links.putIfAbsent(card.id, () => <String>{}).addAll(card.releaseIds);
    }
    final knownCardIds = {for (final card in cards) card.id};
    for (final detail in details) {
      for (final cardId in detail.cardIds) {
        if (!knownCardIds.contains(cardId)) continue;
        links.putIfAbsent(cardId, () => <String>{}).add(detail.id);
      }
    }

    final cardCountByRelease = <String, int>{};
    for (final entry in links.entries) {
      for (final releaseId in entry.value) {
        cardCountByRelease[releaseId] = (cardCountByRelease[releaseId] ?? 0) + 1;
      }
    }

    await _db.transaction(() async {
      await _db.delete(_db.cardReleaseLinks).go();
      await _db.delete(_db.cardTraits).go();
      await _db.delete(_db.cardKeywords).go();
      await _db.delete(_db.cards).go();
      await _db.delete(_db.releases).go();

      await _db.batch((batch) {
        batch.insertAll(_db.releases, [
          for (final detail in details)
            ReleasesCompanion.insert(
              id: detail.id,
              name: detail.name,
              groupName: classifyRelease(detail.id).name,
              genre: Value(detail.genre),
              releaseDate: Value(detail.date),
              imageUrl: Value(detail.imageUrl),
              thumbnailUrl: Value(detail.thumbnailUrl),
              productUri: Value(detail.productUri),
              cardlistUri: Value(detail.cardlistUri),
              cardCount: Value(cardCountByRelease[detail.id] ?? 0),
              sortIndex: Value(orderedIds.indexOf(detail.id)),
            ),
        ]);

        batch.insertAll(_db.cards, [
          for (final card in cards)
            CardsCompanion.insert(
              id: card.id,
              number: card.number,
              parallelId: Value(card.parallelId),
              name: card.name,
              category: card.category,
              colors: Value(encodeList(card.colors)),
              colorCount: Value(card.colors.length),
              rarity: Value(card.rarity),
              supplementalStars: Value(card.supplementalStars),
              level: Value(card.level),
              playCost: Value(card.playCost),
              useCost: Value(card.useCost),
              cost: Value(card.cost),
              dp: Value(card.dp),
              form: Value(card.form),
              attribute: Value(card.attribute),
              blockIcon: Value(card.blockIcon),
              traits: Value(encodeList(card.traits)),
              keywords: Value(encodeList(card.keywords)),
              effect: Value(card.effect),
              inheritedEffect: Value(card.inheritedEffect),
              securityEffect: Value(card.securityEffect),
              digivolveCostMin: Value(card.digivolveCostMin),
              digivolveCostMax: Value(card.digivolveCostMax),
              digivolutionRequirements: Value(card.digivolutionRequirements),
              dualFace: Value(card.dualFace),
              dualCategory: Value(card.dualCategory),
              notes: Value(card.notes),
              faqs: Value(card.faqs),
              errata: Value(card.errata),
              limitations: Value(card.limitations),
              copyLimit: Value(card.copyLimit),
              imageUrl: card.imageUrl,
              releaseIds: Value(encodeList(links[card.id] ?? const {})),
              isPrimary: Value(card.isPrimary),
              numberSort: Value(card.numberSort),
            ),
        ]);

        batch.insertAll(_db.cardTraits, [
          for (final card in cards)
            for (final trait in card.traits)
              CardTraitsCompanion.insert(cardId: card.id, trait: trait),
        ]);

        batch.insertAll(_db.cardKeywords, [
          for (final card in cards)
            for (final keyword in card.keywords)
              CardKeywordsCompanion.insert(cardId: card.id, keyword: keyword),
        ]);

        batch.insertAll(_db.cardReleaseLinks, [
          for (final entry in links.entries)
            for (final releaseId in entry.value)
              CardReleaseLinksCompanion.insert(
                cardId: entry.key,
                releaseId: releaseId,
              ),
        ]);
      });
    });
  }

  static String _megabytes(int bytes) =>
      (bytes / (1024 * 1024)).toStringAsFixed(1);
}
