import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../domain/models/deck.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/card_thumbnail.dart';
import '../../../shared/widgets/common.dart';
import '../deck_providers.dart';

/// Lets the user pick which of a deck's cards stands for it in the deck list.
///
/// The automatic choice — the deck's biggest Digimon — is right often enough
/// to be the default, but not for a deck built around a Tamer or named after
/// a Lv.4, so the choice is offered rather than inferred.
Future<void> showDeckThumbnailSheet(
  BuildContext context, {
  required Deck deck,
  required int revisionId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) =>
        _DeckThumbnailSheet(deck: deck, revisionId: revisionId),
  );
}

class _DeckThumbnailSheet extends ConsumerWidget {
  const _DeckThumbnailSheet({required this.deck, required this.revisionId});

  final Deck deck;
  final int revisionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final composition = ref.watch(compositionProvider(revisionId)).valueOrNull;
    final entries = composition?.allEntries ?? const <DeckEntry>[];
    final automatic = composition?.signatureCard;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.thumbnailTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.thumbnailSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (entries.isEmpty)
            Expanded(
              child: EmptyState(
                icon: Icons.add_card,
                title: context.l10n.thumbnailEmptyTitle,
                message: context.l10n.thumbnailEmptyMessage,
              ),
            )
          else
            Expanded(
              child: CustomScrollView(
                controller: scrollController,
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: OutlinedButton.icon(
                        onPressed: () => _choose(context, ref, null),
                        icon: Icon(
                          deck.thumbnailCardNumber == null
                              ? Icons.check_circle
                              : Icons.auto_awesome,
                          size: 18,
                        ),
                        label: Text(
                          automatic == null
                              ? context.l10n.thumbnailAutomatic
                              : context.l10n.thumbnailAutomaticNamed(
                                  automatic.card.name,
                                ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 130,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: cardAspectRatio,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final entry = entries[index];
                        final selected =
                            deck.thumbnailCardNumber == entry.cardNumber;
                        return GestureDetector(
                          onTap: () => _choose(context, ref, entry.cardNumber),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selected
                                    ? scheme.primary
                                    : Colors.transparent,
                                width: selected ? 3 : 0,
                              ),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(selected ? 2 : 0),
                              child: CardThumbnail(
                                card: entry.card,
                                borderRadius: selected ? 6 : 10,
                              ),
                            ),
                          ),
                        );
                      }, childCount: entries.length),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _choose(
    BuildContext context,
    WidgetRef ref,
    String? cardNumber,
  ) async {
    await ref.read(deckDaoProvider).setDeckThumbnail(deck.id, cardNumber);
    if (context.mounted) Navigator.of(context).pop();
  }
}
