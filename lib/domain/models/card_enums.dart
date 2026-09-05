/// The colour identity of a card. A card may have more than one.
enum CardColor {
  red('red', 'Red'),
  blue('blue', 'Blue'),
  yellow('yellow', 'Yellow'),
  green('green', 'Green'),
  black('black', 'Black'),
  purple('purple', 'Purple'),
  white('white', 'White');

  const CardColor(this.apiValue, this.label);

  final String apiValue;
  final String label;

  static CardColor? tryParse(String? value) {
    if (value == null) return null;
    final normalized = value.toLowerCase().trim();
    for (final color in values) {
      if (color.apiValue == normalized) return color;
    }
    return null;
  }
}

/// The card type, which decides whether a card belongs to the egg deck or the
/// main deck.
enum CardCategory {
  digimon('digimon', 'Digimon'),
  tamer('tamer', 'Tamer'),
  option('option', 'Option'),
  digiEgg('digi-egg', 'Digi-Egg');

  const CardCategory(this.apiValue, this.label);

  final String apiValue;
  final String label;

  /// Digi-Eggs live in the 5-card egg deck; everything else in the 50-card
  /// main deck.
  bool get isEggDeck => this == CardCategory.digiEgg;

  static CardCategory? tryParse(String? value) {
    if (value == null) return null;
    final normalized = value.toLowerCase().trim();
    for (final category in values) {
      if (category.apiValue == normalized) return category;
    }
    return null;
  }
}

/// How a card is limited by the official restriction list.
enum LimitationType {
  restrict('restrict', 'Restricted', 1),
  ban('ban', 'Banned', 0),
  bannedPair('banned-pair', 'Banned Pair', 0),
  unrestrict('unrestrict', 'Unrestricted', 4);

  const LimitationType(this.apiValue, this.label, this.allowance);

  final String apiValue;
  final String label;

  /// Copies allowed of this card number once the limitation applies.
  final int allowance;

  static LimitationType? tryParse(String? value) {
    if (value == null) return null;
    final normalized = value.toLowerCase().trim();
    for (final type in values) {
      if (type.apiValue == normalized) return type;
    }
    return null;
  }
}

/// Grouping used by the library's expansion list. Derived from the release id
/// because the API's own `genre` field does not separate BT/EX/ST/AD/LM.
enum ReleaseGroup {
  booster('Booster Packs'),
  ex('EX Boosters'),
  starter('Starter Decks'),
  advanceDeck('Advanced Decks'),
  limited('Limited Card Packs'),
  resurgence('Resurgence Boosters'),
  promo('Promotional Cards'),
  other('Other Products');

  const ReleaseGroup(this.label);

  final String label;
}
