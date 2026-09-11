import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../domain/models/digimon_card.dart';
import '../../../domain/models/staple_list.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/common.dart';
import '../staple_providers.dart';
import 'deck_name_dialog.dart';

/// Puts [card] into the staple lists the user picks, without leaving the card.
///
/// Unlike adding to a deck, this does not close on the first tap: a card that
/// belongs on one list often belongs on another, and a list holds it once
/// either way, so each row is a switch rather than a one-shot action.
Future<void> showAddToStapleSheet(BuildContext context, DigimonCard card) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _AddToStapleSheet(card: card),
  );
}

class _AddToStapleSheet extends ConsumerWidget {
  const _AddToStapleSheet({required this.card});

  final DigimonCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final lists = ref.watch(stapleListsProvider);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.55,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.addToListTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.addToDeckCardLine(card.name, card.number),
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: lists.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline,
                title: context.l10n.staplesLoadError,
                message: '$error',
              ),
              data: (lists) => lists.isEmpty
                  // Scrollable even with nothing in it: on a short screen the
                  // sheet is not tall enough for the empty state to stand.
                  ? ListView(
                      controller: scrollController,
                      children: [
                        EmptyState(
                          icon: Icons.bookmarks_outlined,
                          title: context.l10n.staplesEmptyTitle,
                          message: context.l10n.addToListEmptyMessage,
                          action: FilledButton.icon(
                            onPressed: () => _createListWithCard(context, ref),
                            icon: const Icon(Icons.add, size: 18),
                            label: Text(context.l10n.staplesCreate),
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        for (final list in lists)
                          _StapleRow(list: list, card: card),
                        const Divider(height: 24),
                        ListTile(
                          onTap: () => _createListWithCard(context, ref),
                          leading: CircleAvatar(
                            backgroundColor: scheme.primaryContainer,
                            child: Icon(Icons.add, color: scheme.primary),
                          ),
                          title: Text(context.l10n.decksNewList),
                          subtitle: Text(context.l10n.addToListNewSubtitle),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// Asks for a name, the way a list is made everywhere else in the app, then
  /// starts the list off with this card.
  Future<void> _createListWithCard(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final name = await showDeckNameDialog(
      context,
      title: l10n.stapleNewTitle,
      label: l10n.stapleNameLabel,
    );
    if (name == null) return;

    final dao = ref.read(stapleDaoProvider);
    final listId = await dao.createList(name: name);
    await dao.addCards(listId, [card.number]);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(l10n.addToListAdded(card.name, name))),
      );
  }
}

class _StapleRow extends ConsumerWidget {
  const _StapleRow({required this.list, required this.card});

  final StapleList list;
  final DigimonCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final holds = list.contains(card.number);

    return ListTile(
      onTap: () => _toggle(context, ref),
      title: Text(list.name),
      subtitle: Text(context.l10n.cardCount(list.count)),
      trailing: Icon(
        holds ? Icons.check_circle : Icons.add_circle_outline,
        size: 20,
        color: holds ? scheme.primary : scheme.onSurfaceVariant,
        semanticLabel: holds ? context.l10n.addToListHolds : null,
      ),
    );
  }

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final added = await ref
        .read(stapleDaoProvider)
        .toggleCard(list.id, card.number);
    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            added
                ? l10n.addToListAdded(card.name, list.name)
                : l10n.addToListRemoved(card.name, list.name),
          ),
        ),
      );
  }
}
