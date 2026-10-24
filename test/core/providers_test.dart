import 'package:digi_card_app/core/providers.dart';
import 'package:digi_card_app/data/db/app_database.dart';
import 'package:digi_card_app/features/library/library_providers.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('what the library has read is read again after a sync', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(() async {
      container.dispose();
      await db.close();
    });
    final ready = container.read(libraryReadyProvider.notifier);

    ready.markReady();
    container.listen(releaseProvider('bt-27'), (_, _) {});
    expect(await container.read(releaseProvider('bt-27').future), isNull);

    // What a sync does: the library goes away, the data is replaced, and the
    // library comes back.
    ready.requireSync();
    await db
        .into(db.releases)
        .insert(
          ReleasesCompanion.insert(
            id: 'bt-27',
            name: 'IGNITION OF X [BT-27]',
            groupName: 'booster',
          ),
        );
    ready.markReady();

    expect(await container.read(releaseProvider('bt-27').future), isNotNull);
  });
}
