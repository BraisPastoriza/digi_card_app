import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/api/digimoncard_io_api.dart';
import '../data/api/heroi_api.dart';
import '../data/db/app_database.dart';
import '../data/db/daos/card_dao.dart';
import '../data/db/daos/deck_dao.dart';
import '../data/db/daos/release_dao.dart';
import '../data/db/daos/staple_dao.dart';
import '../data/sync/card_sync_service.dart';
import '../domain/models/pair_restrictions.dart';

/// The single database connection for the app's lifetime.
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

final heroiApiProvider = Provider<HeroiApi>((ref) => HeroiApi());

/// Secondary card source, used only for the sets the primary API has not
/// published yet.
final digimonCardIoApiProvider = Provider<DigimonCardIoApi>(
  (ref) => DigimonCardIoApi(),
);

final cardDaoProvider = Provider<CardDao>(
  (ref) => ref.watch(appDatabaseProvider).cardDao,
);

/// Which cards may not share a deck, readable from either side of a pairing.
///
/// Kept whole rather than looked up per card: there are only a few pairings in
/// the game, and the card being asked about is as often the one the ruling was
/// not written on.
final pairRestrictionsProvider = FutureProvider<PairRestrictions>((ref) async {
  final dao = ref.watch(cardDaoProvider);
  final carriers = await dao.pairRestrictedCards();
  if (carriers.isEmpty) return const PairRestrictions.empty();

  final numbers = {
    for (final card in carriers) ...[card.number, ...card.bannedWith],
  };
  final named = await dao.cardsByNumbers(numbers);
  return PairRestrictions.from(
    carriers,
    namesByNumber: {
      for (final entry in named.entries) entry.key: entry.value.name,
    },
  );
});

final releaseDaoProvider = Provider<ReleaseDao>(
  (ref) => ref.watch(appDatabaseProvider).releaseDao,
);

final deckDaoProvider = Provider<DeckDao>(
  (ref) => ref.watch(appDatabaseProvider).deckDao,
);

final stapleDaoProvider = Provider<StapleDao>(
  (ref) => ref.watch(appDatabaseProvider).stapleDao,
);

final cardSyncServiceProvider = Provider<CardSyncService>(
  (ref) => CardSyncService(
    ref.watch(appDatabaseProvider),
    ref.watch(heroiApiProvider),
    ref.watch(digimonCardIoApiProvider),
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
