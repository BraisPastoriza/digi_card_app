import 'dart:convert';

import 'package:digi_card_app/data/backup/backup_service.dart';
import 'package:digi_card_app/data/db/app_database.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppDatabase> _database() async {
  final db = AppDatabase.forTesting(NativeDatabase.memory());
  await db.customStatement('PRAGMA foreign_keys = ON');
  // A fresh database is seeded with the default staple lists; clearing them
  // keeps each test about the lists it makes itself.
  await db.delete(db.stapleLists).go();
  addTearDown(db.close);
  return db;
}

/// A deck with two revisions, the second one active, as a user would have it.
Future<void> _addDeck(AppDatabase db, String name) async {
  final when = DateTime.utc(2026, 9, 1, 12);
  final deckId = await db
      .into(db.decks)
      .insert(
        DecksCompanion.insert(
          name: name,
          description: const Value('Red aggro'),
          thumbnailCardNumber: const Value('BT1-010'),
          createdAt: when,
          updatedAt: when,
        ),
      );
  final first = await db
      .into(db.deckRevisions)
      .insert(
        DeckRevisionsCompanion.insert(
          deckId: deckId,
          name: 'v1',
          createdAt: when,
          updatedAt: when,
        ),
      );
  final second = await db
      .into(db.deckRevisions)
      .insert(
        DeckRevisionsCompanion.insert(
          deckId: deckId,
          name: 'v2',
          createdAt: when,
          updatedAt: when,
        ),
      );
  await db.batch((batch) {
    batch.insertAll(db.deckEntries, [
      DeckEntriesCompanion.insert(
        revisionId: first,
        cardNumber: 'BT1-010',
        quantity: 4,
      ),
      DeckEntriesCompanion.insert(
        revisionId: second,
        cardNumber: 'BT1-010',
        quantity: 3,
        printingId: const Value('BT1-010_P1'),
      ),
      DeckEntriesCompanion.insert(
        revisionId: second,
        cardNumber: 'BT1-085',
        quantity: 2,
      ),
    ]);
  });
  await (db.update(db.decks)..where((d) => d.id.equals(deckId))).write(
    DecksCompanion(activeRevisionId: Value(second)),
  );
}

Future<int> _addList(AppDatabase db, String name, List<String> cards) async {
  final when = DateTime.utc(2026, 9, 1);
  final id = await db
      .into(db.stapleLists)
      .insert(
        StapleListsCompanion.insert(
          name: name,
          createdAt: when,
          updatedAt: when,
        ),
      );
  await db.batch((batch) {
    batch.insertAll(db.stapleEntries, [
      for (final card in cards)
        StapleEntriesCompanion.insert(
          listId: id,
          cardNumber: card,
          addedAt: when,
        ),
    ]);
  });
  return id;
}

Future<Set<String>> _listCards(AppDatabase db, String name) async {
  final list = await (db.select(
    db.stapleLists,
  )..where((l) => l.name.equals(name))).getSingle();
  final entries = await (db.select(
    db.stapleEntries,
  )..where((e) => e.listId.equals(list.id))).get();
  return entries.map((e) => e.cardNumber).toSet();
}

void main() {
  test('a backup restores onto another device as it was', () async {
    final phone = await _database();
    await _addDeck(phone, 'Red Hybrid');
    await _addList(phone, 'Memory', ['BT6-097', 'BT1-085']);

    final file = await BackupService(phone).exportBytes();
    final tablet = await _database();
    final result = await BackupService(
      tablet,
    ).restore(BackupService.parse(file));

    expect(result.decksAdded, 1);
    expect(result.listsAdded, 1);

    final deck = await tablet.select(tablet.decks).getSingle();
    expect(deck.name, 'Red Hybrid');
    expect(deck.description, 'Red aggro');
    expect(deck.thumbnailCardNumber, 'BT1-010');
    expect(deck.createdAt.toUtc(), DateTime.utc(2026, 9, 1, 12));

    final revisions = await (tablet.select(
      tablet.deckRevisions,
    )..orderBy([(r) => OrderingTerm.asc(r.id)])).get();
    expect(revisions.map((r) => r.name), ['v1', 'v2']);
    expect(deck.activeRevisionId, revisions.last.id);

    final active = await (tablet.select(
      tablet.deckEntries,
    )..where((e) => e.revisionId.equals(revisions.last.id))).get();
    expect(
      {for (final e in active) e.cardNumber: (e.quantity, e.printingId)},
      {'BT1-010': (3, 'BT1-010_P1'), 'BT1-085': (2, null)},
    );

    expect(await _listCards(tablet, 'Memory'), {'BT6-097', 'BT1-085'});
  });

  test('restoring twice adds nothing the second time', () async {
    final db = await _database();
    await _addDeck(db, 'Red Hybrid');
    await _addList(db, 'Memory', ['BT6-097']);
    final backup = BackupService.parse(await BackupService(db).exportBytes());

    final result = await BackupService(db).restore(backup);

    expect(result.decksAdded, 0);
    expect(result.decksSkipped, 1);
    expect(result.listsAdded, 0);
    expect(result.listsMerged, 0);
    expect(await db.select(db.decks).get(), hasLength(1));
    expect(await db.select(db.stapleLists).get(), hasLength(1));
  });

  test(
    'keeps a deck changed since the backup as well as the old one',
    () async {
      final db = await _database();
      await _addDeck(db, 'Red Hybrid');
      final backup = BackupService.parse(await BackupService(db).exportBytes());
      await (db.update(db.deckEntries)
            ..where((e) => e.cardNumber.equals('BT1-085')))
          .write(const DeckEntriesCompanion(quantity: Value(4)));

      final result = await BackupService(db).restore(backup);

      expect(result.decksAdded, 1);
      expect(await db.select(db.decks).get(), hasLength(2));
    },
  );

  test('adds the missing cards to a staple list of the same name', () async {
    final db = await _database();
    await _addList(db, 'Memory', ['BT6-097', 'BT1-085']);
    final backup = BackupService.parse(await BackupService(db).exportBytes());
    await db.delete(db.stapleEntries).go();
    await (db.into(db.stapleEntries)).insert(
      StapleEntriesCompanion.insert(
        listId: (await db.select(db.stapleLists).getSingle()).id,
        cardNumber: 'EX1-068',
        addedAt: DateTime.now(),
      ),
    );

    final result = await BackupService(db).restore(backup);

    expect(result.listsMerged, 1);
    expect(await db.select(db.stapleLists).get(), hasLength(1));
    expect(await _listCards(db, 'Memory'), {'EX1-068', 'BT6-097', 'BT1-085'});
  });

  test('a deck the file lists twice comes back once', () async {
    final db = await _database();
    await _addDeck(db, 'Red Hybrid');
    final backup = BackupService.parse(await BackupService(db).exportBytes());
    final decks = backup['decks'] as List;
    backup['decks'] = [...decks, ...decks];

    final fresh = await _database();
    final result = await BackupService(fresh).restore(backup);

    expect(result.decksAdded, 1);
    expect(result.decksSkipped, 1);
  });

  group('reading a file', () {
    test('refuses something that is not JSON', () {
      expect(
        () => BackupService.parse(utf8.encode('PK\u0003\u0004 not json')),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.reason,
            'reason',
            BackupFormatProblem.notABackup,
          ),
        ),
      );
    });

    test('refuses JSON that is not a backup', () {
      expect(
        () => BackupService.parse(utf8.encode('{"decks": []}')),
        throwsA(isA<BackupFormatException>()),
      );
    });

    test('refuses a backup from a newer version of the app', () {
      expect(
        () => BackupService.parse(
          utf8.encode(
            jsonEncode({
              'format': BackupService.format,
              'version': BackupService.version + 1,
            }),
          ),
        ),
        throwsA(
          isA<BackupFormatException>().having(
            (e) => e.reason,
            'reason',
            BackupFormatProblem.tooNew,
          ),
        ),
      );
    });

    test('says what a backup holds before it is restored', () async {
      final db = await _database();
      await _addDeck(db, 'A');
      await _addDeck(db, 'B');
      await _addList(db, 'Memory', ['BT6-097']);

      final contents = BackupService.contentsOf(
        BackupService.parse(await BackupService(db).exportBytes()),
      );

      expect(contents.decks, 2);
      expect(contents.stapleLists, 1);
    });
  });
}
