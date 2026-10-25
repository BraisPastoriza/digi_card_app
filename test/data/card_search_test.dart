import 'package:digi_card_app/data/db/app_database.dart';
import 'package:digi_card_app/domain/models/card_filter.dart';
import 'package:drift/drift.dart' show Value;
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

  group('text query', () {
    setUp(() async {
      await db.batch((batch) {
        for (final (number, name, effect) in [
          ('BT1-001', 'Baohuckmon', 'Gain 1 memory.'),
          ('BT1-002', 'Saviorhuckmon', null),
          ('BT1-003', 'Huckmon', null),
          ('BT1-004', 'Agumon', 'This Digimon gets +1000 DP for each place.'),
        ]) {
          batch.update(
            db.cards,
            CardsCompanion(name: Value(name), effect: Value(effect)),
            where: (c) => c.id.equals(number),
          );
        }
      });
      await db.rebuildSearchIndex();
    });

    test('finds a word inside a compound card name', () async {
      expect(await search(const CardFilter(query: 'huck')), [
        'BT1-001',
        'BT1-002',
        'BT1-003',
      ]);
    });

    test('matches effect text only at the start of a word', () async {
      expect(await search(const CardFilter(query: 'memory')), ['BT1-001']);
      expect(await search(const CardFilter(query: 'ace')), isEmpty);
    });

    test('needs every word to match', () async {
      expect(await search(const CardFilter(query: 'huck savior')), [
        'BT1-002',
      ]);
    });
  });

  group('cards in a release', () {
    setUp(() async {
      await db.batch((batch) {
        // An alternate art of BT1-004 that a promo product bundles: not the
        // card's primary printing, but the one the promo is made of.
        batch.insert(
          db.cards,
          CardsCompanion.insert(
            id: 'BT1-004_P1',
            number: 'BT1-004',
            name: 'BT1-004',
            category: 'digimon',
            imageUrl: 'https://example.test/BT1-004_P1.webp',
            isPrimary: const Value(false),
          ),
        );
        batch.insert(
          db.cardTraits,
          CardTraitsCompanion.insert(cardId: 'BT1-004_P1', trait: 'Beast'),
        );
        batch.insertAll(db.cardReleaseLinks, [
          for (final number in ['BT1-001', 'BT1-002', 'BT1-003'])
            CardReleaseLinksCompanion.insert(cardId: number, releaseId: 'bt-1'),
          CardReleaseLinksCompanion.insert(
            cardId: 'BT1-004_P1',
            releaseId: 'promo',
          ),
        ]);
      });
    });

    Future<Set<String>> inRelease(String releaseId, CardFilter filter) async {
      final cards = await db.cardDao.cardsInRelease(releaseId, filter: filter);
      return cards.map((card) => card.id).toSet();
    }

    test('narrows the set by the facets', () async {
      expect(await inRelease('bt-1', const CardFilter(traits: {'Dragon'})), {
        'BT1-001',
        'BT1-002',
      });
    });

    test('never reaches outside the set', () async {
      expect(
        await inRelease('bt-1', const CardFilter(traits: {'Beast'})),
        isEmpty,
      );
    });

    test('keeps a bundled alternate art the set is made of', () async {
      expect(await inRelease('promo', const CardFilter(traits: {'Beast'})), {
        'BT1-004_P1',
      });
    });
  });
}
