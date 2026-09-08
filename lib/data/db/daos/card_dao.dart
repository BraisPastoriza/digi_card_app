import 'package:drift/drift.dart';

import '../../../domain/models/card_enums.dart';
import '../../../domain/models/card_filter.dart';
import '../../../domain/models/digimon_card.dart';
import '../app_database.dart';
import '../mappers.dart';
import '../tables.dart';

part 'card_dao.g.dart';

@DriftAccessor(
  tables: [Cards, CardTraits, CardKeywords, CardReleaseLinks, SyncState],
)
class CardDao extends DatabaseAccessor<AppDatabase> with _$CardDaoMixin {
  CardDao(super.db);

  /// Cards matching [filter], ordered by [CardFilter.sort].
  Future<List<DigimonCard>> search(
    CardFilter filter, {
    int limit = 60,
    int offset = 0,
  }) async {
    final query = select(cards)
      ..where((_) => _predicate(filter))
      ..orderBy(_ordering(filter.sort))
      ..limit(limit, offset: offset);
    final rows = await query.get();
    return rows.map((row) => row.toDigimonCard()).toList();
  }

  /// How many cards [filter] matches, for the result count in the header.
  Future<int> count(CardFilter filter) async {
    final countExp = cards.id.count();
    final query = selectOnly(cards)
      ..addColumns([countExp])
      ..where(_predicate(filter));
    final row = await query.getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<DigimonCard?> cardById(String id) async {
    final row = await (select(
      cards,
    )..where((c) => c.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    final siblings = await _printingIdsOfNumber(row.number);
    return row.toDigimonCard(
      alternateArtIds: siblings.where((s) => s != id).toList(),
    );
  }

  /// Every printing of a card number, base art first. Drives the alternate art
  /// carousel on the detail screen.
  Future<List<DigimonCard>> printingsOfNumber(String number) async {
    final query = select(cards)
      ..where((c) => c.number.equals(number))
      ..orderBy([(c) => OrderingTerm.asc(c.parallelId)]);
    final rows = await query.get();
    final ids = rows.map((r) => r.id).toList();
    return rows
        .map(
          (row) => row.toDigimonCard(
            alternateArtIds: ids.where((id) => id != row.id).toList(),
          ),
        )
        .toList();
  }

  /// Primary printings for a set of card numbers, used to resolve deck entries
  /// back into cards.
  Future<Map<String, DigimonCard>> cardsByNumbers(
    Iterable<String> numbers,
  ) async {
    final wanted = numbers.toSet();
    if (wanted.isEmpty) return {};
    final query = select(cards)
      ..where((c) => c.number.isIn(wanted) & c.isPrimary.equals(true));
    final rows = await query.get();
    return {for (final row in rows) row.number: row.toDigimonCard()};
  }

  /// Primary printings looked up by printed name, case-insensitively, for
  /// importing deck lists that name cards without their number.
  ///
  /// A name can be shared by several numbers (Agumon is printed a dozen
  /// times over), so the lowest number wins and the importer says which card
  /// it settled on.
  Future<Map<String, DigimonCard>> cardsByNames(Iterable<String> names) async {
    final wanted = {for (final name in names) name.toLowerCase().trim()}
      ..remove('');
    if (wanted.isEmpty) return {};
    final query = select(cards)
      ..where((c) => c.name.lower().isIn(wanted) & c.isPrimary.equals(true))
      ..orderBy([(c) => OrderingTerm.asc(c.numberSort)]);
    final resolved = <String, DigimonCard>{};
    for (final row in await query.get()) {
      resolved.putIfAbsent(row.name.toLowerCase(), () => row.toDigimonCard());
    }
    return resolved;
  }

  /// A card from each of [releaseIds] to stand in for its product photo.
  ///
  /// Worked out here rather than stored on the release, because it is derived
  /// entirely from cards that are already on the device: keeping it as a
  /// column meant every change to the choice cost a full re-download to
  /// recompute, which is a lot of bytes to move a picture.
  ///
  /// Promotional buckets get their newest promo — they are not built around a
  /// boss card, and hundreds of loose cards with no level or DP would
  /// otherwise tie at nothing. Everything else gets its biggest Digimon, the
  /// same reading a deck's signature card uses.
  Future<Map<String, String>> representativeCardImages(
    Set<String> releaseIds, {
    required bool Function(String releaseId) prefersNewestPromo,
  }) async {
    if (releaseIds.isEmpty) return const {};

    final links = alias(cardReleaseLinks, 'l');
    final query = select(cards).join([
      innerJoin(links, links.cardId.equalsExp(cards.id)),
    ])..where(links.releaseId.isIn(releaseIds));

    final best = <String, CardRow>{};
    for (final row in await query.get()) {
      final releaseId = row.readTable(links).releaseId;
      final card = row.readTable(cards);
      final promoRule = prefersNewestPromo(releaseId);
      if (promoRule && !card.number.toUpperCase().startsWith('P-')) continue;

      final current = best[releaseId];
      if (current == null ||
          (promoRule
              ? card.numberSort.compareTo(current.numberSort) > 0
              : _showiness(card) > _showiness(current))) {
        best[releaseId] = card;
      }
    }
    return {for (final entry in best.entries) entry.key: entry.value.imageUrl};
  }

  /// How much a card looks like the face of its set: level first, then the
  /// numbers that separate two cards of the same level.
  static int _showiness(CardRow card) =>
      (card.level ?? 0) * 1000000 + (card.dp ?? 0) + (card.cost ?? 0);

  /// Cards belonging to a release, in card-number order.
  ///
  /// Collapsing alternate arts uses the per-release flag rather than the
  /// card's global primary printing: promo and accessory products are made
  /// almost entirely of alternate arts whose base printing belongs to some
  /// other set, so a global collapse leaves them empty.
  Future<List<DigimonCard>> cardsInRelease(
    String releaseId, {
    bool includeAlternateArts = false,
    bool promosOnly = false,
  }) async {
    final link = selectOnly(cardReleaseLinks)
      ..addColumns([cardReleaseLinks.cardId])
      ..where(
        includeAlternateArts
            ? cardReleaseLinks.releaseId.equals(releaseId)
            : cardReleaseLinks.releaseId.equals(releaseId) &
                  cardReleaseLinks.isPrimaryInRelease.equals(true),
      );
    final query = select(cards)
      ..where(
        (c) => promosOnly
            // Promo products bundle alternate arts of ordinary set cards
            // alongside the promos proper, and only the promos carry a `P-`
            // number.
            ? c.id.isInQuery(link) & c.number.like('P-%')
            : c.id.isInQuery(link),
      )
      ..orderBy([(c) => OrderingTerm.asc(c.numberSort)]);
    final rows = await query.get();
    return rows.map((row) => row.toDigimonCard()).toList();
  }

  Future<List<String>> distinctTraits() => _distinctValues(
    selectOnly(cardTraits, distinct: true)
      ..addColumns([cardTraits.trait])
      ..orderBy([OrderingTerm.asc(cardTraits.trait)]),
    cardTraits.trait,
  );

  Future<List<String>> distinctKeywords() => _distinctValues(
    selectOnly(cardKeywords, distinct: true)
      ..addColumns([cardKeywords.keyword])
      ..orderBy([OrderingTerm.asc(cardKeywords.keyword)]),
    cardKeywords.keyword,
  );

  /// Rarities in printed order, least rare first, rather than the
  /// alphabetical order SQL would give them.
  Future<List<String>> distinctRarities() async {
    final rarities = await _distinctCardValues(cards.rarity);
    return rarities..sort(CardRarity.compare);
  }

  Future<List<String>> distinctForms() => _distinctCardValues(cards.form);

  Future<List<String>> distinctAttributes() =>
      _distinctCardValues(cards.attribute);

  Future<int> totalCardCount() async {
    final countExp = cards.id.count();
    final row = await (selectOnly(cards)..addColumns([countExp])).getSingle();
    return row.read(countExp) ?? 0;
  }

  Future<List<String>> _printingIdsOfNumber(String number) async {
    final query = selectOnly(cards)
      ..addColumns([cards.id])
      ..where(cards.number.equals(number))
      ..orderBy([OrderingTerm.asc(cards.parallelId)]);
    final rows = await query.get();
    return rows.map((r) => r.read(cards.id)!).toList();
  }

  Future<List<String>> _distinctValues(
    JoinedSelectStatement query,
    GeneratedColumn<String> column,
  ) async {
    final rows = await query.get();
    return rows
        .map((r) => r.read<String>(column))
        .whereType<String>()
        .where((v) => v.isNotEmpty)
        .toList();
  }

  Future<List<String>> _distinctCardValues(
    GeneratedColumn<String> column,
  ) async {
    final query = selectOnly(cards, distinct: true)
      ..addColumns([column])
      ..where(column.isNotNull())
      ..orderBy([OrderingTerm.asc(column)]);
    return _distinctValues(query, column);
  }

  Expression<bool> _predicate(CardFilter filter) {
    var predicate = const Constant(true) as Expression<bool>;

    if (!filter.includeAlternateArts) {
      predicate = predicate & cards.isPrimary.equals(true);
    }

    final match = _ftsMatchExpression(filter.query);
    if (match != null) predicate = predicate & match;

    if (filter.colors.isNotEmpty) {
      final clauses = filter.colors
          .map(
            (color) => cards.colors.like(
              '%$listDelimiter${color.apiValue}$listDelimiter%',
            ),
          )
          .toList();
      predicate =
          predicate &
          switch (filter.colorMatchMode) {
            ColorMatchMode.any => clauses.reduce((a, b) => a | b),
            ColorMatchMode.all => clauses.reduce((a, b) => a & b),
            ColorMatchMode.exact =>
              clauses.reduce((a, b) => a & b) &
                  cards.colorCount.equals(filter.colors.length),
          };
    }

    if (filter.categories.isNotEmpty) {
      // A dual card is both a Digimon and an Option, so it should surface
      // under either category.
      final values = filter.categories.map((c) => c.apiValue).toList();
      predicate =
          predicate &
          (cards.category.isIn(values) | cards.dualCategory.isIn(values));
    }

    if (filter.levels.isNotEmpty) {
      predicate = predicate & cards.level.isIn(filter.levels);
    }

    if (filter.rarities.isNotEmpty) {
      predicate = predicate & cards.rarity.isIn(filter.rarities);
    }

    if (filter.forms.isNotEmpty) {
      predicate = predicate & cards.form.isIn(filter.forms);
    }

    if (filter.attributes.isNotEmpty) {
      predicate = predicate & cards.attribute.isIn(filter.attributes);
    }

    if (filter.traits.isNotEmpty) {
      predicate =
          predicate &
          _linked(
            filter.traits,
            filter.traitMatchMode,
            (values) => selectOnly(cardTraits)
              ..addColumns([cardTraits.cardId])
              ..where(cardTraits.trait.isIn(values)),
          );
    }

    if (filter.keywords.isNotEmpty) {
      predicate =
          predicate &
          _linked(
            filter.keywords,
            filter.keywordMatchMode,
            (values) => selectOnly(cardKeywords)
              ..addColumns([cardKeywords.cardId])
              ..where(cardKeywords.keyword.isIn(values)),
          );
    }

    if (filter.releaseIds.isNotEmpty) {
      predicate =
          predicate &
          cards.id.isInQuery(
            selectOnly(cardReleaseLinks)
              ..addColumns([cardReleaseLinks.cardId])
              ..where(cardReleaseLinks.releaseId.isIn(filter.releaseIds)),
          );
    }

    predicate = predicate & _range(cards.cost, filter.playCost);
    predicate = predicate & _range(cards.dp, filter.dp);

    // A card qualifies if any of its digivolution requirements falls in range,
    // which the min/max columns capture without unpacking the JSON.
    final digivolve = filter.digivolveCost;
    if (digivolve.min != null) {
      predicate =
          predicate &
          cards.digivolveCostMax.isBiggerOrEqualValue(digivolve.min!);
    }
    if (digivolve.max != null) {
      predicate =
          predicate &
          cards.digivolveCostMin.isSmallerOrEqualValue(digivolve.max!);
    }

    if (filter.restrictedOnly) {
      predicate = predicate & cards.copyLimit.isSmallerThanValue(4);
    }

    // ACE and dual narrow the result rather than widening it: "Digimon + ACE"
    // means ACE Digimon, not Digimon plus every ACE card.
    if (filter.aceOnly) predicate = predicate & cards.isAce.equals(true);
    if (filter.dualOnly) predicate = predicate & cards.dualFace.isNotNull();

    predicate =
        predicate &
        switch (filter.tokens) {
          TokenMode.include => const Constant(true),
          TokenMode.only => _isToken,
          TokenMode.exclude => _isToken.not(),
        };

    return predicate;
  }

  /// Matches the token printings.
  ///
  /// Nothing in the card data marks a token, so this mirrors
  /// [DigimonCard.isToken] and goes by the printed number: `TOKEN` on its own,
  /// or a set code followed by it (`BT22-TOKEN`, `ST22-TOKEN01`).
  Expression<bool> get _isToken =>
      cards.number.like('TOKEN%') | cards.number.like('%-TOKEN%');

  Expression<bool> _range(GeneratedColumn<int> column, RangeFilter range) {
    var predicate = const Constant(true) as Expression<bool>;
    if (range.min != null) {
      predicate = predicate & column.isBiggerOrEqualValue(range.min!);
    }
    if (range.max != null) {
      predicate = predicate & column.isSmallerOrEqualValue(range.max!);
    }
    return predicate;
  }

  /// Restricts to cards whose text matches [rawQuery] using the FTS5 index.
  ///
  /// The query string is interpolated rather than bound because drift cannot
  /// bind variables inside a [CustomExpression]. That is safe here only
  /// because [_toFtsQuery] rebuilds the string from scratch out of
  /// letter/digit tokens, discarding every quote and operator the user typed.
  Expression<bool>? _ftsMatchExpression(String rawQuery) {
    final ftsQuery = _toFtsQuery(rawQuery);
    if (ftsQuery == null) return null;
    return CustomExpression<bool>(
      "cards.id IN (SELECT card_id FROM $cardSearchTable "
      "WHERE $cardSearchTable MATCH '$ftsQuery')",
    );
  }

  /// Turns free text into an FTS5 prefix query, or null when there is nothing
  /// searchable in it.
  static String? _toFtsQuery(String rawQuery) {
    final tokens = rawQuery
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}]+', unicode: true), ' ')
        .split(' ')
        .where((token) => token.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return null;
    return tokens.map((token) => '"$token"*').join(' ');
  }

  List<OrderingTerm Function($CardsTable)> _ordering(CardSort sort) =>
      switch (sort) {
        CardSort.number => [(c) => OrderingTerm.asc(c.numberSort)],
        CardSort.nameAsc => [
          (c) => OrderingTerm.asc(c.name),
          (c) => OrderingTerm.asc(c.numberSort),
        ],
        // SQLite sorts NULLs first, which would bury costless cards at the top
        // of an ascending cost list; order by nullness first to push them out.
        CardSort.costAsc => [
          (c) => OrderingTerm.asc(c.cost.isNull()),
          (c) => OrderingTerm.asc(c.cost),
          (c) => OrderingTerm.asc(c.numberSort),
        ],
        CardSort.costDesc => [
          (c) => OrderingTerm.asc(c.cost.isNull()),
          (c) => OrderingTerm.desc(c.cost),
          (c) => OrderingTerm.asc(c.numberSort),
        ],
        CardSort.dpDesc => [
          (c) => OrderingTerm.asc(c.dp.isNull()),
          (c) => OrderingTerm.desc(c.dp),
          (c) => OrderingTerm.asc(c.numberSort),
        ],
        CardSort.levelAsc => [
          (c) => OrderingTerm.asc(c.level.isNull()),
          (c) => OrderingTerm.asc(c.level),
          (c) => OrderingTerm.asc(c.numberSort),
        ],
      };
}
