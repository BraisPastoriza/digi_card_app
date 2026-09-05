import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/card_enums.dart';
import '../../../domain/models/deck.dart';
import '../../../shared/widgets/card_thumbnail.dart';
import '../../../shared/widgets/common.dart';

/// One stack of cards in the deck editor, with the stepper that changes how
/// many copies the deck runs.
class DeckEntryTile extends ConsumerWidget {
  const DeckEntryTile({
    super.key,
    required this.entry,
    required this.revisionId,
  });

  final DeckEntry entry;
  final int revisionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final card = entry.card;
    final overLimit = entry.quantity > card.copyLimit;

    return InkWell(
      onTap: () => context.push('/card/${card.number}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              height: 38 / cardAspectRatio,
              child: CardThumbnail(card: card, borderRadius: 5),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      ColorDots(colors: card.colors, size: 7),
                      const SizedBox(width: 7),
                      Flexible(
                        child: Text(
                          _subtitle(card.category, card.level, card.cost, card.dp),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (overLimit)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(Icons.warning_amber_rounded,
                    size: 16, color: scheme.error),
              ),
            _QuantityStepper(
              quantity: entry.quantity,
              limit: card.copyLimit,
              onChanged: (delta) => ref.read(deckDaoProvider).adjustQuantity(
                revisionId: revisionId,
                card: card,
                delta: delta,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _subtitle(
    CardCategory category,
    int? level,
    int? cost,
    int? dp,
  ) => [
    if (level != null) 'Lv.$level',
    if (cost != null) 'Cost $cost',
    if (dp != null) '$dp DP',
    if (level == null && cost == null && dp == null) category.label,
  ].join(' · ');
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.limit,
    required this.onChanged,
  });

  final int quantity;
  final int limit;
  final void Function(int delta) onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: AppSurfaces.surfaceHigh,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppSurfaces.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove,
            onPressed: () => onChanged(-1),
          ),
          SizedBox(
            width: 26,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add,
            // The restriction list caps some cards below four copies.
            onPressed: quantity >= limit ? null : () => onChanged(1),
            color: quantity >= limit ? null : scheme.primary,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, this.onPressed, this.color});

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(9),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
        child: Icon(
          icon,
          size: 17,
          color: onPressed == null
              ? scheme.onSurfaceVariant.withValues(alpha: 0.4)
              : (color ?? scheme.onSurface),
        ),
      ),
    );
  }
}
