import 'package:collection/collection.dart';

import 'card_enums.dart';

/// How results are ordered.
enum CardSort {
  number('Card number'),
  nameAsc('Name A-Z'),
  costAsc('Cost, low to high'),
  costDesc('Cost, high to low'),
  dpDesc('DP, high to low'),
  levelAsc('Level, low to high');

  const CardSort(this.label);

  final String label;
}

/// Whether a card must carry every selected colour or just one of them.
enum ColorMatchMode {
  any('Any of'),
  all('All of'),
  exact('Exactly');

  const ColorMatchMode(this.label);

  final String label;
}

/// Whether a card must carry every selected value of a facet or just one of
/// them.
///
/// Colours keep their own [ColorMatchMode] because a card can also be printed
/// in *exactly* the colours asked for, which a card's traits and keywords —
/// open-ended lists — have no equivalent of.
enum MatchMode {
  any('Any of'),
  all('All of');

  const MatchMode(this.label);

  final String label;
}

/// How a search treats token cards.
///
/// Tokens belong in the library — they are printed with the sets and players
/// look them up — but they can never go in a deck, so the deck builder
/// searches with [exclude] whatever the user has filtered on.
enum TokenMode {
  /// Tokens appear alongside everything else. The library's default.
  include,

  /// Only tokens, which is what the Card type filter's Token chip asks for.
  only,

  /// No tokens at all.
  exclude,
}

/// A closed numeric range. Both ends are optional and inclusive.
class RangeFilter {
  const RangeFilter({this.min, this.max});

  final int? min;
  final int? max;

  bool get isEmpty => min == null && max == null;

  String describe(String label) {
    if (min != null && max != null) {
      return min == max ? '$label $min' : '$label $min-$max';
    }
    if (min != null) return '$label $min+';
    return '$label ≤$max';
  }

  RangeFilter copyWith({
    int? min,
    int? max,
    bool clearMin = false,
    bool clearMax = false,
  }) => RangeFilter(
    min: clearMin ? null : (min ?? this.min),
    max: clearMax ? null : (max ?? this.max),
  );

  @override
  bool operator ==(Object other) =>
      other is RangeFilter && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);
}

/// Every search option the library exposes. Built up by the filter sheet and
/// translated into SQL by `CardDao`.
class CardFilter {
  const CardFilter({
    this.query = '',
    this.colors = const {},
    this.colorMatchMode = ColorMatchMode.any,
    this.categories = const {},
    this.levels = const {},
    this.rarities = const {},
    this.traits = const {},
    this.traitMatchMode = MatchMode.any,
    this.keywords = const {},
    this.keywordMatchMode = MatchMode.any,
    this.forms = const {},
    this.attributes = const {},
    this.releaseIds = const {},
    this.cardNumbers = const {},
    this.playCost = const RangeFilter(),
    this.digivolveCost = const RangeFilter(),
    this.dp = const RangeFilter(),
    this.includeAlternateArts = false,
    this.restrictedOnly = false,
    this.aceOnly = false,
    this.dualOnly = false,
    this.tokens = TokenMode.include,
    this.sort = CardSort.number,
  });

  /// Free text matched against name, effect text and traits.
  final String query;

  final Set<CardColor> colors;
  final ColorMatchMode colorMatchMode;
  final Set<CardCategory> categories;
  final Set<int> levels;
  final Set<String> rarities;
  final Set<String> traits;

  /// Whether a card needs all the selected traits or any one of them. A deck
  /// is built out of cards that are, say, both Dragon *and* Vaccine, which an
  /// "any of" search buries under everything that is only one of the two.
  final MatchMode traitMatchMode;

  final Set<String> keywords;
  final MatchMode keywordMatchMode;
  final Set<String> forms;
  final Set<String> attributes;
  final Set<String> releaseIds;

  /// Restricts the search to these printed card numbers, or the whole library
  /// when empty.
  ///
  /// This is the *source* being searched rather than a facet the user picked:
  /// it is how the deck builder narrows a search to one staple list, so it
  /// carries no chip, does not count towards [activeFacetCount], and survives
  /// [clearedFacets] — clearing the filters inside a list should leave you in
  /// the list.
  final Set<String> cardNumbers;

  /// Play cost for Digimon and Tamers, use cost for Options.
  final RangeFilter playCost;

  /// Cost paid to digivolve into the card, from its digivolution requirements.
  final RangeFilter digivolveCost;

  final RangeFilter dp;

  /// When false, only base printings are returned and alternate arts are
  /// folded into their card's detail screen.
  final bool includeAlternateArts;

  /// Limits results to cards on the official restriction list.
  final bool restrictedOnly;

  /// ACE and dual cards cut across the four printed card types rather than
  /// being types of their own, so they narrow the results instead of widening
  /// them the way a second category chip would.
  final bool aceOnly;
  final bool dualOnly;

  /// Whether tokens are searched for, ignored, or the only thing wanted.
  final TokenMode tokens;

  final CardSort sort;

  bool get isEmpty =>
      query.trim().isEmpty &&
      colors.isEmpty &&
      categories.isEmpty &&
      levels.isEmpty &&
      rarities.isEmpty &&
      traits.isEmpty &&
      keywords.isEmpty &&
      forms.isEmpty &&
      attributes.isEmpty &&
      releaseIds.isEmpty &&
      cardNumbers.isEmpty &&
      playCost.isEmpty &&
      digivolveCost.isEmpty &&
      dp.isEmpty &&
      !includeAlternateArts &&
      !restrictedOnly &&
      !aceOnly &&
      !dualOnly &&
      tokens == TokenMode.include;

  /// Number of active facets, shown as a badge on the filter button.
  int get activeFacetCount => [
    colors.isNotEmpty,
    categories.isNotEmpty,
    levels.isNotEmpty,
    rarities.isNotEmpty,
    traits.isNotEmpty,
    keywords.isNotEmpty,
    forms.isNotEmpty,
    attributes.isNotEmpty,
    releaseIds.isNotEmpty,
    !playCost.isEmpty,
    !digivolveCost.isEmpty,
    !dp.isEmpty,
    includeAlternateArts,
    restrictedOnly,
    aceOnly,
    dualOnly,
    tokens != TokenMode.include,
  ].where((active) => active).length;

  /// Short labels for the active facets, rendered as removable chips.
  List<String> describeFacets() => [
    if (colors.isNotEmpty)
      '${colorMatchMode.label} ${colors.map((c) => c.label).join(', ')}',
    ...categories.map((c) => c.label),
    if (levels.isNotEmpty)
      'Lv. ${levels.sorted((a, b) => a.compareTo(b)).join(', ')}',
    ...rarities,
    ...traits,
    ...keywords,
    ...forms,
    ...attributes,
    if (!playCost.isEmpty) playCost.describe('Cost'),
    if (!digivolveCost.isEmpty) digivolveCost.describe('Digivolve'),
    if (!dp.isEmpty) dp.describe('DP'),
    if (aceOnly) 'ACE',
    if (dualOnly) 'Dual Card',
    if (tokens == TokenMode.only) 'Token',
    if (includeAlternateArts) 'Alternate arts',
    if (restrictedOnly) 'Restricted',
  ];

  CardFilter copyWith({
    String? query,
    Set<CardColor>? colors,
    ColorMatchMode? colorMatchMode,
    Set<CardCategory>? categories,
    Set<int>? levels,
    Set<String>? rarities,
    Set<String>? traits,
    MatchMode? traitMatchMode,
    Set<String>? keywords,
    MatchMode? keywordMatchMode,
    Set<String>? forms,
    Set<String>? attributes,
    Set<String>? releaseIds,
    Set<String>? cardNumbers,
    RangeFilter? playCost,
    RangeFilter? digivolveCost,
    RangeFilter? dp,
    bool? includeAlternateArts,
    bool? restrictedOnly,
    bool? aceOnly,
    bool? dualOnly,
    TokenMode? tokens,
    CardSort? sort,
  }) => CardFilter(
    query: query ?? this.query,
    colors: colors ?? this.colors,
    colorMatchMode: colorMatchMode ?? this.colorMatchMode,
    categories: categories ?? this.categories,
    levels: levels ?? this.levels,
    rarities: rarities ?? this.rarities,
    traits: traits ?? this.traits,
    traitMatchMode: traitMatchMode ?? this.traitMatchMode,
    keywords: keywords ?? this.keywords,
    keywordMatchMode: keywordMatchMode ?? this.keywordMatchMode,
    forms: forms ?? this.forms,
    attributes: attributes ?? this.attributes,
    releaseIds: releaseIds ?? this.releaseIds,
    cardNumbers: cardNumbers ?? this.cardNumbers,
    playCost: playCost ?? this.playCost,
    digivolveCost: digivolveCost ?? this.digivolveCost,
    dp: dp ?? this.dp,
    includeAlternateArts: includeAlternateArts ?? this.includeAlternateArts,
    restrictedOnly: restrictedOnly ?? this.restrictedOnly,
    aceOnly: aceOnly ?? this.aceOnly,
    dualOnly: dualOnly ?? this.dualOnly,
    tokens: tokens ?? this.tokens,
    sort: sort ?? this.sort,
  );

  /// Clears every facet but keeps the text query and sort, which the search
  /// bar owns, and the card numbers being searched, which are the source
  /// rather than a filter.
  CardFilter clearedFacets() =>
      CardFilter(query: query, sort: sort, cardNumbers: cardNumbers);

  /// One chip per value when any of them will do, and a single chip naming
  /// the mode when every one of them is required — "All of Dragon, Vaccine"
  /// reads as the one condition it is, so it comes off as one.
  List<FacetChip> _valueFacets(
    Set<String> values,
    MatchMode mode,
    CardFilter Function(Set<String>) replaced,
  ) => mode == MatchMode.all && values.length > 1
      ? [FacetChip('${mode.label} ${values.join(', ')}', replaced(const {}))]
      : [
          for (final value in values)
            FacetChip(value, replaced(_without(values, value))),
        ];

  static Set<T> _without<T>(Set<T> values, T value) =>
      values.where((v) => v != value).toSet();

  // Structural equality, so a filter can key a provider family without a new
  // provider being created on every rebuild.
  static const _sets = SetEquality<Object?>();

  @override
  bool operator ==(Object other) =>
      other is CardFilter &&
      other.query == query &&
      other.colorMatchMode == colorMatchMode &&
      other.traitMatchMode == traitMatchMode &&
      other.keywordMatchMode == keywordMatchMode &&
      other.playCost == playCost &&
      other.digivolveCost == digivolveCost &&
      other.dp == dp &&
      other.includeAlternateArts == includeAlternateArts &&
      other.restrictedOnly == restrictedOnly &&
      other.aceOnly == aceOnly &&
      other.dualOnly == dualOnly &&
      other.tokens == tokens &&
      other.sort == sort &&
      _sets.equals(other.colors, colors) &&
      _sets.equals(other.categories, categories) &&
      _sets.equals(other.levels, levels) &&
      _sets.equals(other.rarities, rarities) &&
      _sets.equals(other.traits, traits) &&
      _sets.equals(other.keywords, keywords) &&
      _sets.equals(other.forms, forms) &&
      _sets.equals(other.attributes, attributes) &&
      _sets.equals(other.releaseIds, releaseIds) &&
      _sets.equals(other.cardNumbers, cardNumbers);

  @override
  // `hashAll` rather than `hash`, which takes at most 20 values.
  int get hashCode => Object.hashAll([
    query,
    colorMatchMode,
    traitMatchMode,
    keywordMatchMode,
    playCost,
    digivolveCost,
    dp,
    includeAlternateArts,
    restrictedOnly,
    aceOnly,
    dualOnly,
    tokens,
    sort,
    _sets.hash(colors),
    _sets.hash(categories),
    _sets.hash(levels),
    _sets.hash(rarities),
    _sets.hash(traits),
    _sets.hash(keywords),
    _sets.hash(forms),
    _sets.hash(attributes),
    _sets.hash(releaseIds),
    _sets.hash(cardNumbers),
  ]);
}
