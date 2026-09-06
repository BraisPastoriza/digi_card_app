import 'dart:convert';

import '../../core/utils/keyword_parser.dart';
import '../../domain/models/card_enums.dart';
import '../../domain/models/card_release.dart';
import '../../domain/models/digimon_card.dart';
import 'bulk_parser.dart';

/// Turns digimoncard.io's flat card rows into the same [ParsedCard] the
/// primary source produces, so the rest of the sync cannot tell them apart.
///
/// The two schemas do not line up, and the gaps are deliberate rather than
/// oversights. What this source does not carry at all:
///
///  * **Alternate arts.** Their card `id` is the printed number, with no
///    parallel marker, and the rows repeat instead. Every card here is
///    therefore a single base printing.
///  * **The restriction list, rulings and errata.** A brand-new set has no
///    restrictions yet, so the copy limit falls back to the printed four.
///  * **Block icon and supplemental rarity.** No equivalent field.
///  * **The Option face of a dual card.** Their row has the Digimon face only,
///    so the card is filed as a Digimon that also answers an Option type
///    filter, and the dual-card facet will not match it.
///
/// And the fields that need work rather than a straight copy are commented
/// where they are read.
List<ParsedCard> parseDigimonCardIoPack(
  List<Map<String, dynamic>> rows,
  PreviewRelease release,
) {
  final byNumber = <String, ParsedCard>{};
  for (final row in rows) {
    final card = _parseRow(row, release);
    // Their API repeats a card once per printing without saying which is
    // which, so the first row for a number is the one that is kept.
    if (card != null) byNumber.putIfAbsent(card.number, () => card);
  }
  return byNumber.values.toList();
}

ParsedCard? _parseRow(Map<String, dynamic> row, PreviewRelease release) {
  final number = (row['id'] as String?)?.trim();
  if (number == null || number.isEmpty) return null;

  final type = (row['type'] as String?)?.trim() ?? '';
  final category = _category(type);

  // Their schema splits what the primary source prints as one block of effect
  // text across three columns: the digivolve line lives in `xros_req` or
  // `alt_effect`, the rest in `main_effect`. Rejoining them in printed order
  // is what makes the two sources read alike on the card screen.
  final effect = _joinLines([
    _text(row['xros_req']),
    _text(row['alt_effect']),
    _text(row['main_effect']),
  ]);

  // `source_effect` carries the inherited effect for Digimon and the security
  // effect for Options and Tamers, in the same column. The printed
  // `[Security]` marker says which, and is more reliable than guessing from
  // the card type.
  final source = _sourceEffect(row['source_effect']);
  final isSecurity = source != null && source.startsWith('[Security]');
  final inheritedEffect = isSecurity ? null : source;
  final securityEffect = isSecurity ? source : null;

  final playCost = _int(row['play_cost']);
  final isOption = category == CardCategory.option;

  final requirements = _digivolveRequirements(row);
  final requirementCosts = requirements
      .map((r) => r.cost)
      .whereType<int>()
      .toList();

  final ruleCopyLimit = CopyLimit.fromRuleText([
    effect,
    inheritedEffect,
    securityEffect,
  ]);

  return ParsedCard(
    // With no parallel marker there is one printing per number, and the id
    // the app keys printings by can simply be the number.
    id: number,
    number: number,
    parallelId: 0,
    isPrimary: true,
    name: _text(row['name']) ?? number,
    category: category.apiValue,
    colors: _colors(row),
    imageUrl: cardImageUrl(number),
    traits: _traits(row),
    keywords: KeywordParser.extract([effect, inheritedEffect, securityEffect]),
    releaseIds: [release.id],
    numberSort: buildNumberSort(number, 0),
    copyLimit: CopyLimit.resolve(
      limitations: const [],
      ruleLimit: ruleCopyLimit,
    ),
    ruleCopyLimit: ruleCopyLimit,
    digivolutionRequirements: jsonEncode([
      for (final requirement in requirements) requirement.toJson(),
    ]),
    faqs: '[]',
    limitations: '[]',
    rarity: CardRarity.normalize(
      _text(row['rarity']),
      isToken: TokenCard.hasTokenNumber(number),
    ),
    level: _int(row['level']),
    // Their `play_cost` is the cost printed on the card whatever the type,
    // while the app keeps an Option's cost in `useCost` so one "cost" column
    // can serve every category.
    playCost: isOption ? null : playCost,
    useCost: isOption ? playCost : null,
    cost: playCost,
    dp: _int(row['dp']),
    form: _text(row['form']) ?? _text(row['stage']),
    attribute: _text(row['attribute']),
    effect: effect,
    inheritedEffect: inheritedEffect,
    securityEffect: securityEffect,
    digivolveCostMin: requirementCosts.isEmpty
        ? null
        : requirementCosts.reduce((a, b) => a < b ? a : b),
    digivolveCostMax: requirementCosts.isEmpty
        ? null
        : requirementCosts.reduce((a, b) => a > b ? a : b),
    notes: release.name,
    // A dual card's Option face is not in their data, but recording that it
    // has one keeps the card answering an Option type filter, which is how
    // players look for it.
    dualCategory: type == 'Dual' ? CardCategory.option.apiValue : null,
  );
}

/// Where the secondary source keeps its card images.
///
/// Their API returns no image field; this path is their site's own convention
/// and is the one part of the integration that is not documented.
String cardImageUrl(String number) =>
    'https://images.digimoncard.io/images/cards/$number.jpg';

/// Their `type` column, mapped onto the four printed card types.
///
/// `Dual` is a fifth value they use for the cards that are a Digimon on one
/// face and an Option on the other. The app files those under the Digimon
/// face, the same way it does for the primary source.
CardCategory _category(String type) => switch (type.toLowerCase()) {
  'digi-egg' => CardCategory.digiEgg,
  'tamer' => CardCategory.tamer,
  'option' => CardCategory.option,
  _ => CardCategory.digimon,
};

List<String> _colors(Map<String, dynamic> row) => [
  for (final key in const ['color', 'color2'])
    ?CardColor.tryParse(_text(row[key]))?.apiValue,
];

List<String> _traits(Map<String, dynamic> row) => CardTrait.normalizeAll([
  for (final key in const [
    'digi_type',
    'digi_type2',
    'digi_type3',
    'digi_type4',
    'digi_type5',
  ])
    ?_text(row[key]),
]);

/// One requirement built from their three evolution columns.
///
/// They keep a single structured condition per card; the alternate digivolve
/// lines a card may also print stay in the effect text, where they are
/// readable even though the cost filter cannot see them.
List<DigivolveRequirement> _digivolveRequirements(Map<String, dynamic> row) {
  final cost = _int(row['evolution_cost']);
  final level = _int(row['evolution_level']);
  final color = CardColor.tryParse(_text(row['evolution_color']));
  if (cost == null && level == null && color == null) return const [];
  return [
    DigivolveRequirement(
      level: level,
      cost: cost,
      colors: [?color],
      category: CardCategory.digimon,
    ),
  ];
}

/// Drops the wiki template fragments that leak into this column.
///
/// A quarter of the BT-26 rows carry the literal string `|applinkdp =` here
/// instead of an inherited effect. Anything starting with a pipe is that
/// leakage rather than card text.
String? _sourceEffect(Object? raw) {
  final text = _text(raw);
  if (text == null || text.startsWith('|')) return null;
  return text;
}

/// Trims a value and normalises the CRLF line endings their columns use, so
/// card text from the two sources renders identically.
String? _text(Object? raw) {
  if (raw == null) return null;
  final text = raw.toString().replaceAll('\r\n', '\n').trim();
  return text.isEmpty ? null : text;
}

String? _joinLines(List<String?> parts) {
  final lines = parts.whereType<String>().toList();
  return lines.isEmpty ? null : lines.join('\n');
}

int? _int(Object? raw) => switch (raw) {
  final int value => value,
  final String value => int.tryParse(value.trim()),
  _ => null,
};
