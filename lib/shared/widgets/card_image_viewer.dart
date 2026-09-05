import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../domain/models/digimon_card.dart';

/// Opens the card art full screen, where the printed text is actually legible.
///
/// Card effect text is set in about 5pt; at thumbnail size it is decorative,
/// so reading a card in the app means being able to zoom into the real scan.
Future<void> showCardImage(
  BuildContext context, {
  required List<DigimonCard> printings,
  int initialIndex = 0,
}) {
  return Navigator.of(context).push(
    PageRouteBuilder<void>(
      opaque: false,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      pageBuilder: (context, animation, _) => FadeTransition(
        opacity: animation,
        child: _CardImageViewer(
          printings: printings,
          initialIndex: initialIndex,
        ),
      ),
      transitionDuration: const Duration(milliseconds: 180),
    ),
  );
}

class _CardImageViewer extends StatefulWidget {
  const _CardImageViewer({required this.printings, required this.initialIndex});

  final List<DigimonCard> printings;
  final int initialIndex;

  @override
  State<_CardImageViewer> createState() => _CardImageViewerState();
}

class _CardImageViewerState extends State<_CardImageViewer> {
  late final PageController _controller = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  /// Set while a card is zoomed in, so the pager does not steal the drag.
  bool _zoomed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = widget.printings[_index];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.printings.length,
            physics: _zoomed
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) => _ZoomableImage(
              url: widget.printings[index].imageUrl,
              onZoomChanged: (zoomed) {
                if (zoomed != _zoomed) setState(() => _zoomed = zoomed);
              },
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                      color: Colors.white,
                    ),
                    Expanded(
                      child: Text(
                        '${card.name} · ${card.number}',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (widget.printings.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Text(
                          '${_index + 1} / ${widget.printings.length}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Pinch or double-tap to zoom',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomableImage extends StatefulWidget {
  const _ZoomableImage({required this.url, required this.onZoomChanged});

  final String url;
  final void Function(bool zoomed) onZoomChanged;

  @override
  State<_ZoomableImage> createState() => _ZoomableImageState();
}

class _ZoomableImageState extends State<_ZoomableImage>
    with SingleTickerProviderStateMixin {
  final _controller = TransformationController();
  late final AnimationController _animation = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 200),
  );
  Animation<Matrix4>? _reset;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTransform);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransform);
    _controller.dispose();
    _animation.dispose();
    super.dispose();
  }

  void _onTransform() =>
      widget.onZoomChanged(_controller.value.getMaxScaleOnAxis() > 1.02);

  /// Double-tap zooms to the point tapped, and zooms back out if already in.
  void _handleDoubleTap(TapDownDetails details) {
    final zoomedIn = _controller.value.getMaxScaleOnAxis() > 1.02;
    final target = zoomedIn
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..translateByDouble(
              -details.localPosition.dx * 1.6,
              -details.localPosition.dy * 1.6,
              0,
              1,
            )
            ..scaleByDouble(2.6, 2.6, 2.6, 1));

    _reset = Matrix4Tween(begin: _controller.value, end: target).animate(
      CurvedAnimation(parent: _animation, curve: Curves.easeOutCubic),
    )..addListener(() => _controller.value = _reset!.value);
    _animation.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: _handleDoubleTap,
      // The handler has to exist for onDoubleTapDown to fire.
      onDoubleTap: () {},
      child: InteractiveViewer(
        transformationController: _controller,
        minScale: 1,
        maxScale: 5,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: CachedNetworkImage(
              imageUrl: widget.url,
              fit: BoxFit.contain,
              placeholder: (context, _) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, _, _) => const Icon(
                Icons.image_not_supported_outlined,
                color: Colors.white54,
                size: 40,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
