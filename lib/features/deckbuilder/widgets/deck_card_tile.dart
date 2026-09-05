import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/digimon_card.dart';
import '../../../shared/widgets/card_thumbnail.dart';

/// A card in a deck-editing context: the art, how many copies the deck runs,
/// and — once tapped — the controls to change that.
///
/// Deck building is repetitive, so the stepper appears in place on the card
/// rather than in a sheet: adding the fourth copy of something should not cost
/// two taps and an animation.
class DeckCardTile extends StatelessWidget {
  const DeckCardTile({
    super.key,
    required this.card,
    required this.quantity,
    required this.expanded,
    required this.onTap,
    required this.onAdjust,
    required this.onInfo,
  });

  final DigimonCard card;
  final int quantity;

  /// Whether this tile is the one showing its stepper.
  final bool expanded;

  final VoidCallback onTap;
  final void Function(int delta) onAdjust;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final inDeck = quantity > 0;
    final atLimit = quantity >= card.copyLimit;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: inDeck ? scheme.primary : Colors.transparent,
                  width: inDeck ? 3 : 0,
                ),
                boxShadow: inDeck
                    ? [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(inDeck ? 8 : 10),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CardThumbnail(card: card, borderRadius: 0),
                    // Cards not in the deck sit back so the ones that are read
                    // as a set at a glance.
                    if (!inDeck) const ColoredBox(color: Color(0x33000000)),
                  ],
                ),
              ),
            ),
          ),
          if (inDeck)
            Positioned(
              top: -6,
              right: -6,
              child: _CopyBadge(quantity: quantity, limit: card.copyLimit),
            ),
          if (expanded)
            Positioned.fill(
              child: _Stepper(
                quantity: quantity,
                atLimit: atLimit,
                onAdjust: onAdjust,
                onInfo: onInfo,
              ),
            ),
        ],
      ),
    );
  }
}

/// The copy count, sized to be legible while scanning a 50-card deck rather
/// than to be tidy.
class _CopyBadge extends StatelessWidget {
  const _CopyBadge({required this.quantity, required this.limit});

  final int quantity;
  final int limit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final over = quantity > limit;
    final background = over ? scheme.error : scheme.primary;

    return Container(
      constraints: const BoxConstraints(minWidth: 30),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppSurfaces.background, width: 2),
      ),
      child: Text(
        '$quantity',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          height: 1.1,
          color: over ? scheme.onError : scheme.onPrimary,
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.quantity,
    required this.atLimit,
    required this.onAdjust,
    required this.onInfo,
  });

  final int quantity;
  final bool atLimit;
  final void Function(int delta) onAdjust;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.78),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StepButton(
                  icon: Icons.remove,
                  enabled: quantity > 0,
                  onPressed: () => onAdjust(-1),
                ),
                SizedBox(
                  width: 34,
                  child: Text(
                    '$quantity',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
                _StepButton(
                  icon: Icons.add,
                  enabled: !atLimit,
                  onPressed: () => onAdjust(1),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: onInfo,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                foregroundColor: scheme.primary,
              ),
              icon: const Icon(Icons.info_outline, size: 14),
              label: const Text('Card', style: TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.enabled,
    required this.onPressed,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: enabled ? scheme.primary : Colors.white24,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: enabled ? onPressed : null,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(7),
          child: Icon(
            icon,
            size: 20,
            color: enabled ? scheme.onPrimary : Colors.white38,
          ),
        ),
      ),
    );
  }
}
