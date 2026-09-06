import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../domain/models/card_enums.dart';
import '../../domain/models/card_release.dart';
import '../api/digimoncard_io_api.dart';
import '../api/heroi_api.dart';
import '../db/app_database.dart';
import '../db/tables.dart';
import 'bulk_parser.dart';
import 'digimoncard_io_parser.dart';

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
  CardSyncService(this._db, this._api, this._secondaryApi);

  final AppDatabase _db;
  final HeroiApi _api;
  final DigimonCardIoApi _secondaryApi;

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

      final previews = await _fetchPreviewSets(
        ids,
        controller,
        knownNumbers: {for (final card in cards) card.number},
      );
      cards.addAll(previews.cards);

      controller.add(const SyncProgress(SyncStage.storing));
      await _store(cards, [...details, ...previews.details], ids);

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

  /// Fills in the sets the primary API has not published yet.
  ///
  /// Two things keep this contained. It skips any preview set the primary API
  /// has started publishing, so each one retires itself the day the canonical
  /// data lands and no code has to be deleted. And it swallows its own
  /// failures: the secondary source is a bonus, so a sync must finish exactly
  /// as it does today if that API is down, slow, or has changed shape.
  Future<({List<ParsedCard> cards, List<ReleaseDetail> details})>
  _fetchPreviewSets(
    List<String> publishedIds,
    StreamController<SyncProgress> controller, {
    required Set<String> knownNumbers,
  }) async {
    final wanted = previewReleases
        .where((preview) => !publishedIds.contains(preview.id))
        .toList();
    if (wanted.isEmpty) {
      return (cards: <ParsedCard>[], details: <ReleaseDetail>[]);
    }

    final cards = <ParsedCard>[];
    final details = <ReleaseDetail>[];

    for (final preview in wanted) {
      controller.add(
        SyncProgress(SyncStage.releases, detail: 'Preview: ${preview.pack}'),
      );
      try {
        // One request at a time: two sequential calls stay far under the
        // secondary API's 15-per-10-seconds limit with no throttling of our
        // own to get wrong.
        final rows = await _secondaryApi.cardsInPack(preview.pack);
        final parsed = parseDigimonCardIoPack(rows, preview);
        if (parsed.isEmpty) continue;

        // A Limited pack is mostly reprints of cards from other sets, and the
        // primary source already has those — with better data and their real
        // artwork. Only what is genuinely new gets stored; the reprints are
        // linked to the pack through the release detail below, so the pack
        // still lists its full contents.
        cards.addAll(
          parsed.where((card) => !knownNumbers.contains(card.number)),
        );
        details.add(
          ReleaseDetail(
            id: preview.id,
            name: preview.name,
            cardIds: parsed.map((card) => card.id).toList(),
            genre: preview.genre,
          ),
        );
      } on Object {
        // Deliberately swallowed: an unreachable preview set must never cost
        // the user the 7,600 cards the primary sync just downloaded.
        continue;
      }
    }
    return (cards: cards, details: details);
  }

  Future<void> _store(
    List<ParsedCard> cards,
    List<ReleaseDetail> details,
    List<String> orderedIds,
  ) async {
    final byId = {for (final card in cards) card.id: card};

    // A card belongs to a release if either side of the API says so: the
    // card's own relationships miss a handful of cards, and a release's card
    // list misses the ones filed only under a promo bucket.
    final releaseToCards = <String, Set<String>>{};
    for (final card in cards) {
      for (final releaseId in card.releaseIds) {
        releaseToCards.putIfAbsent(releaseId, () => <String>{}).add(card.id);
      }
    }
    for (final detail in details) {
      for (final cardId in detail.cardIds) {
        if (!byId.containsKey(cardId)) continue;
        releaseToCards.putIfAbsent(detail.id, () => <String>{}).add(cardId);
      }
    }

    _addAllPromosRelease(releaseToCards, details);
    _addAllLimitedRelease(releaseToCards, cards);

    // One printing per card number, chosen among the printings that release
    // actually contains. Choosing globally instead would leave promo and
    // accessory products empty, because their cards are alternate arts of
    // base printings that belong to other sets.
    final primaryInRelease = <String, Set<String>>{};
    for (final entry in releaseToCards.entries) {
      final lowestByNumber = <String, ParsedCard>{};
      for (final cardId in entry.value) {
        final card = byId[cardId];
        if (card == null) continue;
        final current = lowestByNumber[card.number];
        if (current == null || card.parallelId < current.parallelId) {
          lowestByNumber[card.number] = card;
        }
      }
      primaryInRelease[entry.key] = {
        for (final card in lowestByNumber.values) card.id,
      };
    }

    final links = <String, Set<String>>{};
    for (final entry in releaseToCards.entries) {
      for (final cardId in entry.value) {
        links.putIfAbsent(cardId, () => <String>{}).add(entry.key);
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
          for (final detail in _withAllPromos(details))
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
              cardCount: Value(primaryInRelease[detail.id]?.length ?? 0),
              printingCount: Value(releaseToCards[detail.id]?.length ?? 0),
              dataSource: Value(
                previewReleases.any((p) => p.id == detail.id)
                    ? secondarySourceName
                    : null,
              ),
              // Neither the promo aggregate nor a preview set appears in the
              // API's own ordering. The aggregate floats to the top of its
              // group; a preview set is the newest thing there is, so it sorts
              // past every published release rather than to the -1 that
              // `indexOf` would give it.
              sortIndex: Value(switch (detail.id) {
                allPromosReleaseId => orderedIds.length + 1,
                final id when previewReleases.any((p) => p.id == id) =>
                  orderedIds.length + 2,
                allLimitedReleaseId => orderedIds.length + 3,
                final id => orderedIds.indexOf(id),
              }),
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
              ruleCopyLimit: Value(card.ruleCopyLimit),
              imageUrl: card.imageUrl,
              releaseIds: Value(encodeList(links[card.id] ?? const {})),
              isPrimary: Value(card.isPrimary),
              isAce: Value(card.isAce),
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
          for (final entry in releaseToCards.entries)
            for (final cardId in entry.value)
              CardReleaseLinksCompanion.insert(
                cardId: cardId,
                releaseId: entry.key,
                isPrimaryInRelease: Value(
                  primaryInRelease[entry.key]?.contains(cardId) ?? true,
                ),
              ),
        ]);
      });
    });
  }

  /// Files every promotional card under one aggregate release, so a player who
  /// only has the card in hand can find it without knowing which event or
  /// product it came from.
  void _addAllPromosRelease(
    Map<String, Set<String>> releaseToCards,
    List<ReleaseDetail> details,
  ) {
    final promoCards = <String>{};
    for (final entry in releaseToCards.entries) {
      if (classifyRelease(entry.key) != ReleaseGroup.promo) continue;
      promoCards.addAll(entry.value);
    }
    if (promoCards.isNotEmpty) {
      releaseToCards[allPromosReleaseId] = promoCards;
    }
  }

  /// Files every Limited card under one aggregate release.
  ///
  /// The same problem the promo aggregate solves: a Limited card is a bonus
  /// tucked into some other product, six at a time, so the product it came in
  /// is the one thing the person holding it cannot look it up by.
  void _addAllLimitedRelease(
    Map<String, Set<String>> releaseToCards,
    List<ParsedCard> cards,
  ) {
    final limited = {
      for (final card in cards)
        if (card.number.toUpperCase().startsWith('LM-')) card.id,
    };
    if (limited.isNotEmpty) {
      releaseToCards[allLimitedReleaseId] = limited;
    }
  }

  /// The API's releases plus the synthetic promo aggregate, which borrows its
  /// artwork from the plain promotion-card product.
  List<ReleaseDetail> _withAllPromos(List<ReleaseDetail> details) {
    final donor = details.firstWhereOrNull(
      (detail) => detail.id == 'p' && detail.thumbnailUrl != null,
    );
    return [
      ...details,
      ReleaseDetail(
        id: allPromosReleaseId,
        name: 'All Promos',
        cardIds: const [],
        genre: 'Promotion Card',
        imageUrl: donor?.imageUrl,
        thumbnailUrl: donor?.thumbnailUrl,
      ),
      const ReleaseDetail(
        id: allLimitedReleaseId,
        name: 'All LM',
        cardIds: [],
        genre: 'Premium Bandai',
      ),
    ];
  }

  static String _megabytes(int bytes) =>
      (bytes / (1024 * 1024)).toStringAsFixed(1);
}
