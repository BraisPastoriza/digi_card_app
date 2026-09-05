import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/card_enums.dart';
import '../../../domain/models/deck.dart';
import '../../../shared/widgets/common.dart';
import '../deck_providers.dart';
import 'deck_entry_tile.dart';

/// The cards in the active revision, grouped the way a deck list is written:
/// eggs first, then Digimon, Tamers and Options.
class DeckCardsTab extends ConsumerWidget {
  const DeckCardsTab({
    super.key,
    required this.revisionId,
    required this.onAddCards,
  });

  final int revisionId;
  final VoidCallback onAddCards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final composition = ref.watch(compositionProvider(revisionId));

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
              onPressed: onAddCards,
              icon: const Icon(Icons.search, size: 18),
              label: const Text('Add cards'),
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 96),
          children: [
            _CategoryGroup(
              title: 'Egg deck',
              entries: composition.entriesOfCategory(CardCategory.digiEgg),
              count: composition.eggDeckCount,
              limit: DeckRules.maxEggDeckSize,
              revisionId: revisionId,
            ),
            for (final category in const [
              CardCategory.digimon,
              CardCategory.tamer,
              CardCategory.option,
            ])
              _CategoryGroup(
                title: '${category.label}s',
                entries: composition.entriesOfCategory(category),
                count: composition.countOfCategory(category),
                revisionId: revisionId,
              ),
          ],
        );
      },
    );
  }
}

class _CategoryGroup extends StatelessWidget {
  const _CategoryGroup({
    required this.title,
    required this.entries,
    required this.count,
    required this.revisionId,
    this.limit,
  });

  final String title;
  final List<DeckEntry> entries;
  final int count;
  final int? limit;
  final int revisionId;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;
    final overLimit = limit != null && count > limit!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title,
          trailing: Text(
            limit == null ? '$count' : '$count / $limit',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: overLimit ? scheme.error : scheme.onSurfaceVariant,
            ),
          ),
        ),
        for (final entry in entries)
          DeckEntryTile(entry: entry, revisionId: revisionId),
      ],
    );
  }
}
