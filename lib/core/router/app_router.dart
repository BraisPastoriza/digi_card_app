import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/deckbuilder/deck_card_picker_screen.dart';
import '../../features/deckbuilder/deck_export_screen.dart';
import '../../features/deckbuilder/deck_import_screen.dart';
import '../../features/deckbuilder/deck_screen.dart';
import '../../features/deckbuilder/decks_screen.dart';
import '../../features/deckbuilder/staple_card_picker_screen.dart';
import '../../features/deckbuilder/staple_import_screen.dart';
import '../../features/deckbuilder/staple_list_screen.dart';
import '../../features/deckbuilder/test_hand_screen.dart';
import '../../features/library/attribution_screen.dart';
import '../../features/library/card_detail_screen.dart';
import '../../features/library/library_screen.dart';
import '../../features/library/release_cards_screen.dart';
import '../../features/library/search_screen.dart';
import '../../features/sync/sync_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../providers.dart';

/// Router for the app.
///
/// Everything is gated behind [libraryReadyProvider]: until the card database
/// exists locally, the only reachable route is the sync screen.
final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<bool>(ref.read(libraryReadyProvider));
  ref.listen<bool>(
    libraryReadyProvider,
    (_, next) => refresh.value = next,
    fireImmediately: true,
  );
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/sync',
    refreshListenable: refresh,
    redirect: (context, state) {
      final ready = ref.read(libraryReadyProvider);
      final atSync = state.matchedLocation == '/sync';
      if (!ready) return atSync ? null : '/sync';
      return atSync ? '/library' : null;
    },
    routes: [
      GoRoute(path: '/sync', builder: (_, _) => const SyncScreen()),

      // Card detail sits outside the tab shell so it opens full-screen over
      // whichever tab the user came from.
      GoRoute(
        path: '/card/:number',
        builder: (_, state) =>
            CardDetailScreen(number: state.pathParameters['number']!),
      ),

      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (_, _) => const LibraryScreen(),
                routes: [
                  GoRoute(
                    path: 'search',
                    builder: (_, _) => const SearchScreen(),
                  ),
                  GoRoute(
                    path: 'credits',
                    builder: (_, _) => const AttributionScreen(),
                  ),
                  GoRoute(
                    path: 'release/:releaseId',
                    builder: (_, state) => ReleaseCardsScreen(
                      releaseId: state.pathParameters['releaseId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/decks',
                builder: (_, _) => const DecksScreen(),
                routes: [
                  // Ahead of `:deckId`, which would otherwise swallow them
                  // and then fail to parse "import" as a deck id.
                  GoRoute(
                    path: 'import',
                    builder: (_, _) => const DeckImportScreen(),
                  ),
                  // Ahead of `staples/:listId` for the same reason as
                  // `import` above: the id is parsed as a number.
                  GoRoute(
                    path: 'staples/import',
                    builder: (_, _) => const StapleImportScreen(),
                  ),
                  GoRoute(
                    path: 'staples/:listId',
                    builder: (_, state) => StapleListScreen(
                      listId: int.parse(state.pathParameters['listId']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'add',
                        builder: (_, state) => StapleCardPickerScreen(
                          listId: int.parse(state.pathParameters['listId']!),
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: ':deckId',
                    builder: (_, state) => DeckScreen(
                      deckId: int.parse(state.pathParameters['deckId']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'add/:revisionId',
                        builder: (_, state) => DeckCardPickerScreen(
                          deckId: int.parse(state.pathParameters['deckId']!),
                          revisionId: int.parse(
                            state.pathParameters['revisionId']!,
                          ),
                        ),
                      ),
                      GoRoute(
                        path: 'export/:revisionId',
                        builder: (_, state) => DeckExportScreen(
                          deckId: int.parse(state.pathParameters['deckId']!),
                          revisionId: int.parse(
                            state.pathParameters['revisionId']!,
                          ),
                        ),
                      ),
                      GoRoute(
                        path: 'hand/:revisionId',
                        builder: (_, state) => TestHandScreen(
                          deckId: int.parse(state.pathParameters['deckId']!),
                          revisionId: int.parse(
                            state.pathParameters['revisionId']!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
