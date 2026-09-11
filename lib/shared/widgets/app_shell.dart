import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/navigation.dart';
import '../../l10n/l10n.dart';

/// Bottom-navigation shell holding the two top-level sections.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // The app handles back itself, and Android has to be told so.
      //
      // Left to the framework, the platform is told whether the *root*
      // navigator can pop — and the root holds exactly one page, this shell,
      // however deep the branch the user is looking at happens to be. So a
      // back press on a deck could be answered by Android closing the app
      // instead of going back, which is what a user reported: gone from the
      // deck they were reading, with the app's own idea of where they were
      // left pointing at a page no longer on screen.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final router = GoRouter.of(context);
        if (router.canPop()) {
          router.pop();
          return;
        }
        // A page pushed a moment ago is in the router but not yet in the
        // navigator, so `canPop` says no while a page really is opening.
        // Swallowing the back there costs one press; answering it by closing
        // the app costs the user their place.
        if (isPushSettling) return;
        // Nothing left in this branch: back out of the app, which is what
        // back at the root of a tab means on Android.
        SystemNavigator.pop();
      },
      child: Scaffold(
        body: shell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: shell.currentIndex,
          // Tapping the active tab pops back to its root, which is what the
          // gesture means everywhere else.
          onDestinationSelected: (index) => shell.goBranch(
            index,
            initialLocation: index == shell.currentIndex,
          ),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.grid_view_outlined),
              selectedIcon: const Icon(Icons.grid_view_rounded),
              label: context.l10n.navLibrary,
            ),
            NavigationDestination(
              icon: const Icon(Icons.layers_outlined),
              selectedIcon: const Icon(Icons.layers_rounded),
              label: context.l10n.navDecks,
            ),
          ],
        ),
      ),
    );
  }
}
