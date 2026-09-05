import 'package:flutter/material.dart';

import '../../../domain/models/digimon_card.dart';
import '../../../shared/widgets/card_thumbnail.dart';

/// Grid of card images, sized so a phone shows three columns and a tablet
/// scales up rather than stretching the cards.
class SliverCardGrid extends StatelessWidget {
  const SliverCardGrid({
    super.key,
    required this.cards,
    required this.onCardTap,
    this.quantityOf,
    this.onCardLongPress,
  });

  final List<DigimonCard> cards;
  final void Function(DigimonCard card) onCardTap;
  final void Function(DigimonCard card)? onCardLongPress;

  /// Copies of a card already in the deck being edited, drawn as a badge.
  /// Null in the plain library, where copies are not a concept.
  final int Function(DigimonCard card)? quantityOf;

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
          final quantity = quantityOf?.call(card) ?? 0;
          return _CardGridTile(
            card: card,
            quantity: quantity,
            onTap: () => onCardTap(card),
            onLongPress: onCardLongPress == null
                ? null
                : () => onCardLongPress!(card),
          );
        }, childCount: cards.length),
      ),
    );
  }
}

class _CardGridTile extends StatelessWidget {
  const _CardGridTile({
    required this.card,
    required this.quantity,
    required this.onTap,
    this.onLongPress,
  });

  final DigimonCard card;
  final int quantity;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Stack(
        children: [
          Positioned.fill(child: CardThumbnail(card: card)),
          if (quantity > 0)
            Positioned(
              top: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$quantity',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: scheme.onPrimary,
                  ),
                ),
              ),
            ),
          if (quantity > 0)
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: scheme.primary, width: 2),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
