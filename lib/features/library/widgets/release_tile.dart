import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/card_release.dart';
import '../../../l10n/l10n.dart';

/// Aspect ratio of the product artwork the API serves for a release. Every
/// release has a 360x240 thumbnail, so the grid can rely on one shape.
const releaseArtRatio = 3 / 2;

/// A release as a piece of box art.
///
/// The artwork is the point: a player recognises DUAL REVOLUTION by its pack
/// long before they read "BT-25". The name and set code ride along in a scrim
/// over the bottom of the art, both because that is where they stay out of the
/// way and because keeping the tile a single fixed ratio means the grid can
/// size it from its width alone — labels stacked underneath overflow as soon
/// as the column width changes.
class ReleaseTile extends StatelessWidget {
  const ReleaseTile({
    super.key,
    required this.release,
    required this.onTap,
    this.cardImage,
  });

  final CardRelease release;
  final VoidCallback onTap;

  /// One of the release's own cards, for the releases whose product photo
  /// cannot stand for them. Resolved in the background, so it arrives a
  /// moment after the tile first paints.
  final String? cardImage;

  /// The picture the tile leads with.
  ///
  /// A card wins over the product photo wherever one was chosen: either the
  /// release publishes no photo, or the photo it publishes is the placeholder
  /// several releases share.
  Widget _artwork(String? code) {
    if (cardImage != null) {
      return _CardArtBackdrop(key: ValueKey(cardImage), imageUrl: cardImage!);
    }
    if (release.thumbnailUrl != null) {
      return CachedNetworkImage(
        key: ValueKey(release.thumbnailUrl),
        imageUrl: release.thumbnailUrl!,
        fit: BoxFit.cover,
        fadeInDuration: const Duration(milliseconds: 150),
        errorWidget: (context, _, _) =>
            _ArtFallback(label: code ?? release.displayName),
      );
    }
    return _ArtFallback(
      key: const ValueKey('fallback'),
      label: code ?? release.displayName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final code = release.setCode;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppSurfaces.surfaceHigh,
            border: Border.all(color: AppSurfaces.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // The stand-in card is resolved in the background, so it lands
              // after the tile has already painted. Crossfading covers that
              // switch instead of letting the tile blink.
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 150),
                layoutBuilder: (current, previous) => Stack(
                  fit: StackFit.expand,
                  children: [...previous, ?current],
                ),
                child: _artwork(code),
              ),
              // A preview set's data is community-sourced and still moving, so
              // it says so on the tile rather than only once you open it.
              if (release.isPreview)
                const Positioned(top: 6, left: 6, child: PreviewBadge()),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(9, 20, 9, 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Color(0xF2000000)],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        release.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 4, color: Colors.black87),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          if (code != null) ...[
                            Text(
                              code,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                                color: Color(0xFFFFB273),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            '${release.cardCount}',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtFallback extends StatelessWidget {
  const _ArtFallback({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppSurfaces.surfaceHigh, AppSurfaces.surfaceHighest],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 30),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

/// A card from the release, standing in for the missing product photo.
///
/// The card is shown whole rather than cropped to the tile's shape. A card is
/// taller than this tile is, so filling the tile would cut off the top and
/// bottom edges — and the bottom edge is where the copyright line and the
/// artist's name are printed, which the data sources require be left intact.
/// It sits on a blurred, darkened copy of itself so the tile still reads as a
/// filled block of colour rather than a card floating on grey.
///
/// The layer underneath is a plain colour, deliberately: using the lettered
/// fallback there put the product's name behind the blur, where it showed
/// through as a second title competing with the one in the scrim below.
class _CardArtBackdrop extends StatelessWidget {
  const _CardArtBackdrop({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: AppSurfaces.surfaceHigh),
        ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Opacity(
            opacity: 0.55,
            child: CachedNetworkImage(imageUrl: imageUrl, fit: BoxFit.cover),
          ),
        ),
        Padding(
          // Room at the bottom for the scrim the name and set code sit in.
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 30),
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            fadeInDuration: const Duration(milliseconds: 150),
            errorWidget: (context, _, _) => const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

/// Marks data that came from the secondary source rather than the primary
/// card API: a set that is not published there yet.
class PreviewBadge extends StatelessWidget {
  const PreviewBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.seed,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        context.l10n.releasePreviewBadge,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: Color(0xFF261200),
        ),
      ),
    );
  }
}
