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

/// The printed rarity codes, least rare first.
///
/// The filter lists rarities in this order rather than alphabetically, which
/// would read C, P, R, SEC, SR, U, UR and put the two rarest codes in the
/// middle of the row.
abstract final class CardRarity {
  static const order = ['C', 'U', 'R', 'SR', 'UR', 'SEC', 'P'];

  /// What an unrecognised rarity is stored as.
  static const fallback = 'R';

  /// The rarity to store for [raw], or null when the card has none.
  ///
  /// Tokens never have one. They are not collected, so no rarity is printed on
  /// them — six of the seven arrive with the field empty and the seventh,
  /// BT24-TOKEN, carries a stray Japanese word.
  ///
  /// Otherwise anything outside [order] becomes [fallback] rather than a
  /// rarity of its own: a BT-26 Tamer printed R arrives as `RC`, and giving a
  /// bad value its own entry would put a filter chip in front of the user that
  /// matches a single card.
  static String? normalize(String? raw, {bool isToken = false}) {
    if (isToken) return null;
    final rarity = raw?.trim();
    if (rarity == null || rarity.isEmpty) return null;
    final code = rarity.toUpperCase();
    return order.contains(code) ? code : fallback;
  }

  /// Position in [order]; codes the game has not printed yet sort last.
  static int rank(String rarity) {
    final index = order.indexOf(rarity.toUpperCase());
    return index < 0 ? order.length : index;
  }

  static int compare(String a, String b) =>
      switch (rank(a).compareTo(rank(b))) {
        0 => a.compareTo(b),
        final other => other,
      };
}

/// Tokens are printed as Digimon and ship with the sets, but they are created
/// by card effects during play rather than collected, so several things the
/// rest of the cards have do not apply to them.
///
/// Nothing in the card data marks one: the printed number is the only tell,
/// either `TOKEN` on its own or a set code followed by it.
abstract final class TokenCard {
  static final _number = RegExp(r'(?:^|-)TOKEN', caseSensitive: false);

  static bool hasTokenNumber(String number) => _number.hasMatch(number);
}

/// Normalises the printed trait vocabulary, which the two card sources spell
/// inconsistently enough to split one trait into several filter options.
abstract final class CardTrait {
  /// Appmon traits arrive from the secondary source with a qualifier the
  /// printed card does not carry: `Tweet (App Name)` rather than `Tweet`.
  /// Dropping it also merges them with the same traits published plainly.
  static final _appNameQualifier = RegExp(
    r'\s*\(\s*App\s+Name\s*\)\s*$',
    caseSensitive: false,
  );

  /// Spellings that are the same trait under two names. The X Antibody trait
  /// is printed without a hyphen, but a minority of entries hyphenate it.
  static const _synonyms = {'x-antibody': 'X Antibody'};

  /// The trait [raw] names, or null if there is nothing left of it.
  static String? normalize(String raw) {
    final trait = raw.replaceAll(_appNameQualifier, '').trim();
    if (trait.isEmpty) return null;
    return _synonyms[trait.toLowerCase()] ?? trait;
  }

  /// Every trait in [raw] values, normalised, in order and without repeats —
  /// normalising can make two entries on one card collapse into one.
  static List<String> normalizeAll(Iterable<String> raw) {
    final traits = <String>{};
    for (final value in raw) {
      final trait = normalize(value);
      if (trait != null) traits.add(trait);
    }
    return traits.toList();
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
  advanceDeck('Advanced Boosters'),
  limited('Limited Card Packs'),
  resurgence('Resurgence Boosters'),
  promo('Promotional Cards'),
  other('Other Products');

  const ReleaseGroup(this.label);

  final String label;
}
