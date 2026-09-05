import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom-navigation shell holding the two top-level sections.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        // Tapping the active tab pops back to its root, which is what the
        // gesture means everywhere else.
        onDestinationSelected: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.grid_view_outlined),
            selectedIcon: Icon(Icons.grid_view_rounded),
            label: 'Library',
          ),
          NavigationDestination(
            icon: Icon(Icons.layers_outlined),
            selectedIcon: Icon(Icons.layers_rounded),
            label: 'Decks',
          ),
        ],
      ),
    );
  }
}
