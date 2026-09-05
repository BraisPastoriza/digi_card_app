import 'package:flutter/material.dart';

import '../../domain/models/card_enums.dart';

/// Accent colours for the seven card colours of the Digimon Card Game.
///
/// The values are tuned for legibility on the app's near-black surfaces rather
/// than being exact reproductions of the print colours: `black` in particular
/// has to read as a swatch on a dark background, so it becomes a cool grey.
abstract final class DigimonColors {
  static const red = Color(0xFFFF5A52);
  static const blue = Color(0xFF4B9BFF);
  static const yellow = Color(0xFFFFC940);
  static const green = Color(0xFF4ECB71);
  static const black = Color(0xFF8C8FA3);
  static const purple = Color(0xFFB77BFF);
  static const white = Color(0xFFF0EFEA);

  static Color of(CardColor color) => switch (color) {
    CardColor.red => red,
    CardColor.blue => blue,
    CardColor.yellow => yellow,
    CardColor.green => green,
    CardColor.black => black,
    CardColor.purple => purple,
    CardColor.white => white,
  };

  /// Gradient used for multi-colour cards, so a two-colour card reads as such
  /// at a glance in lists and deck stats.
  static LinearGradient gradientOf(List<CardColor> colors) {
    final swatches = colors.isEmpty
        ? const [Color(0xFF3A3A46), Color(0xFF3A3A46)]
        : colors.map(of).toList();
    return LinearGradient(
      colors: swatches.length == 1
          ? [swatches.first, swatches.first]
          : swatches,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }
}
