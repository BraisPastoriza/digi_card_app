import 'package:drift/drift.dart';

import '../../../domain/models/card_enums.dart';
import '../../../domain/models/card_release.dart';
import '../app_database.dart';
import '../mappers.dart';
import '../tables.dart';

part 'release_dao.g.dart';

/// Releases grouped under one heading in the library.
class ReleaseSection {
  const ReleaseSection(this.group, this.releases);

  final ReleaseGroup group;
  final List<CardRelease> releases;

  /// Cards in the group, skipping the synthetic promo aggregate so its
  /// contents are not counted a second time on top of the products they came
  /// from.
  int get cardCount => releases
      .where((r) => r.id != allPromosReleaseId)
      .fold(0, (sum, r) => sum + r.cardCount);
}

@DriftAccessor(tables: [Releases])
class ReleaseDao extends DatabaseAccessor<AppDatabase> with _$ReleaseDaoMixin {
  ReleaseDao(super.db);

  /// Newest first. Preview sets all share one sort index, past every published
  /// release, so the id breaks the tie: BT-27 above BT-26.
  static List<OrderClauseGenerator<$ReleasesTable>> get _newestFirst => [
    (r) => OrderingTerm.desc(r.sortIndex),
    (r) => OrderingTerm.desc(r.id),
  ];

  /// Every release, newest first within each group.
  Future<List<CardRelease>> allReleases() async {
    final query = select(releases)..orderBy(_newestFirst);
    final rows = await query.get();
    return rows.map((row) => row.toCardRelease()).toList();
  }

  /// Releases bucketed into the library's sections, in the order the sections
  /// are listed.
  Future<List<ReleaseSection>> sections() async {
    final all = await allReleases();
    return [
      for (final group in ReleaseGroup.values)
        if (all.any((r) => r.group == group))
          ReleaseSection(group, all.where((r) => r.group == group).toList()),
    ];
  }

  Future<CardRelease?> releaseById(String id) async {
    final row = await (select(
      releases,
    )..where((r) => r.id.equals(id))).getSingleOrNull();
    return row?.toCardRelease();
  }

  Stream<List<CardRelease>> watchAllReleases() {
    final query = select(releases)..orderBy(_newestFirst);
    return query.watch().map(
      (rows) => rows.map((row) => row.toCardRelease()).toList(),
    );
  }
}
