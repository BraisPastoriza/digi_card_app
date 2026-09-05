import 'package:flutter/material.dart';

import '../../../domain/models/digimon_card.dart';
import '../../../shared/widgets/card_thumbnail.dart';

/// Grid of card images, sized so a phone shows three columns and a tablet
/// scales up rather than stretching the cards.
///
/// This is the read-only grid the library browses with. Deck editing uses
/// `DeckCardTile` instead, which adds copy counts and a stepper.
class SliverCardGrid extends StatelessWidget {
  const SliverCardGrid({
    super.key,
    required this.cards,
    required this.onCardTap,
  });

  final List<DigimonCard> cards;
  final void Function(DigimonCard card) onCardTap;

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 150,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: cardAspectRatio,
        ),
        delegate: SliverChildBuilderDelegate((context, index) {
          final card = cards[index];
          return GestureDetector(
            onTap: () => onCardTap(card),
            child: CardThumbnail(card: card),
          );
        }, childCount: cards.length),
      ),
    );
  }
}
