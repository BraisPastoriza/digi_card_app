import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../domain/models/deck.dart';
import '../../../domain/models/digimon_card.dart';
import '../../../shared/widgets/common.dart';
import '../deck_providers.dart';
import 'deck_name_dialog.dart';

/// Adds a copy of [card] to a deck the user picks, without leaving the card.
Future<void> showAddToDeckSheet(BuildContext context, DigimonCard card) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _AddToDeckSheet(card: card),
  );
}

class _AddToDeckSheet extends ConsumerWidget {
  const _AddToDeckSheet({required this.card});

  final DigimonCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final decks = ref.watch(decksProvider);

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
                const Text(
                  'Add to deck',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${card.name} · ${card.number}',
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
            child: decks.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load decks',
                message: '$error',
              ),
              data: (decks) => decks.isEmpty
                  ? EmptyState(
                      icon: Icons.layers_outlined,
                      title: 'No decks yet',
                      message: 'Create a deck to start adding cards to it.',
                      action: FilledButton.icon(
                        onPressed: () => _createDeckWithCard(context, ref),
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('New deck'),
                      ),
                    )
                  : ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.only(bottom: 24),
                      children: [
                        for (final deck in decks)
                          _DeckRow(deck: deck, card: card),
                        const Divider(height: 24),
                        ListTile(
                          onTap: () => _createDeckWithCard(context, ref),
                          leading: CircleAvatar(
                            backgroundColor: scheme.primaryContainer,
                            child: Icon(Icons.add, color: scheme.primary),
                          ),
                          title: const Text('New deck'),
                          subtitle: const Text('Start a deck with this card'),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createDeckWithCard(BuildContext context, WidgetRef ref) async {
    final name = await showDeckNameDialog(context, title: 'New deck');
    if (name == null || !context.mounted) return;

    final dao = ref.read(deckDaoProvider);
    final deckId = await dao.createDeck(name: name);
    // Read the revision from the database rather than a provider: nothing is
    // listening to the new deck yet, so an auto-disposing provider would be
    // torn down before it resolved.
    final revisionId = await dao.activeRevisionIdOf(deckId);
    if (revisionId != null) {
      await dao.adjustQuantity(revisionId: revisionId, card: card, delta: 1);
    }
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Added ${card.name} to $name')));
    }
  }
}

class _DeckRow extends ConsumerWidget {
  const _DeckRow({required this.deck, required this.card});

  final Deck deck;
  final DigimonCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final revision = deck.activeRevision;
    if (revision == null) return const SizedBox.shrink();

    final quantities = ref.watch(revisionQuantitiesProvider(revision.id));
    final quantity = quantities[card.number] ?? 0;
    final atLimit = quantity >= card.copyLimit;

    return ListTile(
      onTap: atLimit ? null : () => _add(context, ref, revision.id),
      title: Text(deck.name),
      subtitle: Text(
        deck.revisions.length > 1
            ? '${revision.name} · ${deck.revisions.length} revisions'
            : revision.name,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (quantity > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                '$quantity',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
            ),
          const SizedBox(width: 8),
          Icon(
            atLimit ? Icons.block : Icons.add_circle_outline,
            size: 20,
            color: atLimit ? scheme.onSurfaceVariant : scheme.primary,
          ),
        ],
      ),
    );
  }

  Future<void> _add(BuildContext context, WidgetRef ref, int revisionId) async {
    await ref
        .read(deckDaoProvider)
        .adjustQuantity(revisionId: revisionId, card: card, delta: 1);
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added ${card.name} to ${deck.name}')),
    );
  }
}
