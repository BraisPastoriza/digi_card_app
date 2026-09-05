import 'package:flutter/material.dart';

import '../../core/theme/digimon_colors.dart';

/// Renders printed card text with the game's own typographic conventions.
///
/// Card text mixes three kinds of token that players read differently, and
/// running them together as plain text makes rules hard to scan:
///  * `[Main]`, `[When Digivolving]` — timings and named cards, in brackets
///  * `＜Blocker＞` — keywords, in angle brackets
///  * `(reminder text)` — restatements of rules, safe to skip when reading
class GameText extends StatelessWidget {
  const GameText(this.text, {super.key, this.fontSize = 14});

  final String text;
  final double fontSize;

  static final _token = RegExp(
    r'(\[[^\[\]\n]{1,60}\])'
    r'|([＜<〈⟨][^＞>〉⟩\n]{1,60}[＞>〉⟩])'
    r'|(\([^()\n]{0,200}\))',
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = TextStyle(
      fontSize: fontSize,
      height: 1.5,
      color: scheme.onSurface,
    );

    final spans = <TextSpan>[];
    var index = 0;
    for (final match in _token.allMatches(text)) {
      if (match.start > index) {
        spans.add(TextSpan(text: text.substring(index, match.start)));
      }
      final token = match.group(0)!;
      spans.add(
        TextSpan(
          text: token,
          style: switch (match) {
            _ when match.group(1) != null => TextStyle(
              fontWeight: FontWeight.w700,
              color: scheme.primary,
            ),
            _ when match.group(2) != null => const TextStyle(
              fontWeight: FontWeight.w700,
              color: DigimonColors.yellow,
            ),
            _ => TextStyle(
              color: scheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          },
        ),
      );
      index = match.end;
    }
    if (index < text.length) {
      spans.add(TextSpan(text: text.substring(index)));
    }

    return Text.rich(TextSpan(style: base, children: spans));
  }
}
