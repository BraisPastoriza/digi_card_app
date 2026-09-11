import 'package:digi_card_app/core/providers.dart';
import 'package:digi_card_app/data/db/app_database.dart';
import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/digimon_card.dart';
import 'package:digi_card_app/features/deckbuilder/widgets/add_to_staple_sheet.dart';
import 'package:digi_card_app/l10n/l10n.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _card = DigimonCard(
  id: 'BT6-097',
  number: 'BT6-097',
  parallelId: 0,
  name: 'Howling Memory Boost!',
  category: CardCategory.option,
  colors: [CardColor.red],
  imageUrl: 'https://example.invalid/BT6-097.webp',
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
            id: _card.id,
            number: _card.number,
            name: _card.name,
            category: 'option',
            imageUrl: _card.imageUrl,
            numberSort: const Value('BT06-097-0'),
          ),
        );
    // A new database comes with the built-in lists already in it; these tests
    // are about what the sheet does with the lists it is given.
    for (final list in await db.stapleDao.lists()) {
      await db.stapleDao.deleteList(list.id);
    }
  });

  tearDown(() => db.close());

  Future<void> pumpSheet(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showAddToStapleSheet(context, _card),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  /// Tears the tree down while the test is still running, so the database's
  /// stream queries finish closing before the framework checks for stray
  /// timers. After the test body is too late.
  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    // Advancing the clock, not just drawing a frame: the timer drift leaves
    // behind is a zero-duration one and only fires when time moves.
    await tester.pump(const Duration(milliseconds: 1));
  }

  Future<List<String>> cardsIn(int listId) async {
    final rows = await (db.select(
      db.stapleEntries,
    )..where((e) => e.listId.equals(listId))).get();
    return rows.map((row) => row.cardNumber).toList();
  }

  testWidgets('a tap puts the card on the list, another takes it off', (
    tester,
  ) async {
    final listId = await db.stapleDao.createList(name: 'Blue tech');
    await pumpSheet(tester);

    expect(find.text('Blue tech'), findsOneWidget);

    await tester.tap(find.text('Blue tech'));
    await tester.pumpAndSettle();
    expect(await cardsIn(listId), [_card.number]);

    // The sheet stays open: a card that belongs on one list often belongs on
    // another, and this is also how a card comes back off.
    expect(find.text('Blue tech'), findsOneWidget);

    await tester.tap(find.text('Blue tech'));
    await tester.pumpAndSettle();
    expect(await cardsIn(listId), isEmpty);

    await close(tester);
  });

  testWidgets('a list that already holds the card says so', (tester) async {
    final listId = await db.stapleDao.createList(name: 'Blue tech');
    await db.stapleDao.addCards(listId, [_card.number]);

    await pumpSheet(tester);

    expect(find.byIcon(Icons.check_circle), findsOneWidget);
    expect(find.byIcon(Icons.add_circle_outline), findsNothing);

    await close(tester);
  });

  testWidgets('with no lists at all it offers to start one', (tester) async {
    await pumpSheet(tester);

    expect(find.text('No staple lists'), findsOneWidget);
    expect(find.text('Create a list'), findsOneWidget);

    await close(tester);
  });

  testWidgets('a new list is named and starts with the card in it', (
    tester,
  ) async {
    await pumpSheet(tester);

    await tester.tap(find.text('Create a list'));
    await tester.pumpAndSettle();
    expect(find.text('New staple list'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Floodgates');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final lists = await db.stapleDao.lists();
    expect(lists.single.name, 'Floodgates');
    expect(await cardsIn(lists.single.id), [_card.number]);

    await close(tester);
  });
}
