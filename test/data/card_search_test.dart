import 'package:digi_card_app/data/db/app_database.dart';
import 'package:digi_card_app/domain/models/card_filter.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Cards keyed by number, each with the traits and keywords a search has to
/// separate them by.
const _cards = {
  'BT1-001': (traits: ['Dragon', 'Vaccine'], keywords: ['Blocker', 'Rush']),
  'BT1-002': (traits: ['Dragon'], keywords: ['Blocker']),
  'BT1-003': (traits: ['Vaccine'], keywords: ['Rush']),
  'BT1-004': (traits: ['Beast'], keywords: <String>[]),
};

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');

    await db.batch((batch) {
      batch.insertAll(db.cards, [
        for (final number in _cards.keys)
          CardsCompanion.insert(
            id: number,
            number: number,
            name: number,
            category: 'digimon',
            imageUrl: 'https://example.test/$number.webp',
          ),
      ]);
      batch.insertAll(db.cardTraits, [
        for (final entry in _cards.entries)
          for (final trait in entry.value.traits)
            CardTraitsCompanion.insert(cardId: entry.key, trait: trait),
      ]);
      batch.insertAll(db.cardKeywords, [
        for (final entry in _cards.entries)
          for (final keyword in entry.value.keywords)
            CardKeywordsCompanion.insert(cardId: entry.key, keyword: keyword),
      ]);
    });
  });

  tearDown(() => db.close());

  Future<List<String>> search(CardFilter filter) async {
    final cards = await db.cardDao.search(filter);
    return cards.map((card) => card.number).toList();
  }

  group('trait match mode', () {
    test('any of returns cards carrying either trait', () async {
      const filter = CardFilter(traits: {'Dragon', 'Vaccine'});

      expect(await search(filter), ['BT1-001', 'BT1-002', 'BT1-003']);
      expect(await db.cardDao.count(filter), 3);
    });

    test('all of returns only the cards carrying both', () async {
      const filter = CardFilter(
        traits: {'Dragon', 'Vaccine'},
        traitMatchMode: MatchMode.all,
      );

      expect(await search(filter), ['BT1-001']);
      expect(await db.cardDao.count(filter), 1);
    });

    test('one trait means the same thing in either mode', () async {
      expect(
        await search(
          const CardFilter(traits: {'Beast'}, traitMatchMode: MatchMode.all),
        ),
        ['BT1-004'],
      );
    });
  });

  group('keyword match mode', () {
    test('any of returns cards carrying either keyword', () async {
      expect(await search(const CardFilter(keywords: {'Blocker', 'Rush'})), [
        'BT1-001',
        'BT1-002',
        'BT1-003',
      ]);
    });

    test('all of returns only the cards carrying both', () async {
      expect(
        await search(
          const CardFilter(
            keywords: {'Blocker', 'Rush'},
            keywordMatchMode: MatchMode.all,
          ),
        ),
        ['BT1-001'],
      );
    });
  });

  group('card-number scope', () {
    test('limits the search to the numbers given', () async {
      expect(
        await search(const CardFilter(cardNumbers: {'BT1-002', 'BT1-004'})),
        ['BT1-002', 'BT1-004'],
      );
    });

    test('narrows further with the facets on top of it', () async {
      expect(
        await search(
          const CardFilter(
            cardNumbers: {'BT1-001', 'BT1-002', 'BT1-004'},
            traits: {'Dragon'},
          ),
        ),
        ['BT1-001', 'BT1-002'],
      );
    });

    test('an empty scope is the whole library', () async {
      expect(await search(const CardFilter()), hasLength(4));
    });
  });

  test('an all-of match still narrows the rest of the filter', () async {
    expect(
      await search(
        const CardFilter(
          traits: {'Dragon', 'Vaccine'},
          traitMatchMode: MatchMode.all,
          keywords: {'Rush'},
        ),
      ),
      ['BT1-001'],
    );
    expect(
      await search(
        const CardFilter(
          traits: {'Dragon', 'Vaccine'},
          traitMatchMode: MatchMode.all,
          keywords: {'Piercing'},
        ),
      ),
      isEmpty,
    );
  });
}
