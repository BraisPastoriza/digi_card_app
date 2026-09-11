import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/digimon_card.dart';
import '../../../l10n/l10n.dart';
import '../../../domain/models/staple_list.dart';
import '../../../shared/widgets/card_thumbnail.dart';
import '../staple_providers.dart';

/// Asks which staple list to build from, straight from the deck.
///
/// It returns the chosen list rather than adding anything itself: the card
/// picker already knows how to show a list and put copies in a deck, so this
/// only has to say which list to open.
Future<StapleList?> showStapleSourceSheet(BuildContext context) {
  return showModalBottomSheet<StapleList>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const _StapleSourceSheet(),
  );
}

class _StapleSourceSheet extends ConsumerWidget {
  const _StapleSourceSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final lists = ref.watch(stapleListsProvider).valueOrNull ?? const [];

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
            child: Text(
              context.l10n.stapleSourceTitle,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            child: Text(
              lists.isEmpty
                  ? context.l10n.stapleSourceEmpty
                  : context.l10n.stapleSourceHint,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: lists.length,
              itemBuilder: (context, index) {
                final list = lists[index];
                return ListTile(
                  onTap: () => Navigator.of(context).pop(list),
                  title: Text(
                    list.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    context.l10n.cardCount(list.count),
                  ),
                  trailing: _Preview(cards: list.cards),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// A few cards of the list, so it is recognised by its art rather than only
/// by the name the user gave it.
class _Preview extends StatelessWidget {
  const _Preview({required this.cards});

  final List<DigimonCard> cards;

  static const _shown = 3;

  @override
  Widget build(BuildContext context) {
    final preview = cards.take(_shown).toList();
    if (preview.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      width: 96,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        spacing: 4,
        children: [
          for (final card in preview)
            SizedBox(
              width: 28,
              child: AspectRatio(
                aspectRatio: cardAspectRatio,
                child: CardThumbnail(
                  card: card,
                  borderRadius: 4,
                  showColorEdge: false,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
