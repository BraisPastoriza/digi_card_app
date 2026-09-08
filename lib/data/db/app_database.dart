import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/card_dao.dart';
import 'daos/deck_dao.dart';
import 'daos/release_dao.dart';
import 'tables.dart';

part 'app_database.g.dart';

/// Name of the FTS5 index over card text.
///
/// It is created with raw SQL rather than a drift table because drift has no
/// typed model for virtual tables; queries against it go through
/// [customSelect] in [CardDao].
const cardSearchTable = 'card_search';

@DriftDatabase(
  tables: [
    Releases,
    Cards,
    CardTraits,
    CardKeywords,
    CardReleaseLinks,
    Decks,
    DeckRevisions,
    DeckEntries,
    SyncState,
  ],
  daos: [CardDao, ReleaseDao, DeckDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Used by tests to run against an in-memory database.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 9;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _createSearchIndex();
      await _createIndexes();
    },
    // Everything on the card side is a cache of the published card list, so an
    // upgrade throws it away and re-syncs rather than migrating column by
    // column. That also covers the columns derived at sync time — keywords are
    // parsed out of effect text, so a change to the parser only reaches the
    // user through a version bump. Decks are the only data the user authored,
    // and they survive: they reference cards by printed number, not by row.
    // Their own columns do have to be migrated one by one.
    // Note on version 8: it once carried a `tile_card_image` column on
    // releases, precomputed at sync time. Working out a release's stand-in
    // card is now done by querying the cards already on the device, so the
    // column is gone from the schema without a version bump: an install that
    // still has it simply never writes or reads it, and the next migration
    // that recreates the card tables clears it away. Bumping instead would
    // have cost every user a 25 MB re-download to change which picture a tile
    // shows, which is what this move exists to stop.
    onUpgrade: (m, from, to) async {
      if (from < 3) await m.addColumn(decks, decks.thumbnailCardNumber);
      await resetCardData(m);
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  /// Drops and recreates the card tables, leaving decks untouched. The next
  /// launch finds no cards and runs a sync.
  Future<void> resetCardData(Migrator m) async {
    final cardTables = <TableInfo<Table, dynamic>>[
      cardReleaseLinks,
      cardTraits,
      cardKeywords,
      cards,
      releases,
      syncState,
    ];
    for (final table in cardTables) {
      await m.deleteTable(table.actualTableName);
      await m.createTable(table);
    }
    await customStatement('DROP TABLE IF EXISTS $cardSearchTable');
    await _createSearchIndex();
    await _createIndexes();
  }

  /// Rebuilds the FTS index from scratch. Called after a card sync, which
  /// replaces the whole dataset anyway.
  Future<void> rebuildSearchIndex() async {
    await customStatement('DROP TABLE IF EXISTS $cardSearchTable');
    await _createSearchIndex();
    await customStatement('''
      INSERT INTO $cardSearchTable (card_id, name, effect, inherited_effect, security_effect, traits)
      SELECT id, name, COALESCE(effect, ''), COALESCE(inherited_effect, ''),
             COALESCE(security_effect, ''), REPLACE(traits, '$listDelimiter', ' ')
      FROM cards
    ''');
  }

  /// Re-indexes just [cardIds], dropping the entries of any that are gone.
  ///
  /// Refreshing a preview set touches a hundred cards or so out of 7,600, and
  /// it happens while the user is looking at the set — rebuilding the whole
  /// index for that would be several seconds of the search box being wrong.
  Future<void> refreshSearchIndexFor(Set<String> cardIds) async {
    if (cardIds.isEmpty) return;
    // FTS5 tables take no parameter placeholders in an `IN` list on every
    // SQLite build, and card ids are printed card numbers from the API rather
    // than anything a user types, so they are quoted inline.
    final list = cardIds.map((id) => "'${id.replaceAll("'", "''")}'").join(',');
    await customStatement(
      'DELETE FROM $cardSearchTable WHERE card_id IN ($list)',
    );
    await customStatement('''
      INSERT INTO $cardSearchTable (card_id, name, effect, inherited_effect, security_effect, traits)
      SELECT id, name, COALESCE(effect, ''), COALESCE(inherited_effect, ''),
             COALESCE(security_effect, ''), REPLACE(traits, '$listDelimiter', ' ')
      FROM cards WHERE id IN ($list)
    ''');
  }

  Future<void> _createSearchIndex() async {
    // `unicode61` with diacritics folded so "Wargreymon" finds "WarGreymon"
    // and accented card names match unaccented queries.
    await customStatement('''
      CREATE VIRTUAL TABLE IF NOT EXISTS $cardSearchTable USING fts5(
        card_id UNINDEXED,
        name,
        effect,
        inherited_effect,
        security_effect,
        traits,
        tokenize = "unicode61 remove_diacritics 2"
      )
    ''');
  }

  Future<void> _createIndexes() async {
    const statements = [
      'CREATE INDEX IF NOT EXISTS idx_cards_number ON cards (number)',
      'CREATE INDEX IF NOT EXISTS idx_cards_category ON cards (category)',
      'CREATE INDEX IF NOT EXISTS idx_cards_parallel ON cards (parallel_id)',
      'CREATE INDEX IF NOT EXISTS idx_cards_number_sort ON cards (number_sort)',
      'CREATE INDEX IF NOT EXISTS idx_card_traits_trait ON card_traits (trait)',
      'CREATE INDEX IF NOT EXISTS idx_card_keywords_keyword ON card_keywords (keyword)',
      'CREATE INDEX IF NOT EXISTS idx_card_releases_release ON card_release_links (release_id)',
      'CREATE INDEX IF NOT EXISTS idx_deck_revisions_deck ON deck_revisions (deck_id)',
      'CREATE INDEX IF NOT EXISTS idx_deck_entries_revision ON deck_entries (revision_id)',
    ];
    for (final statement in statements) {
      await customStatement(statement);
    }
  }

  static QueryExecutor _openConnection() => driftDatabase(name: 'digicard');
}
