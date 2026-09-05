import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/digimon_colors.dart';
import '../../domain/models/digimon_card.dart';

/// Aspect ratio of a physical Digimon card (63 x 88 mm).
const cardAspectRatio = 63 / 88;

/// A card image, cached on disk after the first view.
///
/// While loading it shows a plate tinted with the card's own colours, so a
/// grid reads as the right shape and colour before any image arrives.
class CardThumbnail extends StatelessWidget {
  const CardThumbnail({
    super.key,
    required this.card,
    this.borderRadius = 10,
    this.showColorEdge = true,
    this.fit = BoxFit.cover,
  });

  final DigimonCard card;
  final double borderRadius;

  /// Draws a thin bar of the card's colours along the bottom edge, which keeps
  /// the colour readable when the art itself is dark.
  final bool showColorEdge;

  /// `cover` in grids, where every tile is already the card's aspect ratio.
  /// Anywhere the box is a different shape this must be `contain`, or the
  /// card's own borders and its number get cropped away.
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
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
        ],
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
