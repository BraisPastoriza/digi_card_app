import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'card_thumbnail.dart';

/// The app's mark: two cards on the brand gradient.
///
/// This is the single definition of the artwork. `tool/generate_app_icon.dart`
/// rasterises the launcher icon from these same routines, so the icon on the
/// home screen and the mark inside the app cannot drift apart — which they did
/// when the mark was a Material icon that merely resembled the launcher art.
abstract final class AppLogoArt {
  static const gradientStart = AppTheme.seed;
  static const gradientEnd = Color(0xFFFF5A52);

  /// The dark the cards are cut out in — the theme's `onPrimary`.
  static const ink = Color(0xFF261200);

  /// Fraction of an adaptive icon's 108dp canvas that is guaranteed visible
  /// whatever mask the launcher applies.
  static const adaptiveSafeFraction = 66 / 108;

  /// Corner rounding of the mark, as a fraction of its size.
  static const cornerFraction = 0.225;

  /// Fills the canvas with the brand gradient.
  static void paintGradient(Canvas canvas, double size, {double radius = 0}) {
    final bounds = Rect.fromLTWH(0, 0, size, size);
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [gradientStart, gradientEnd],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(bounds);
    if (radius == 0) {
      canvas.drawRect(bounds, paint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(bounds, Radius.circular(radius)),
        paint,
      );
    }
  }

  /// Two cards, one tucked behind the other.
  ///
  /// [extent] is the width the pair may occupy, centred on the canvas. The
  /// back card is drawn at reduced opacity rather than outlined, so the pair
  /// still reads as two cards at 48px where an outline would vanish.
  static void paintCards(
    Canvas canvas,
    double size,
    double extent, {
    Color color = ink,
  }) {
    final cardWidth = extent * 0.62;
    final cardHeight = cardWidth / cardAspectRatio;
    final radius = Radius.circular(cardWidth * 0.13);
    final centre = Offset(size / 2, size / 2);

    void card(
      double degrees,
      Offset offset,
      double opacity, {
      bool art = false,
    }) {
      canvas
        ..save()
        ..translate(centre.dx + offset.dx, centre.dy + offset.dy)
        ..rotate(degrees * math.pi / 180);

      final body = Rect.fromCenter(
        center: Offset.zero,
        width: cardWidth,
        height: cardHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(body, radius),
        Paint()..color = color.withValues(alpha: opacity),
      );

      // The art window and the text box below it are what make the silhouette
      // read as a card rather than a rounded rectangle — it is the anatomy of
      // every card in the game. Both are cut out rather than painted in a
      // second colour, so the monochrome launcher layer keeps the same shape
      // and the background shows through on every variant.
      if (art) {
        final cut = Paint()..blendMode = BlendMode.clear;
        final inset = cardWidth * 0.13;

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(
              body.left + inset,
              body.top + inset,
              body.right - inset,
              body.top + cardHeight * 0.46,
            ),
            Radius.circular(cardWidth * 0.06),
          ),
          cut,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(
              body.left + inset,
              body.top + cardHeight * 0.58,
              body.right - inset,
              body.top + cardHeight * 0.74,
            ),
            Radius.circular(cardWidth * 0.05),
          ),
          cut,
        );
      }
      canvas.restore();
    }

    // Drawn into a layer so the cut-outs punch straight through the card and
    // let whatever is behind it show through.
    canvas.saveLayer(Rect.fromLTWH(0, 0, size, size), Paint());
    card(-17, Offset(-extent * 0.13, -extent * 0.02), 0.38);
    card(9, Offset(extent * 0.07, extent * 0.02), 1, art: true);
    canvas.restore();
  }
}

/// The app's mark, drawn at [size].
///
/// The same artwork as the launcher icon, so the screen that greets a first
/// run shows the icon the user just tapped.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _AppLogoPainter()),
    );
  }
}

class _AppLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    AppLogoArt.paintGradient(
      canvas,
      side,
      radius: side * AppLogoArt.cornerFraction,
    );
    AppLogoArt.paintCards(canvas, side, side * 0.72);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
