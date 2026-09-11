import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/router/navigation.dart';
import '../../../domain/models/deck.dart';
import '../../../l10n/l10n.dart';
import '../deck_text.dart';
import '../../../shared/widgets/card_thumbnail.dart';
import '../../../shared/widgets/common.dart';
import '../deck_providers.dart';
import 'deck_card_tile.dart';

/// The cards in the active revision, laid out the way a deck list is read:
/// Digi-Eggs first, then the Digimon a level at a time, then Tamers and
/// Options.
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
        title: context.l10n.revisionLoadError,
        message: '$error',
      ),
      data: (composition) {
        if (composition.allEntries.isEmpty) {
          return EmptyState(
            icon: Icons.add_card,
            title: context.l10n.revisionEmptyTitle,
            message:
                context.l10n.revisionEmptyMessage,
            action: FilledButton.icon(
              onPressed: widget.onAddCards,
              icon: const Icon(Icons.search, size: 18),
              label: Text(context.l10n.deckAddCards),
            ),
          );
        }

        return GestureDetector(
          // Tapping the background closes an open stepper.
          onTap: () => setState(() => _openCard = null),
          behavior: HitTestBehavior.translucent,
          child: CustomScrollView(
            slivers: [
              for (final section in composition.sections) ...[
                SliverToBoxAdapter(child: _SectionHeader(section: section)),
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
                      final entry = section.entries[index];
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
                            context.pushOnce('/card/${entry.cardNumber}'),
                      );
                    }, childCount: section.entries.length),
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

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.section});

  final DeckSection section;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final limit = section.limit;
    final overLimit = limit != null && section.count > limit;
    return SectionHeader(
      sectionLabel(section, context.l10n),
      trailing: Text(
        limit == null ? '${section.count}' : '${section.count} / $limit',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: overLimit ? scheme.error : scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}
