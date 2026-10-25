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

/// An offer at the top of a list — something newer is available — with the
/// buttons that act on it along the bottom.
class NoticeBanner extends StatelessWidget {
  const NoticeBanner({
    super.key,
    required this.icon,
    required this.title,
    this.body = const [],
    this.actions = const [],
    this.margin = const EdgeInsets.fromLTRB(16, 8, 16, 8),
  });

  final IconData icon;
  final String title;

  /// Under the title, beside the icon: usually one [NoticeBanner.text].
  final List<Widget> body;

  final List<Widget> actions;

  /// Space around the banner: the default suits a banner on its own, and a
  /// list that already pads its items passes less.
  final EdgeInsetsGeometry margin;

  /// A paragraph in the banner's body style.
  static Widget text(BuildContext context, String text) => Text(
    text,
    style: TextStyle(
      fontSize: 12.5,
      height: 1.45,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: margin,
      padding: EdgeInsets.fromLTRB(12, 12, 12, actions.isEmpty ? 12 : 4),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppSurfaces.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 18, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    for (final child in body) ...[
                      const SizedBox(height: 4),
                      child,
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (actions.isNotEmpty)
            // Wraps rather than overflows when three buttons in a long
            // language do not fit on a narrow phone.
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(alignment: WrapAlignment.end, children: actions),
            ),
        ],
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
