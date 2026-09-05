import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../domain/models/deck.dart';
import '../../shared/widgets/common.dart';
import 'deck_providers.dart';
import 'widgets/deck_cards_tab.dart';
import 'widgets/deck_name_dialog.dart';
import 'widgets/deck_revisions_tab.dart';
import 'widgets/deck_stats_tab.dart';

/// The deck editor: the active revision's cards, the revision history, and the
/// deck's statistics.
class DeckScreen extends ConsumerWidget {
  const DeckScreen({super.key, required this.deckId});

  final int deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deck = ref.watch(deckProvider(deckId));

    return deck.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load deck',
          message: '$error',
        ),
      ),
      data: (deck) {
        if (deck == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const EmptyState(
              icon: Icons.layers_clear_outlined,
              title: 'Deck not found',
              message: 'It may have been deleted.',
            ),
          );
        }
        return _DeckView(deck: deck);
      },
    );
  }
}

class _DeckView extends ConsumerWidget {
  const _DeckView({required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final revision = deck.activeRevision;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.go('/decks'),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(deck.name, overflow: TextOverflow.ellipsis),
              if (revision != null)
                Text(
                  'Editing ${revision.name}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          actions: [
            PopupMenuButton<String>(
              onSelected: (action) => _handle(context, ref, action),
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'rename', child: Text('Rename deck')),
                if (revision != null)
                  PopupMenuItem(
                    value: 'clear',
                    child: Text('Clear ${revision.name}'),
                  ),
                PopupMenuItem(
                  value: 'delete',
                  child: Text(
                    'Delete deck',
                    style: TextStyle(color: scheme.error),
                  ),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Cards'),
              Tab(text: 'Revisions (${deck.revisions.length})'),
              const Tab(text: 'Stats'),
            ],
          ),
        ),
        floatingActionButton: revision == null
            ? null
            : FloatingActionButton.extended(
                onPressed: () => _openPicker(context, revision.id),
                icon: const Icon(Icons.add),
                label: const Text('Add cards'),
              ),
        body: revision == null
            ? const EmptyState(
                icon: Icons.history_toggle_off,
                title: 'This deck has no revisions',
                message: 'Create one to start adding cards.',
              )
            : TabBarView(
                children: [
                  DeckCardsTab(
                    revisionId: revision.id,
                    onAddCards: () => _openPicker(context, revision.id),
                  ),
                  DeckRevisionsTab(deck: deck),
                  DeckStatsTab(revisionId: revision.id),
                ],
              ),
      ),
    );
  }

  void _openPicker(BuildContext context, int revisionId) {
    context.push('/decks/${deck.id}/add/$revisionId');
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final dao = ref.read(deckDaoProvider);
    switch (action) {
      case 'rename':
        final name = await showDeckNameDialog(
          context,
          title: 'Rename deck',
          label: 'Deck name',
          initialValue: deck.name,
        );
        if (name != null) await dao.updateDeck(deck.id, name: name);
      case 'clear':
        final revisionId = deck.activeRevision?.id;
        if (revisionId == null || !context.mounted) return;
        final confirmed = await _confirm(
          context,
          title: 'Clear ${deck.activeRevision!.name}?',
          message: 'Removes every card from this revision. Other revisions '
              'keep their cards.',
          confirmLabel: 'Clear',
        );
        if (confirmed) await dao.clearRevision(revisionId);
      case 'delete':
        if (!context.mounted) return;
        final confirmed = await _confirm(
          context,
          title: 'Delete ${deck.name}?',
          message: 'The deck and all ${deck.revisions.length} of its '
              'revisions are removed. This cannot be undone.',
          confirmLabel: 'Delete',
        );
        if (confirmed) {
          await dao.deleteDeck(deck.id);
          if (context.mounted) context.go('/decks');
        }
    }
  }

  Future<bool> _confirm(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
