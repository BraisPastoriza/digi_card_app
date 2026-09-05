import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../domain/models/card_enums.dart';
import '../../../domain/models/deck.dart';
import '../../../shared/widgets/card_thumbnail.dart';
import '../../../shared/widgets/common.dart';
import '../deck_providers.dart';
import 'deck_card_tile.dart';

/// The cards in the active revision, laid out the way a deck list is written:
/// eggs first, then Digimon, Tamers and Options.
///
/// Cards are shown as art rather than rows — a deck is recognised by its
/// pictures, and the copy counts have to be readable while scanning 50 of
/// them.
class DeckCardsTab extends ConsumerStatefulWidget {
  const DeckCardsTab({
    super.key,
    required this.revisionId,
    required this.onAddCards,
  });

  final int revisionId;
  final VoidCallback onAddCards;

  @override
  ConsumerState<DeckCardsTab> createState() => _DeckCardsTabState();
}

class _DeckCardsTabState extends ConsumerState<DeckCardsTab> {
  /// Card number whose stepper is open, if any. Only one at a time.
  String? _openCard;

  Future<void> _adjust(DeckEntry entry, int delta) async {
    await ref
        .read(deckDaoProvider)
        .adjustQuantity(
          revisionId: widget.revisionId,
          card: entry.card,
          delta: delta,
        );
  }

  @override
  Widget build(BuildContext context) {
    final composition = ref.watch(compositionProvider(widget.revisionId));

    return composition.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.error_outline,
        title: 'Could not load this revision',
        message: '$error',
      ),
      data: (composition) {
        if (composition.allEntries.isEmpty) {
          return EmptyState(
            icon: Icons.add_card,
            title: 'This revision is empty',
            message:
                'Add 50 cards to the main deck and up to 5 Digi-Eggs to the '
                'egg deck.',
            action: FilledButton.icon(
              onPressed: widget.onAddCards,
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Add cards'),
            ),
          );
        }

        final groups = <({String title, List<DeckEntry> entries, int? limit})>[
          (
            title: 'Egg deck',
            entries: composition.entriesOfCategory(CardCategory.digiEgg),
            limit: DeckRules.maxEggDeckSize,
          ),
          for (final category in const [
            CardCategory.digimon,
            CardCategory.tamer,
            CardCategory.option,
          ])
            (
              title: '${category.label}s',
              entries: composition.entriesOfCategory(category),
              limit: null,
            ),
        ];

        return GestureDetector(
          // Tapping the background closes an open stepper.
          onTap: () => setState(() => _openCard = null),
          behavior: HitTestBehavior.translucent,
          child: CustomScrollView(
            slivers: [
              for (final group in groups)
                if (group.entries.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: _GroupHeader(
                      title: group.title,
                      count: group.entries.fold(
                        0,
                        (sum, e) => sum + e.quantity,
                      ),
                      limit: group.limit,
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(14, 2, 14, 10),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 150,
                            mainAxisSpacing: 14,
                            crossAxisSpacing: 12,
                            childAspectRatio: cardAspectRatio,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final entry = group.entries[index];
                        return DeckCardTile(
                          card: entry.card,
                          quantity: entry.quantity,
                          expanded: _openCard == entry.cardNumber,
                          onTap: () => setState(
                            () => _openCard = _openCard == entry.cardNumber
                                ? null
                                : entry.cardNumber,
                          ),
                          onAdjust: (delta) => _adjust(entry, delta),
                          onInfo: () =>
                              context.push('/card/${entry.cardNumber}'),
                        );
                      }, childCount: group.entries.length),
                    ),
                  ),
                ],
              const SliverToBoxAdapter(child: SizedBox(height: 96)),
            ],
          ),
        );
      },
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.title,
    required this.count,
    required this.limit,
  });

  final String title;
  final int count;
  final int? limit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final overLimit = limit != null && count > limit!;
    return SectionHeader(
      title,
      trailing: Text(
        limit == null ? '$count' : '$count / $limit',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: overLimit ? scheme.error : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
