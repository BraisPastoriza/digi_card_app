import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/utils/digivolve_parser.dart';
import '../../core/utils/keyword_parser.dart';
import '../../domain/models/digimon_card.dart';
import '../db/app_database.dart';
import '../db/card_data_versions.dart';
import '../db/tables.dart';
import 'bulk_parser.dart';

/// Re-reads the cards already on the device when the parsers change.
///
/// Everything here is worked out from text the database already holds, so a
/// change to how a card is read costs a pass over the local rows rather than
/// the 25 MB download an upgrade used to force. What it covers is exactly what
/// [ParsedCard] derives from that text:
///
///  * the keywords in the effect boxes,
///  * the copy limit a card's own ⟨Rule⟩ line grants,
///  * the cheapest and priciest way to digivolve into the card, and
///  * the collator key that sorts printed numbers.
///
/// It deliberately does not touch anything whose source is not stored — traits
/// are split from an API field the database does not keep — because guessing
/// at those would quietly write worse data than the sync did. Those changes go
/// through `CardDataVersions.invalidatedAt` instead.
class CardDerivations {
  CardDerivations(this._db);

  final AppDatabase _db;

  /// Cards read per pass. Card text is the bulk of the row, and 7,700 of them
  /// at once is a lot of string to hold for no gain.
  static const _pageSize = 500;

  /// The parser version the stored cards were last read with.
  Future<int> storedVersion() async {
    final state = await _db.select(_db.syncState).getSingleOrNull();
    return state?.derivedVersion ?? 0;
  }

  /// Whether [rederive] has anything to do.
  ///
  /// False on an install with no cards: there is nothing to re-read, and the
  /// sync that fills the database writes the current version itself.
  Future<bool> isStale() async {
    if (!CardDataVersions.needsRederive(await storedVersion())) return false;
    return await _db.cardDao.totalCardCount() > 0;
  }

  /// Reads every stored card again and writes back what changed. Returns the
  /// number of cards that actually needed it.
  Future<int> rederive({void Function(int done, int total)? onProgress}) async {
    final total = await _db.cardDao.totalCardCount();
    var done = 0;
    var changed = 0;

    for (var offset = 0; offset < total; offset += _pageSize) {
      final page =
          await (_db.select(_db.cards)
                ..orderBy([(c) => OrderingTerm.asc(c.id)])
                ..limit(_pageSize, offset: offset))
              .get();
      if (page.isEmpty) break;

      final updates = <_Derived>[];
      for (final row in page) {
        final derived = _derive(row);
        if (derived.differsFrom(row)) updates.add(derived);
      }

      if (updates.isNotEmpty) {
        await _write(updates);
        changed += updates.length;
      }
      done += page.length;
      onProgress?.call(done, total);
    }

    await markCurrent();
    return changed;
  }

  /// Records that the stored cards were read with the current parsers. The
  /// full sync calls this too, since everything it writes is already current.
  Future<void> markCurrent() async {
    await _db
        .into(_db.syncState)
        .insertOnConflictUpdate(
          SyncStateCompanion.insert(
            id: const Value(1),
            derivedVersion: const Value(CardDataVersions.derived),
          ),
        );
  }

  _Derived _derive(CardRow row) {
    final dualEffect = _dualEffect(row.dualFace);
    final texts = [
      row.effect,
      row.inheritedEffect,
      row.securityEffect,
      dualEffect,
    ];

    final ruleCopyLimit = CopyLimit.fromRuleText(texts);
    final requirementCosts = [
      ..._printedCosts(row.digivolutionRequirements),
      ...DigivolveParser.alternativesIn(
        row.effect,
      ).map((r) => r.cost).whereType<int>(),
    ];

    return _Derived(
      id: row.id,
      keywords: KeywordParser.extract(texts),
      numberSort: buildNumberSort(row.number, row.parallelId),
      ruleCopyLimit: ruleCopyLimit,
      copyLimit: CopyLimit.resolve(
        limitations: _limitations(row.limitations),
        ruleLimit: ruleCopyLimit,
      ),
      digivolveCostMin: requirementCosts.isEmpty
          ? null
          : requirementCosts.reduce((a, b) => a < b ? a : b),
      digivolveCostMax: requirementCosts.isEmpty
          ? null
          : requirementCosts.reduce((a, b) => a > b ? a : b),
    );
  }

  Future<void> _write(List<_Derived> updates) async {
    await _db.transaction(() async {
      await _db.batch((batch) {
        for (final derived in updates) {
          batch.update(
            _db.cards,
            CardsCompanion(
              keywords: Value(encodeList(derived.keywords)),
              numberSort: Value(derived.numberSort),
              copyLimit: Value(derived.copyLimit),
              ruleCopyLimit: Value(derived.ruleCopyLimit),
              digivolveCostMin: Value(derived.digivolveCostMin),
              digivolveCostMax: Value(derived.digivolveCostMax),
            ),
            where: (c) => c.id.equals(derived.id),
          );
        }
      });

      // The normalised keywords are what the filter searches, so they are
      // replaced wholesale for the cards that changed rather than diffed.
      final ids = updates.map((u) => u.id).toList();
      await (_db.delete(
        _db.cardKeywords,
      )..where((k) => k.cardId.isIn(ids))).go();
      await _db.batch((batch) {
        batch.insertAll(_db.cardKeywords, [
          for (final derived in updates)
            for (final keyword in derived.keywords)
              CardKeywordsCompanion.insert(
                cardId: derived.id,
                keyword: keyword,
              ),
        ], mode: InsertMode.insertOrIgnore);
      });
    });
  }

  /// The effect text on the other face of a dual card, which carries keywords
  /// of its own.
  static String? _dualEffect(String? dualFace) {
    if (dualFace == null || dualFace.isEmpty) return null;
    final decoded = jsonDecode(dualFace);
    return decoded is Map<String, dynamic>
        ? decoded['effect'] as String?
        : null;
  }

  static List<int> _printedCosts(String requirementsJson) {
    final decoded = jsonDecode(requirementsJson);
    if (decoded is! List) return const [];
    return [
      for (final entry in decoded)
        if (entry is Map<String, dynamic> && entry['cost'] is int)
          entry['cost'] as int,
    ];
  }

  static List<CardLimitation> _limitations(String limitationsJson) {
    final decoded = jsonDecode(limitationsJson);
    if (decoded is! List) return const [];
    return [
      for (final entry in decoded)
        if (entry is Map<String, dynamic>) CardLimitation.fromJson(entry),
    ];
  }
}

/// What one card works out to, and whether that is news.
class _Derived {
  const _Derived({
    required this.id,
    required this.keywords,
    required this.numberSort,
    required this.copyLimit,
    required this.ruleCopyLimit,
    required this.digivolveCostMin,
    required this.digivolveCostMax,
  });

  final String id;
  final List<String> keywords;
  final String numberSort;
  final int copyLimit;
  final int? ruleCopyLimit;
  final int? digivolveCostMin;
  final int? digivolveCostMax;

  bool differsFrom(CardRow row) =>
      encodeList(keywords) != row.keywords ||
      numberSort != row.numberSort ||
      copyLimit != row.copyLimit ||
      ruleCopyLimit != row.ruleCopyLimit ||
      digivolveCostMin != row.digivolveCostMin ||
      digivolveCostMax != row.digivolveCostMax;
}
