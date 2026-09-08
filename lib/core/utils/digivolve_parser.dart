import '../../domain/models/digimon_card.dart';

/// Extracts the alternative digivolution conditions printed in a card's effect
/// box.
///
/// A card's structured `digivolution-requirements` field carries only the
/// condition printed in the cost box at the top left — one level, one colour
/// set, one cost. Most of the interesting cards also print one or more *extra*
/// ways to digivolve as the first line of their effect text:
///
/// ```
/// Coronamon BT25-008
///   digivolution-requirements: [{level: 2, color: [blue, red], cost: 0}]
///   effect: "[Digivolve] Lv.2 w/[TS] trait: Cost 0\n[When Moving] ..."
/// ```
///
/// Neither card API models that second line as data — it is prose in the
/// effect text — so the Digivolution requirements section showed one condition
/// where the card prints two. Around 2,300 printed lines across the English
/// card pool are affected, counting the `[DNA Digivolve]` and
/// `[Burst Digivolve]` markers, which are the same kind of information and are
/// labelled rather than left out.
///
/// Parsing happens when a card is read out of the database rather than when it
/// is written, so the conditions appear without anyone having to re-download
/// the 25 MB card dump.
abstract final class DigivolveParser {
  /// The markers that open an alternative condition, with the qualifier that
  /// says which mechanic it is. Two cards print a second marker part-way
  /// through a line rather than on a line of its own, so these are found
  /// anywhere in the text and each one's condition runs up to the next.
  static final _marker = RegExp(r'\[(DNA |Burst )?Digivolve\]\s*');

  /// How a non-plain marker is introduced, so a condition that needs two
  /// Digimon at once is not read as one that needs one.
  static const _qualifierLabels = {
    'DNA ': 'DNA digivolve — ',
    'Burst ': 'Burst digivolve — ',
  };

  /// Splits a line that prints several conditions at once, e.g.
  /// `[Seraphimon]: Cost 1/[Sephirothmon] w/[Mercurymon] ...: Cost 4`.
  ///
  /// Only a slash that follows a complete `Cost N` separates two conditions;
  /// every other slash on the line joins alternatives *inside* one condition,
  /// as in `Lv.5 w/[X Antibody]/[DigiPolice] trait`.
  static final _conditionSplit = RegExp(r'(?<=Cost \d)\s*/\s*');

  /// `Lv.2 w/[TS] trait: Cost 0` — the modern printed form, with whatever
  /// follows the number captured so it can be judged.
  static final _withCost = RegExp(r'^(.*?):\s*Cost\s+(\d+)\s*(.*)$');

  /// Whether what follows the cost is the rules reminder the DNA cards print
  /// after their condition ("Stack the 2 specified Digimon and digivolve
  /// unsuspended."), rather than part of the condition itself.
  ///
  /// The reminder is a sentence and starts with a capital; a qualifier on the
  /// cost runs on from it in lower case — "Cost 1 for each of your security
  /// cards", "Cost 0 by returning 1 [Marcus Damon] to the hand". Cutting a
  /// qualifier off would print a flat cost the card does not charge, so those
  /// keep their whole line and no number.
  static final _rulesReminder = RegExp(r'^[A-Z]');

  /// `2 from [Armadillomon]` — the older form used by armour and DNA lines,
  /// which prints the cost first.
  static final _fromSource = RegExp(r'^(\d+)\s+from\s+(.+)$');

  /// `3 if name contains [Omnimon]`.
  static final _ifCondition = RegExp(r'^(\d+)\s+(if\s+.+)$');

  /// Where the effect text of the *next* ability got glued onto a condition
  /// with no line break. Three cards in the pool print it that way; without
  /// the cut their condition reads as a paragraph of unrelated rules text.
  static final _gluedEffect = RegExp(
    r'[＜<]|\[(?:On |When |Your Turn|All Turns|Opponent|Main\]|Security\]|'
    r'Start |End |Counter\]|Rule\]|Hand\])',
  );

  /// Every alternative digivolution condition [effect] prints, in printed
  /// order. Empty for the vast majority of cards, which print none.
  static List<DigivolveRequirement> alternativesIn(String? effect) {
    if (effect == null || !effect.contains('Digivolve]')) return const [];

    final requirements = <DigivolveRequirement>[];
    for (final line in effect.split('\n')) {
      final markers = _marker.allMatches(line).toList();
      for (var i = 0; i < markers.length; i++) {
        final end = i + 1 < markers.length ? markers[i + 1].start : line.length;
        final label = _qualifierLabels[markers[i].group(1)] ?? '';
        for (final condition
            in line.substring(markers[i].end, end).split(_conditionSplit)) {
          final requirement = _parseCondition(condition.trim(), label);
          if (requirement != null) requirements.add(requirement);
        }
      }
    }
    return requirements;
  }

  static DigivolveRequirement? _parseCondition(String condition, String label) {
    if (condition.isEmpty) return null;

    if (_withCost.firstMatch(condition) case final match?) {
      final trailing = match.group(3)!.trim();
      if (trailing.isEmpty || _rulesReminder.hasMatch(trailing)) {
        return DigivolveRequirement(
          text: '$label${match.group(1)!.trim()}',
          cost: int.parse(match.group(2)!),
          isAlternative: true,
        );
      }
    }

    if (_fromSource.firstMatch(condition) case final match?) {
      return DigivolveRequirement(
        text: '${label}From ${_untilGluedEffect(match.group(2)!)}',
        cost: int.parse(match.group(1)!),
        isAlternative: true,
      );
    }

    if (_ifCondition.firstMatch(condition) case final match?) {
      return DigivolveRequirement(
        text: '$label${_capitalize(_untilGluedEffect(match.group(2)!))}',
        cost: int.parse(match.group(1)!),
        isAlternative: true,
      );
    }

    // A shape nobody has printed yet. Showing the line as the card prints it
    // beats dropping a digivolution condition on the floor because a future
    // set worded it in a way this parser has not met.
    return DigivolveRequirement(text: '$label$condition', isAlternative: true);
  }

  static String _untilGluedEffect(String source) {
    final glued = _gluedEffect.firstMatch(source);
    final cut = glued == null ? source : source.substring(0, glued.start);
    return cut.trim();
  }

  static String _key(DigivolveRequirement requirement) =>
      '${requirement.describe()}@${requirement.cost}';

  static String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);

  /// [printed] plus the conditions in [effect], which together are every way a
  /// card can be digivolved into.
  ///
  /// The two lists never describe the same condition twice over, even when
  /// they share a cost. Checked against the 36 BT-25 cards where both sources
  /// have the card: every one of them prints a level and a colour in the cost
  /// box *and* a trait-based condition at the same cost in its effect box, and
  /// they are genuinely different routes — "Lv.3 yellow" is not "Lv.3 with the
  /// [TS] trait". So a cost the preview source publishes without the condition
  /// that goes with it stays its own row, saying what little is known, rather
  /// than being answered with a line of text that belongs to a different
  /// route.
  ///
  /// What is dropped is an exact repeat: a card whose effect restates a
  /// condition word for word contributes it once. The preview source repeats
  /// its digivolve line in two columns, so that is the common case.
  static List<DigivolveRequirement> allConditions({
    required List<DigivolveRequirement> printed,
    required String? effect,
  }) {
    final conditions = [...printed];
    final seen = {for (final condition in conditions) _key(condition)};
    for (final alternative in alternativesIn(effect)) {
      if (seen.add(_key(alternative))) conditions.add(alternative);
    }
    return conditions;
  }
}
