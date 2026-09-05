import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/heroi_api.dart';
import '../data/db/app_database.dart';
import '../data/db/daos/card_dao.dart';
import '../data/db/daos/deck_dao.dart';
import '../data/db/daos/release_dao.dart';
import '../data/sync/card_sync_service.dart';

/// The single database connection for the app's lifetime.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final heroiApiProvider = Provider<HeroiApi>((ref) => HeroiApi());

final cardDaoProvider = Provider<CardDao>(
  (ref) => ref.watch(appDatabaseProvider).cardDao,
);

final releaseDaoProvider = Provider<ReleaseDao>(
  (ref) => ref.watch(appDatabaseProvider).releaseDao,
);

final deckDaoProvider = Provider<DeckDao>(
  (ref) => ref.watch(appDatabaseProvider).deckDao,
);

final cardSyncServiceProvider = Provider<CardSyncService>(
  (ref) => CardSyncService(
    ref.watch(appDatabaseProvider),
    ref.watch(heroiApiProvider),
  ),
);

/// Whether the local card database has been populated.
///
/// The router keeps the user on the sync screen until this flips to true, so
/// no screen ever has to cope with an empty library.
class LibraryReadyNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void markReady() => state = true;

  /// Sends the app back to the sync screen. Pair it with
  /// [resyncRequestedProvider] so the sync screen runs an update check instead
  /// of immediately handing back the cards it already has.
  void requireSync() => state = false;
}

/// Set when the user asks to check for card updates, which tells the sync
/// screen to contact the API rather than take the local cards as good enough.
final resyncRequestedProvider = StateProvider<bool>((ref) => false);

final libraryReadyProvider = NotifierProvider<LibraryReadyNotifier, bool>(
  LibraryReadyNotifier.new,
);

/// Last completed sync, shown in settings and used to offer a refresh.
final syncStateProvider = FutureProvider((ref) {
  // Re-read whenever a sync finishes.
  ref.watch(libraryReadyProvider);
  return ref.watch(cardSyncServiceProvider).currentState();
});
