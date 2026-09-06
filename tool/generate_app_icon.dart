// Writes the app's launcher icon in every size each platform needs.
//
// The artwork itself lives in lib/shared/widgets/app_logo.dart, which is also
// what the app paints on its first-run screen. This file only decides the
// framing each platform wants — rounded, square, or inside an adaptive icon's
// safe zone — so the icon on the home screen and the mark inside the app are
// the same drawing rather than two that happen to look alike.
//
// It is deliberately original artwork: two card silhouettes on the app's own
// gradient. The Digimon Card Game logo is a Bandai trademark and putting it on
// a launcher icon would claim an affiliation this app explicitly disclaims.
//
// Run it with the Flutter test harness, which is what provides a real engine
// to rasterise with:
//
//     flutter test tool/generate_app_icon.dart
//
// Committing the generated PNGs is intended; this only reruns when the mark
// changes.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:digi_card_app/shared/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generate app icons', () async {
    // Android: legacy square icons, plus the adaptive layers modern launchers
    // mask into whatever shape the device uses.
    const androidDensities = {
      'mdpi': 1.0,
      'hdpi': 1.5,
      'xhdpi': 2.0,
      'xxhdpi': 3.0,
      'xxxhdpi': 4.0,
    };
    for (final entry in androidDensities.entries) {
      final dir = 'android/app/src/main/res/mipmap-${entry.key}';
      await _write(
        '$dir/ic_launcher.png',
        (48 * entry.value).round(),
        _LegacyIcon(),
      );
      await _write(
        '$dir/ic_launcher_foreground.png',
        (108 * entry.value).round(),
        _AdaptiveForeground(),
      );
      await _write(
        '$dir/ic_launcher_monochrome.png',
        (108 * entry.value).round(),
        _AdaptiveForeground(monochrome: true),
      );
    }

    // iOS wants opaque squares with no rounding of their own; the system
    // applies the mask.
    const iosSizes = {
      'Icon-App-20x20@1x': 20,
      'Icon-App-20x20@2x': 40,
      'Icon-App-20x20@3x': 60,
      'Icon-App-29x29@1x': 29,
      'Icon-App-29x29@2x': 58,
      'Icon-App-29x29@3x': 87,
      'Icon-App-40x40@1x': 40,
      'Icon-App-40x40@2x': 80,
      'Icon-App-40x40@3x': 120,
      'Icon-App-60x60@2x': 120,
      'Icon-App-60x60@3x': 180,
      'Icon-App-76x76@1x': 76,
      'Icon-App-76x76@2x': 152,
      'Icon-App-83.5x83.5@2x': 167,
      'Icon-App-1024x1024@1x': 1024,
    };
    for (final entry in iosSizes.entries) {
      await _write(
        'ios/Runner/Assets.xcassets/AppIcon.appiconset/${entry.key}.png',
        entry.value,
        _SquareIcon(),
      );
    }

    // Web: the plain icons are rounded like the Android legacy one, while the
    // maskable pair keeps its art inside the safe zone browsers crop to.
    await _write('web/favicon.png', 64, _LegacyIcon());
    await _write('web/icons/Icon-192.png', 192, _LegacyIcon());
    await _write('web/icons/Icon-512.png', 512, _LegacyIcon());
    await _write('web/icons/Icon-maskable-192.png', 192, _MaskableIcon());
    await _write('web/icons/Icon-maskable-512.png', 512, _MaskableIcon());
  });
}

Future<void> _write(String path, int size, _IconPainter painter) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  painter.paint(canvas, size.toDouble());
  final image = await recorder.endRecording().toImage(size, size);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  image.dispose();

  final file = File(path);
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(data!.buffer.asUint8List());
}

abstract class _IconPainter {
  void paint(Canvas canvas, double size);
}

/// Full-bleed rounded square, for Android's legacy icon and the web.
class _LegacyIcon extends _IconPainter {
  @override
  void paint(Canvas canvas, double size) {
    AppLogoArt.paintGradient(
      canvas,
      size,
      radius: size * AppLogoArt.cornerFraction,
    );
    AppLogoArt.paintCards(canvas, size, size * 0.72);
  }
}

/// Square with no rounding, for iOS.
class _SquareIcon extends _IconPainter {
  @override
  void paint(Canvas canvas, double size) {
    AppLogoArt.paintGradient(canvas, size);
    AppLogoArt.paintCards(canvas, size, size * 0.72);
  }
}

/// Rounded square whose art stays inside the area a maskable icon guarantees.
class _MaskableIcon extends _IconPainter {
  @override
  void paint(Canvas canvas, double size) {
    AppLogoArt.paintGradient(
      canvas,
      size,
      radius: size * AppLogoArt.cornerFraction,
    );
    AppLogoArt.paintCards(
      canvas,
      size,
      size * 0.8 * AppLogoArt.adaptiveSafeFraction,
    );
  }
}

/// The cards alone on a transparent canvas, for Android's adaptive foreground.
///
/// The background is a gradient drawable rather than a second bitmap, so the
/// launcher can shift the layers apart without exposing an edge.
class _AdaptiveForeground extends _IconPainter {
  _AdaptiveForeground({this.monochrome = false});

  /// Android 13 themed icons recolour the layer, so only its alpha matters.
  final bool monochrome;

  @override
  void paint(Canvas canvas, double size) {
    // Just inside the safe zone rather than well inside it: a circular mask
    // crops to 72 of the 108dp canvas, and art sized for the square looks
    // marooned once the launcher rounds it off.
    AppLogoArt.paintCards(
      canvas,
      size,
      size * 0.98 * AppLogoArt.adaptiveSafeFraction,
      color: monochrome ? const Color(0xFF000000) : AppLogoArt.ink,
    );
  }
}
