// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staple_dao.dart';

// ignore_for_file: type=lint
mixin _$StapleDaoMixin on DatabaseAccessor<AppDatabase> {
  $StapleListsTable get stapleLists => attachedDatabase.stapleLists;
  $StapleEntriesTable get stapleEntries => attachedDatabase.stapleEntries;
  $CardsTable get cards => attachedDatabase.cards;
  StapleDaoManager get managers => StapleDaoManager(this);
}

class StapleDaoManager {
  final _$StapleDaoMixin _db;
  StapleDaoManager(this._db);
  $$StapleListsTableTableManager get stapleLists =>
      $$StapleListsTableTableManager(_db.attachedDatabase, _db.stapleLists);
  $$StapleEntriesTableTableManager get stapleEntries =>
      $$StapleEntriesTableTableManager(_db.attachedDatabase, _db.stapleEntries);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db.attachedDatabase, _db.cards);
}
