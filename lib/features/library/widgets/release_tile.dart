import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/card_release.dart';

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
  const ReleaseTile({super.key, required this.release, required this.onTap});

  final CardRelease release;
  final VoidCallback onTap;

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
              if (release.thumbnailUrl != null)
                CachedNetworkImage(
                  imageUrl: release.thumbnailUrl!,
                  fit: BoxFit.cover,
                  fadeInDuration: const Duration(milliseconds: 150),
                  errorWidget: (context, _, _) =>
                      _ArtFallback(label: code ?? release.displayName),
                )
              else
                _ArtFallback(label: code ?? release.displayName),
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
  const _ArtFallback({required this.label});

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
