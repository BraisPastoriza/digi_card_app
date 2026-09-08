import 'package:digi_card_app/data/db/app_database.dart';
import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/digimon_card.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

DigimonCard _card(String number) => DigimonCard(
  id: number,
  number: number,
  parallelId: 0,
  name: number,
  category: CardCategory.digimon,
  colors: const [CardColor.red],
  imageUrl: 'https://example.test/$number.webp',
);

void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    await db
        .into(db.cards)
        .insert(
          CardsCompanion.insert(
            id: 'BT1-001',
            number: 'BT1-001',
            name: 'Agumon',
            category: 'digimon',
            imageUrl: 'https://example.test/BT1-001.webp',
          ),
        );
  });

  tearDown(() => db.close());

  Future<bool> deckExists(int deckId) async {
    final row = await (db.select(
      db.decks,
    )..where((d) => d.id.equals(deckId))).getSingleOrNull();
    return row != null;
  }

  group('discardIfEmpty', () {
    test('throws away a deck that was never filled in', () async {
      final deckId = await db.deckDao.createDeck(name: 'Scratch');

      expect(await db.deckDao.discardIfEmpty(deckId), isTrue);
      expect(await deckExists(deckId), isFalse);
    });

    test('keeps a deck with a card in it', () async {
      final deckId = await db.deckDao.createDeck(name: 'Real');
      final revisionId = (await db.deckDao.activeRevisionIdOf(deckId))!;
      await db.deckDao.adjustQuantity(
        revisionId: revisionId,
        card: _card('BT1-001'),
        delta: 1,
      );

      expect(await db.deckDao.discardIfEmpty(deckId), isFalse);
      expect(await deckExists(deckId), isTrue);
    });

    test('keeps a deck whose cards are on another revision', () async {
      // The revision being edited can be empty while the deck is not: that is
      // what branching a revision to try something is for.
      final deckId = await db.deckDao.createDeck(name: 'Branched');
      final first = (await db.deckDao.activeRevisionIdOf(deckId))!;
      await db.deckDao.adjustQuantity(
        revisionId: first,
        card: _card('BT1-001'),
        delta: 1,
      );
      final empty = await db.deckDao.createRevisionFrom(
        deckId: deckId,
        sourceRevisionId: first,
        name: 'v2',
      );
      await db.deckDao.clearRevision(empty);

      expect(await db.deckDao.discardIfEmpty(deckId), isFalse);
      expect(await deckExists(deckId), isTrue);
    });

    test('throws away a deck emptied of its last card', () async {
      // The rule is about what the deck holds, not how it got there.
      final deckId = await db.deckDao.createDeck(name: 'Emptied');
      final revisionId = (await db.deckDao.activeRevisionIdOf(deckId))!;
      await db.deckDao.adjustQuantity(
        revisionId: revisionId,
        card: _card('BT1-001'),
        delta: 1,
      );
      await db.deckDao.clearRevision(revisionId);

      expect(await db.deckDao.discardIfEmpty(deckId), isTrue);
      expect(await deckExists(deckId), isFalse);
    });

    test('is safe to call on a deck that is already gone', () async {
      // The editor tidies up as it closes, and the deck may have been deleted
      // from the menu a moment earlier.
      final deckId = await db.deckDao.createDeck(name: 'Deleted');
      await db.deckDao.deleteDeck(deckId);

      expect(await db.deckDao.discardIfEmpty(deckId), isTrue);
    });
  });
}
