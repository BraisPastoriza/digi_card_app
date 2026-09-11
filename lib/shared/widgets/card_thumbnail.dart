import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/digimon_colors.dart';
import '../../domain/models/digimon_card.dart';

/// Aspect ratio of a physical Digimon card (63 x 88 mm).
const cardAspectRatio = 63 / 88;

/// A card image, cached on disk after the first view.
///
/// While loading it shows a plate tinted with the card's own colours, so a
/// grid reads as the right shape and colour before any image arrives.
class CardThumbnail extends ConsumerWidget {
  const CardThumbnail({
    super.key,
    required this.card,
    this.borderRadius = 10,
    this.showColorEdge = true,
    this.showRestriction = true,
    this.fit = BoxFit.cover,
  });

  final DigimonCard card;
  final double borderRadius;

  /// Draws a thin bar of the card's colours along the bottom edge, which keeps
  /// the colour readable when the art itself is dark.
  final bool showColorEdge;

  /// Marks the card when the restriction list limits it, either in how many
  /// copies it allows or in what it may be played alongside.
  ///
  /// It belongs on the picture rather than on any one screen: what the list
  /// says is a property of the card, and it is needed wherever cards are being
  /// looked at — in the library, in a deck, in a staple list. Turned off where
  /// something else already says it in words.
  final bool showRestriction;

  /// `cover` in grids, where every tile is already the card's aspect ratio.
  /// Anywhere the box is a different shape this must be `contain`, or the
  /// card's own borders and its number get cropped away.
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final radius = BorderRadius.circular(borderRadius);
    final limitation = card.activeLimitation;
    // Whether the card is half of a banned pair cannot be read off the card:
    // the ruling is recorded on one of the two only, and the other would go
    // unmarked. The index answers for both, and is empty until it resolves —
    // a tile that paints a moment before the badge appears is better than one
    // that waits for it.
    final pairBanned =
        showRestriction &&
        (ref.watch(pairRestrictionsProvider).valueOrNull
                ?.forNumber(card.number)
                .isNotEmpty ??
            false);
    // The badges size themselves against the tile, so the measurement has to
    // be taken here: inside the Stack a positioned child is handed unbounded
    // width and would always look like the biggest case.
    return LayoutBuilder(
      builder: (context, constraints) => _build(
        context,
        radius,
        limitation,
        pairBanned: pairBanned,
        compact: constraints.maxWidth < 130,
      ),
    );
  }

  Widget _build(
    BuildContext context,
    BorderRadius radius,
    CardLimitation? limitation, {
    required bool pairBanned,
    required bool compact,
  }) {
    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedNetworkImage(
            imageUrl: card.imageUrl,
            fit: fit,
            fadeInDuration: const Duration(milliseconds: 150),
            placeholder: (context, _) => _Placeholder(card: card),
            errorWidget: (context, _, _) =>
                _Placeholder(card: card, failed: true),
          ),
          if (showColorEdge)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 3,
                decoration: BoxDecoration(
                  gradient: DigimonColors.gradientOf(card.colors),
                ),
              ),
            ),
          if (pairBanned || (showRestriction && limitation != null))
            Positioned(
              // Bottom left is the one corner free across every grid in the
              // app: copy counts and selection ticks sit at the top, and the
              // colour edge takes the last three pixels of the bottom.
              left: 4,
              bottom: showColorEdge ? 7 : 4,
              child: Row(
                spacing: 3,
                children: [
                  // A card can be both restricted and half of a pairing, and
                  // the two say different things, so neither replaces the
                  // other.
                  if (showRestriction && limitation != null)
                    _RestrictionBadge(
                      limitation: limitation,
                      compact: compact,
                    ),
                  if (pairBanned) _PairBadge(compact: compact),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Says what the restriction list allows of a card, in the space a thumbnail
/// has: banned cards are called out as such, and a limited card carries the
/// number it is limited to.
class _RestrictionBadge extends StatelessWidget {
  const _RestrictionBadge({required this.limitation, required this.compact});

  final CardLimitation limitation;

  /// Set on the smaller thumbnails — a dealt hand, the strip of art on a
  /// staple list — where a full-size badge covers the card's own name rather
  /// than sitting beside it. A grid tile is around 150 wide and takes the
  /// full size; the strips are around 110.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final banned = limitation.effectiveAllowance == 0;
    final background = banned ? scheme.error : DigimonColors.yellow;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 3 : 5,
        vertical: compact ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: AppSurfaces.background.withValues(alpha: 0.7),
        ),
      ),
      child: Text(
        banned ? 'BAN' : '×${limitation.effectiveAllowance}',
        style: TextStyle(
          fontSize: compact ? 8 : 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
          height: 1.1,
          // Black on yellow, white on red: both are the readable pairing, and
          // the badge has to work over whatever art is behind it.
          color: banned ? scheme.onError : Colors.black,
        ),
      ),
    );
  }
}

/// Marks a card the restriction list bans alongside another.
///
/// Says only that a pairing exists — which card it is, and why, needs more
/// room than a corner of a thumbnail and is on the card's own page.
class _PairBadge extends StatelessWidget {
  const _PairBadge({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 3 : 5,
        vertical: compact ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: DigimonColors.purple,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: AppSurfaces.background.withValues(alpha: 0.7),
        ),
      ),
      child: Text(
        'PAIR',
        style: TextStyle(
          fontSize: compact ? 8 : 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.2,
          height: 1.1,
          color: Colors.black,
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.card, this.failed = false});

  final DigimonCard card;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppSurfaces.surfaceHigh,
            Color.lerp(
              AppSurfaces.surfaceHigh,
              card.colors.isEmpty
                  ? AppSurfaces.surfaceHighest
                  : DigimonColors.of(card.colors.first),
              0.22,
            )!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: failed
            ? Icon(
                Icons.image_not_supported_outlined,
                size: 20,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )
            : Padding(
                padding: const EdgeInsets.all(6),
                child: Text(
                  card.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
      ),
    );
  }
}
