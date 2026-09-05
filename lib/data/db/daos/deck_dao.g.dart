// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_dao.dart';

// ignore_for_file: type=lint
mixin _$DeckDaoMixin on DatabaseAccessor<AppDatabase> {
  $DecksTable get decks => attachedDatabase.decks;
  $DeckRevisionsTable get deckRevisions => attachedDatabase.deckRevisions;
  $DeckEntriesTable get deckEntries => attachedDatabase.deckEntries;
  $CardsTable get cards => attachedDatabase.cards;
  DeckDaoManager get managers => DeckDaoManager(this);
}

class DeckDaoManager {
  final _$DeckDaoMixin _db;
  DeckDaoManager(this._db);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db.attachedDatabase, _db.decks);
  $$DeckRevisionsTableTableManager get deckRevisions =>
      $$DeckRevisionsTableTableManager(_db.attachedDatabase, _db.deckRevisions);
  $$DeckEntriesTableTableManager get deckEntries =>
      $$DeckEntriesTableTableManager(_db.attachedDatabase, _db.deckEntries);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db.attachedDatabase, _db.cards);
}
