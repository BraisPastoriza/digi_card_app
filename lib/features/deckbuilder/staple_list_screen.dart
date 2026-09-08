import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router/navigation.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/digimon_card.dart';
import '../../domain/models/staple_list.dart';
import '../../shared/widgets/card_thumbnail.dart';
import '../../shared/widgets/common.dart';
import 'staple_providers.dart';
import 'widgets/deck_name_dialog.dart';
import 'widgets/staples_tab.dart';

/// One staple list: the cards in it, with the two things you do to a list —
/// put a card in, take a card out.
class StapleListScreen extends ConsumerWidget {
  const StapleListScreen({super.key, required this.listId});

  final int listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(stapleListsProvider);
    final list = ref.watch(stapleListProvider(listId));
    final scheme = Theme.of(context).colorScheme;

    if (lists.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (list == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.goBack('/decks'),
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        body: const EmptyState(
          icon: Icons.bookmark_remove_outlined,
          title: 'List not found',
          message: 'It may have been deleted.',
        ),
      );
    }

    // Cards stored but not in the library — a set that has not been synced
    // yet. Counting them keeps the list honest about what it holds.
    final unresolved = list.count - list.cards.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.goBack('/decks'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(list.name, overflow: TextOverflow.ellipsis),
            Text(
              list.count == 1 ? '1 card' : '${list.count} cards',
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
            onSelected: (action) => _handle(context, ref, list, action),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'rename', child: Text('Rename list')),
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  'Delete list',
                  style: TextStyle(color: scheme.error),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushOnce('/decks/staples/$listId/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add cards'),
      ),
      body: list.isEmpty
          ? EmptyState(
              icon: Icons.add_card,
              title: 'This list is empty',
              message:
                  'Add the cards you want at hand. They show up as a source '
                  'in the deck builder, so you can drop them into a deck '
                  'without going looking for them.',
              action: FilledButton.icon(
                onPressed: () => context.pushOnce('/decks/staples/$listId/add'),
                icon: const Icon(Icons.search, size: 18),
                label: const Text('Add cards'),
              ),
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 150,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 12,
                          childAspectRatio: cardAspectRatio,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final card = list.cards[index];
                      return _StapleCardTile(
                        card: card,
                        onTap: () => context.pushOnce('/card/${card.number}'),
                        onRemove: () => _remove(context, ref, list, card),
                      );
                    }, childCount: list.cards.length),
                  ),
                ),
                if (unresolved > 0)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: Text(
                        '$unresolved more '
                        '${unresolved == 1 ? 'card is' : 'cards are'} in this '
                        'list but not in your library yet.',
                        style: TextStyle(
                          fontSize: 12,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 96)),
              ],
            ),
    );
  }

  Future<void> _remove(
    BuildContext context,
    WidgetRef ref,
    StapleList list,
    DigimonCard card,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(stapleDaoProvider).removeCard(list.id, card.number);
    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Removed ${card.name}'),
          action: SnackBarAction(
            label: 'Undo',
            onPressed: () =>
                ref.read(stapleDaoProvider).addCards(list.id, [card.number]),
          ),
        ),
      );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    StapleList list,
    String action,
  ) async {
    switch (action) {
      case 'rename':
        final name = await showDeckNameDialog(
          context,
          title: 'Rename list',
          label: 'List name',
          initialValue: list.name,
        );
        if (name != null) {
          await ref.read(stapleDaoProvider).renameList(list.id, name);
        }
      case 'delete':
        if (!context.mounted) return;
        if (await showDeleteStapleListDialog(context, list)) {
          await ref.read(stapleDaoProvider).deleteList(list.id);
          // The list this screen was showing is gone, so there is nothing to
          // pop back onto.
          if (context.mounted) context.go('/decks');
        }
    }
  }
}

/// A card in the list, with the cross that takes it out.
class _StapleCardTile extends StatelessWidget {
  const _StapleCardTile({
    required this.card,
    required this.onTap,
    required this.onRemove,
  });

  final DigimonCard card;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onTap,
            child: CardThumbnail(card: card),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: Material(
            color: AppSurfaces.background.withValues(alpha: 0.8),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(Icons.close, size: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
