// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'release_dao.dart';

// ignore_for_file: type=lint
mixin _$ReleaseDaoMixin on DatabaseAccessor<AppDatabase> {
  $ReleasesTable get releases => attachedDatabase.releases;
  ReleaseDaoManager get managers => ReleaseDaoManager(this);
}

class ReleaseDaoManager {
  final _$ReleaseDaoMixin _db;
  ReleaseDaoManager(this._db);
  $$ReleasesTableTableManager get releases =>
      $$ReleasesTableTableManager(_db.attachedDatabase, _db.releases);
}
