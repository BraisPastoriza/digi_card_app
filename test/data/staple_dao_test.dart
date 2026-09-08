import 'package:digi_card_app/data/db/app_database.dart';
import 'package:digi_card_app/data/db/default_staples.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    // Two printings of one number, so resolution has to pick the primary one.
    await db.batch((batch) {
      batch.insertAll(db.cards, [
        CardsCompanion.insert(
          id: 'BT6-097',
          number: 'BT6-097',
          name: 'Howling Memory Boost!',
          category: 'option',
          imageUrl: 'https://example.test/BT6-097.webp',
          numberSort: const Value('BT06-097-0'),
        ),
        CardsCompanion.insert(
          id: 'BT6-097_P1',
          number: 'BT6-097',
          name: 'Howling Memory Boost!',
          category: 'option',
          imageUrl: 'https://example.test/BT6-097_P1.webp',
          parallelId: const Value(1),
          isPrimary: const Value(false),
          numberSort: const Value('BT06-097-1'),
        ),
        CardsCompanion.insert(
          id: 'BT1-085',
          number: 'BT1-085',
          name: 'Tai Kamiya',
          category: 'tamer',
          imageUrl: 'https://example.test/BT1-085.webp',
          numberSort: const Value('BT01-085-0'),
        ),
      ]);
    });
  });

  tearDown(() => db.close());

  group('seeded lists', () {
    test('a new database starts with the default lists', () async {
      final lists = await db.stapleDao.lists();

      expect(
        lists.map((l) => l.name),
        defaultStapleLists.map((s) => s.name),
        reason: 'seeded in the order they are declared',
      );
      expect(
        lists.map((l) => l.count),
        defaultStapleLists.map((s) => s.cardNumbers.length),
      );
    });

    test('a list keeps its cards while the library lacks them', () async {
      // Only three printings are in this database, so almost every seeded
      // number resolves to nothing — the list must still report what it holds
      // rather than shrinking to what happens to be synced.
      final boosts = (await db.stapleDao.lists()).firstWhere(
        (l) => l.name == 'Memory Boosts',
      );

      expect(boosts.count, greaterThan(boosts.cards.length));
      expect(boosts.cards.map((c) => c.number), ['BT6-097']);
      expect(
        boosts.cards.single.id,
        'BT6-097',
        reason: 'the primary printing, not the alternate art',
      );
    });
  });

  group('editing', () {
    test('creates, renames and deletes a list', () async {
      final id = await db.stapleDao.createList(name: 'Blue package');
      expect(
        (await db.stapleDao.lists()).map((l) => l.name),
        contains('Blue package'),
      );

      await db.stapleDao.renameList(id, 'Blue tech');
      final renamed = (await db.stapleDao.lists()).firstWhere(
        (l) => l.id == id,
      );
      expect(renamed.name, 'Blue tech');

      await db.stapleDao.deleteList(id);
      expect(
        (await db.stapleDao.lists()).map((l) => l.id),
        isNot(contains(id)),
      );
    });

    test('a new list sorts after the ones already there', () async {
      final id = await db.stapleDao.createList(name: 'Last');

      expect((await db.stapleDao.lists()).last.id, id);
    });

    test('names an unnamed list past the ones already called that', () async {
      await db.stapleDao.createList();
      await db.stapleDao.createList();

      expect(
        (await db.stapleDao.lists()).map((l) => l.name),
        containsAll(['New list', 'New list 2']),
      );
    });

    test('adding a card twice leaves one copy', () async {
      final id = await db.stapleDao.createList(name: 'Tamers');

      await db.stapleDao.addCards(id, ['BT1-085', 'BT1-085', 'BT6-097']);

      final list = (await db.stapleDao.lists()).firstWhere((l) => l.id == id);
      expect(list.cardNumbers, ['BT1-085', 'BT6-097']);
      expect(list.count, 2);
    });

    test('toggling adds a card and then takes it out', () async {
      final id = await db.stapleDao.createList(name: 'Scratch');

      expect(await db.stapleDao.toggleCard(id, 'BT1-085'), isTrue);
      expect(
        (await db.stapleDao.lists()).firstWhere((l) => l.id == id).cardNumbers,
        ['BT1-085'],
      );

      expect(await db.stapleDao.toggleCard(id, 'BT1-085'), isFalse);
      expect(
        (await db.stapleDao.lists()).firstWhere((l) => l.id == id).isEmpty,
        isTrue,
      );
    });

    test('deleting a list takes its cards with it', () async {
      final id = await db.stapleDao.createList(name: 'Scratch');
      await db.stapleDao.addCards(id, ['BT1-085']);

      await db.stapleDao.deleteList(id);

      final left = await db.select(db.stapleEntries).get();
      expect(left.where((e) => e.listId == id), isEmpty);
    });

    test('an empty list still comes back from the query', () async {
      final id = await db.stapleDao.createList(name: 'Empty');

      final list = (await db.stapleDao.lists()).firstWhere((l) => l.id == id);
      expect(list.isEmpty, isTrue);
      expect(list.cards, isEmpty);
    });
  });

  test('cards are ordered by printed number', () async {
    final id = await db.stapleDao.createList(name: 'Ordered');
    await db.stapleDao.addCards(id, ['BT6-097', 'BT1-085']);

    final list = (await db.stapleDao.lists()).firstWhere((l) => l.id == id);
    expect(list.cards.map((c) => c.number), ['BT1-085', 'BT6-097']);
  });
}
