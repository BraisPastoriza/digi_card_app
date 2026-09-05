// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_dao.dart';

// ignore_for_file: type=lint
mixin _$CardDaoMixin on DatabaseAccessor<AppDatabase> {
  $CardsTable get cards => attachedDatabase.cards;
  $CardTraitsTable get cardTraits => attachedDatabase.cardTraits;
  $CardKeywordsTable get cardKeywords => attachedDatabase.cardKeywords;
  $CardReleaseLinksTable get cardReleaseLinks =>
      attachedDatabase.cardReleaseLinks;
  $SyncStateTable get syncState => attachedDatabase.syncState;
  CardDaoManager get managers => CardDaoManager(this);
}

class CardDaoManager {
  final _$CardDaoMixin _db;
  CardDaoManager(this._db);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db.attachedDatabase, _db.cards);
  $$CardTraitsTableTableManager get cardTraits =>
      $$CardTraitsTableTableManager(_db.attachedDatabase, _db.cardTraits);
  $$CardKeywordsTableTableManager get cardKeywords =>
      $$CardKeywordsTableTableManager(_db.attachedDatabase, _db.cardKeywords);
  $$CardReleaseLinksTableTableManager get cardReleaseLinks =>
      $$CardReleaseLinksTableTableManager(
        _db.attachedDatabase,
        _db.cardReleaseLinks,
      );
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db.attachedDatabase, _db.syncState);
}
