import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/digimon_colors.dart';
import '../../domain/models/card_enums.dart';

/// Row of colour dots identifying a card's colour or a deck's spread.
class ColorDots extends StatelessWidget {
  const ColorDots({
    super.key,
    required this.colors,
    this.size = 8,
    this.spacing = 3,
  });

  final List<CardColor> colors;
  final double size;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final color in colors)
          Padding(
            padding: EdgeInsets.only(right: color == colors.last ? 0 : spacing),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: DigimonColors.of(color),
                shape: BoxShape.circle,
                border: Border.all(color: AppSurfaces.background, width: 0.5),
              ),
            ),
          ),
      ],
    );
  }
}

/// Small uppercase label used for set codes, rarities and card types.
class MetaBadge extends StatelessWidget {
  const MetaBadge(
    this.label, {
    super.key,
    this.color,
    this.background,
    this.icon,
  });

  final String label;
  final Color? color;
  final Color? background;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = color ?? scheme.onSurfaceVariant;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: icon == null ? 7 : 6,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: background ?? AppSurfaces.surfaceHigh,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppSurfaces.outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 11, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder shown when a list has nothing in it.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppSurfaces.surfaceHigh,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 28, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: scheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}

/// Section heading used above grouped lists.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.1,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
