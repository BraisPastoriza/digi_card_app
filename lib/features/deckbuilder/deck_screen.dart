import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router/navigation.dart';
import '../../domain/models/card_filter.dart';
import '../../domain/models/deck.dart';
import '../../shared/widgets/common.dart';
import '../library/library_providers.dart';
import 'deck_providers.dart';
import 'decks_screen.dart';
import 'widgets/deck_cards_tab.dart';
import 'widgets/deck_name_dialog.dart';
import 'widgets/deck_revisions_tab.dart';
import 'widgets/deck_stats_tab.dart';
import 'widgets/staple_source_sheet.dart';
import 'widgets/deck_thumbnail_sheet.dart';

/// The deck editor: the active revision's cards, the revision history, and the
/// deck's statistics.
class DeckScreen extends ConsumerWidget {
  const DeckScreen({super.key, required this.deckId});

  final int deckId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deck = ref.watch(deckProvider(deckId));

    return deck.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
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

class _DeckView extends ConsumerStatefulWidget {
  const _DeckView({required this.deck});

  final Deck deck;

  @override
  ConsumerState<_DeckView> createState() => _DeckViewState();
}

class _DeckViewState extends ConsumerState<_DeckView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 3, vsync: this)
    ..addListener(() {
      // Rebuild so the add-cards button can hide on the tabs it does not
      // belong to, where it otherwise floats over the charts.
      if (!_tabs.indexIsChanging) setState(() {});
    });

  Deck get deck => widget.deck;

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final revision = deck.activeRevision;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.goBack('/decks'),
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
            onSelected: (action) => _handle(context, action),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rename', child: Text('Rename deck')),
              if (revision != null) ...[
                const PopupMenuItem(
                  value: 'thumbnail',
                  child: Text('Deck thumbnail'),
                ),
                const PopupMenuItem(value: 'hand', child: Text('Test hand')),
                const PopupMenuItem(value: 'export', child: Text('Export')),
                PopupMenuItem(
                  value: 'clear',
                  child: Text('Clear ${revision.name}'),
                ),
              ],
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
          controller: _tabs,
          tabs: [
            const Tab(text: 'Cards'),
            Tab(text: 'Revisions (${deck.revisions.length})'),
            const Tab(text: 'Stats'),
          ],
        ),
      ),
      floatingActionButton: revision == null || _tabs.index != 0
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
              controller: _tabs,
              children: [
                DeckCardsTab(
                  revisionId: revision.id,
                  onAddCards: () => _openPicker(context, revision.id),
                ),
                DeckRevisionsTab(deck: deck),
                DeckStatsTab(revisionId: revision.id),
              ],
            ),
    );
  }

  void _openPicker(BuildContext context, int revisionId) {
    context.pushOnce('/decks/${deck.id}/add/$revisionId');
  }

  Future<void> _handle(BuildContext context, String action) async {
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
      case 'thumbnail':
        final revisionId = deck.activeRevision?.id;
        if (revisionId == null || !context.mounted) return;
        await showDeckThumbnailSheet(
          context,
          deck: deck,
          revisionId: revisionId,
        );
      case 'staples':
        // The picker already shows a list and puts copies in the deck, so
        // this only chooses which list it opens on.
        final revisionId = deck.activeRevision?.id;
        if (revisionId == null || !context.mounted) return;
        final list = await showStapleSourceSheet(context);
        if (list == null || !context.mounted) return;
        ref
            .read(cardFilterProvider(CardSearchScope.deckBuilder).notifier)
            .update(
              const CardFilter().copyWith(
                cardNumbers: list.cardNumbers.toSet(),
              ),
            );
        context.pushOnce('/decks/${deck.id}/add/$revisionId');
      case 'hand':
        // Offered whatever state the deck is in: a deck that cannot be dealt
        // from says so on the screen itself, which is a better answer than a
        // menu entry greyed out for reasons it cannot give.
        final revisionId = deck.activeRevision?.id;
        if (revisionId == null || !context.mounted) return;
        context.pushOnce('/decks/${deck.id}/hand/$revisionId');
      case 'export':
        final revisionId = deck.activeRevision?.id;
        if (revisionId == null || !context.mounted) return;
        context.pushOnce('/decks/${deck.id}/export/$revisionId');
      case 'clear':
        final revisionId = deck.activeRevision?.id;
        if (revisionId == null || !context.mounted) return;
        final confirmed = await _confirm(
          context,
          title: 'Clear ${deck.activeRevision!.name}?',
          message:
              'Removes every card from this revision. Other revisions '
              'keep their cards.',
          confirmLabel: 'Clear',
        );
        if (confirmed) await dao.clearRevision(revisionId);
      case 'delete':
        if (!context.mounted) return;
        final confirmed = await showDeleteDeckDialog(context, deck);
        if (confirmed) {
          await dao.deleteDeck(deck.id);
          // The deck this screen was showing is gone, so there is nothing to
          // pop back onto: go to the list instead.
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
