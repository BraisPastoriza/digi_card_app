import 'package:drift/drift.dart';

import '../../../domain/models/staple_list.dart';
import '../app_database.dart';
import '../mappers.dart';
import '../tables.dart';

part 'staple_dao.g.dart';

@DriftAccessor(tables: [StapleLists, StapleEntries, Cards])
class StapleDao extends DatabaseAccessor<AppDatabase> with _$StapleDaoMixin {
  StapleDao(super.db);

  /// Every list with its cards resolved against the library.
  ///
  /// One joined query rather than a query per list: the whole point of the
  /// feature is a handful of small lists read together, and a single watch
  /// updates them all when a card is added, a list renamed, or the card table
  /// rebuilt by a sync.
  Stream<List<StapleList>> watchLists() => _listsQuery().watch().map(_group);

  Future<List<StapleList>> lists() async => _group(await _listsQuery().get());

  /// Name a list gets when the user does not supply one, numbered past the
  /// lists already called that.
  static const defaultListName = 'New list';

  Future<String> nextDefaultListName() async {
    final taken = (await select(stapleLists).get()).map((l) => l.name).toSet();
    if (!taken.contains(defaultListName)) return defaultListName;
    for (var suffix = 2; ; suffix++) {
      final candidate = '$defaultListName $suffix';
      if (!taken.contains(candidate)) return candidate;
    }
  }

  /// Creates an empty list, placed after the ones already there.
  Future<int> createList({String? name}) async {
    final listName = name ?? await nextDefaultListName();
    final now = DateTime.now();
    final last = await (selectOnly(
      stapleLists,
    )..addColumns([stapleLists.sortIndex.max()])).getSingle();
    return into(stapleLists).insert(
      StapleListsCompanion.insert(
        name: listName,
        sortIndex: Value((last.read(stapleLists.sortIndex.max()) ?? -1) + 1),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<void> renameList(int listId, String name) async {
    await (update(stapleLists)..where((l) => l.id.equals(listId))).write(
      StapleListsCompanion(name: Value(name), updatedAt: Value(DateTime.now())),
    );
  }

  /// Removes a list and, by cascade, its cards.
  Future<void> deleteList(int listId) async {
    await (delete(stapleLists)..where((l) => l.id.equals(listId))).go();
  }

  Future<void> addCards(int listId, Iterable<String> cardNumbers) async {
    final now = DateTime.now();
    await batch((batch) {
      batch.insertAll(stapleEntries, [
        for (final number in cardNumbers)
          StapleEntriesCompanion.insert(
            listId: listId,
            cardNumber: number,
            addedAt: now,
          ),
      ], mode: InsertMode.insertOrIgnore);
    });
    await _touch(listId);
  }

  Future<void> removeCard(int listId, String cardNumber) async {
    await (delete(stapleEntries)..where(
          (e) => e.listId.equals(listId) & e.cardNumber.equals(cardNumber),
        ))
        .go();
    await _touch(listId);
  }

  /// Adds the card if the list does not have it and removes it if it does.
  /// Returns whether the list holds it afterwards, so the caller can say what
  /// just happened.
  Future<bool> toggleCard(int listId, String cardNumber) async {
    final existing =
        await (select(stapleEntries)..where(
              (e) => e.listId.equals(listId) & e.cardNumber.equals(cardNumber),
            ))
            .getSingleOrNull();
    if (existing == null) {
      await addCards(listId, [cardNumber]);
      return true;
    }
    await removeCard(listId, cardNumber);
    return false;
  }

  /// Seeds the lists a fresh install starts with.
  ///
  /// Called from the migration rather than at launch, so deleting a seeded
  /// list is final.
  Future<void> seed(Iterable<({String name, List<String> cardNumbers})> seeds) {
    final now = DateTime.now();
    return transaction(() async {
      var sortIndex = 0;
      for (final seed in seeds) {
        final listId = await into(stapleLists).insert(
          StapleListsCompanion.insert(
            name: seed.name,
            sortIndex: Value(sortIndex++),
            createdAt: now,
            updatedAt: now,
          ),
        );
        await batch((batch) {
          batch.insertAll(stapleEntries, [
            for (final number in seed.cardNumbers)
              StapleEntriesCompanion.insert(
                listId: listId,
                cardNumber: number,
                addedAt: now,
              ),
          ], mode: InsertMode.insertOrIgnore);
        });
      }
    });
  }

  Future<void> _touch(int listId) async {
    await (update(stapleLists)..where((l) => l.id.equals(listId))).write(
      StapleListsCompanion(updatedAt: Value(DateTime.now())),
    );
  }

  /// Lists left-joined to their cards, so a list with nothing in it still
  /// comes back — as one row with no card attached.
  JoinedSelectStatement<HasResultSet, dynamic> _listsQuery() =>
      select(stapleLists).join([
        leftOuterJoin(
          stapleEntries,
          stapleEntries.listId.equalsExp(stapleLists.id),
        ),
        leftOuterJoin(
          cards,
          cards.number.equalsExp(stapleEntries.cardNumber) &
              cards.isPrimary.equals(true),
        ),
      ])..orderBy([
        OrderingTerm.asc(stapleLists.sortIndex),
        OrderingTerm.asc(stapleLists.id),
        OrderingTerm.asc(cards.numberSort),
      ]);

  List<StapleList> _group(List<TypedResult> rows) {
    final byId = <int, StapleListRow>{};
    final numbers = <int, List<String>>{};
    final resolved = <int, List<CardRow>>{};

    for (final row in rows) {
      final list = row.readTable(stapleLists);
      byId[list.id] = list;
      final number = row.read(stapleEntries.cardNumber);
      if (number == null) continue;
      numbers.putIfAbsent(list.id, () => []).add(number);
      final card = row.readTableOrNull(cards);
      if (card != null) resolved.putIfAbsent(list.id, () => []).add(card);
    }

    return [
      for (final list in byId.values)
        StapleList(
          id: list.id,
          name: list.name,
          sortIndex: list.sortIndex,
          cardNumbers: numbers[list.id] ?? const [],
          cards: [
            for (final card in resolved[list.id] ?? const <CardRow>[])
              card.toDigimonCard(),
          ],
        ),
    ];
  }
}
