import 'package:collection/collection.dart';

import 'card_enums.dart';

/// One requirement line from a card's digivolution conditions, e.g.
/// "Lv.3 red — cost 2".
class DigivolveRequirement {
  const DigivolveRequirement({
    this.level,
    this.form,
    this.cost,
    this.category,
    this.colors = const [],
    this.text,
    this.isAlternative = false,
  });

  final int? level;

  /// The Appmon grade a condition names in place of a level, e.g. `ultimate`.
  ///
  /// Appmon digivolve by grade rather than by level, so the primary source
  /// leaves `level` null on those 61 requirements and fills this instead.
  final String? form;

  final int? cost;
  final CardCategory? category;
  final List<CardColor> colors;

  /// Free-form requirement text used by cards whose condition is not a plain
  /// level/colour pair (DNA digivolution, DigiXros, and similar).
  final String? text;

  /// True for a condition printed in the card's effect box rather than in the
  /// cost box at the top left.
  ///
  /// Neither card API models those as data — they are a line of effect text —
  /// so they are parsed out of it when a card is read. See `DigivolveParser`.
  /// The card screen labels them, because a player reading a list of
  /// conditions needs to know which one is the one on the corner of the card.
  final bool isAlternative;

  factory DigivolveRequirement.fromJson(Map<String, dynamic> json) {
    final rawColors = json['color'];
    return DigivolveRequirement(
      isAlternative: json['alternative'] as bool? ?? false,
      level: json['level'] as int?,
      form: json['form'] as String?,
      cost: json['cost'] as int?,
      category: CardCategory.tryParse(json['category'] as String?),
      colors: rawColors is List
          ? rawColors
                .map((c) => CardColor.tryParse(c is String ? c : null))
                .whereType<CardColor>()
                .toList()
          : const [],
      text: json['text'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    if (level != null) 'level': level,
    if (form != null) 'form': form,
    if (cost != null) 'cost': cost,
    if (category != null) 'category': category!.apiValue,
    if (colors.isNotEmpty) 'color': colors.map((c) => c.apiValue).toList(),
    if (text != null) 'text': text,
    if (isAlternative) 'alternative': true,
  };

  /// The condition in words, without the cost — the card screen prints that
  /// alongside, and saying it twice read as though it were two costs.
  ///
  /// Says nothing but a colour when the source published no condition; see
  /// [isConditionUnpublished].
  String describe() {
    if (text != null && text!.isNotEmpty) return text!;
    return [
      if (level != null) 'Lv.$level',
      if (form != null) _formLabel,
      if (colors.isNotEmpty) _colorLabel,
      if (category != null && category != CardCategory.digimon) category!.label,
    ].join(' ');
  }

  /// The Appmon grade spelled out for the card screen.
  ///
  /// The grades share their names with the Digimon forms — an `ultimate`
  /// condition on an Appmon is not the Ultimate level — so the word Appmon is
  /// what tells a reader which of the two the row means. Every requirement
  /// that carries a grade is on an Appmon; none carries a level as well.
  String get _formLabel =>
      '${form![0].toUpperCase()}${form!.substring(1)} Appmon';

  /// True when the condition lists every colour, which is how the source
  /// spells "from a Digimon of any colour".
  ///
  /// The 93 requirements that do it are the Appmon grades and the handful of
  /// Digimon that digivolve from anything; naming all seven buried the rest of
  /// the condition, and the card prints the whole colour wheel rather than a
  /// list.
  bool get isAnyColor => colors.length == CardColor.values.length;

  /// Reads as a qualifier on what comes before it — "Lv.2 any colour",
  /// "Standard Appmon any colour" — so it never opens the description, and no
  /// requirement with every colour lacks the level or grade that would.
  String get _colorLabel =>
      isAnyColor ? 'any colour' : colors.map((c) => c.label).join('/');

  /// True when the source published a digivolution cost, and at most the
  /// colour to pay it from, without the thing being digivolved from.
  ///
  /// Only the preview source does this, and it does it for nearly every card:
  /// its `evolution_level` column is null throughout and `evolution_color` on
  /// all but a handful, with the real condition left in the card's text. A row
  /// like that is still the card's own condition and keeps its row — the card
  /// screen just says which half of it is missing instead of describing a
  /// condition the source never published.
  ///
  /// A colour on its own is not enough to make it a condition: every printed
  /// condition names a level, a grade, or a card type to digivolve from, and
  /// the colour only says which colours it may come from.
  bool get isConditionUnpublished =>
      (text == null || text!.isEmpty) &&
      level == null &&
      form == null &&
      (category == null || category == CardCategory.digimon);
}

/// A question and answer from the official rulings database.
class CardFaq {
  const CardFaq({required this.question, required this.answer, this.date});

  final String question;
  final String answer;
  final String? date;

  factory CardFaq.fromJson(Map<String, dynamic> json) => CardFaq(
    question: json['question'] as String? ?? '',
    answer: json['answer'] as String? ?? '',
    date: json['date'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
    if (date != null) 'date': date,
  };
}

/// An official correction to a card's printed text.
class CardErrata {
  const CardErrata({this.date, this.error, this.correction, this.notes});

  final String? date;
  final String? error;
  final String? correction;
  final String? notes;

  factory CardErrata.fromJson(Map<String, dynamic> json) => CardErrata(
    date: json['date'] as String?,
    error: json['error'] as String?,
    correction: json['correction'] as String?,
    notes: json['notes'] as String?,
  );

  Map<String, dynamic> toJson() => {
    if (date != null) 'date': date,
    if (error != null) 'error': error,
    if (correction != null) 'correction': correction,
    if (notes != null) 'notes': notes,
  };
}

/// An entry from the official restriction list.
class CardLimitation {
  const CardLimitation({
    required this.type,
    this.date,
    this.allowance,
    this.note,
    this.pairedCardNumbers = const [],
  });

  final LimitationType type;
  final String? date;
  final int? allowance;
  final String? note;

  /// For a [LimitationType.bannedPair], the cards this one may not share a
  /// deck with — any one of them, not all of them together.
  ///
  /// The list writes the ruling on one of the two cards and names the others
  /// here, so the entry only ever exists on one side of the pairing.
  final List<String> pairedCardNumbers;

  /// Copies of this card number a deck may legally contain.
  int get effectiveAllowance => allowance ?? type.allowance;

  factory CardLimitation.fromJson(Map<String, dynamic> json) {
    final type =
        LimitationType.tryParse(json['type'] as String?) ??
        LimitationType.restrict;
    final allowance = json['allowance'] as int?;
    return CardLimitation(
      type: type,
      date: json['date'] as String?,
      // The zero published alongside a banned pair is how many copies the
      // *pairing* may run, and reading it as a copy limit would ban a card
      // that is perfectly legal on its own.
      allowance: type == LimitationType.bannedPair ? null : allowance,
      note: json['note'] as String?,
      pairedCardNumbers:
          (json['paired-card-numbers'] as List?)?.whereType<String>().toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type.apiValue,
    if (date != null) 'date': date,
    if (allowance != null) 'allowance': allowance,
    if (note != null) 'note': note,
    if (pairedCardNumbers.isNotEmpty) 'paired-card-numbers': pairedCardNumbers,
  };

  /// The limitation from [limitations] that still caps this card's copies, or
  /// `null` if the card may be run in fours.
  ///
  /// Entries accumulate over time, so the newest restriction wins — unless an
  /// `unrestrict` entry postdates it, which lifts the card again.
  ///
  /// Banned pairs are left out: they say nothing about how many copies a deck
  /// may hold, only about what the deck may hold alongside them, and a card
  /// can carry one of each. [pairBansIn] is that other half.
  static CardLimitation? activeIn(List<CardLimitation> limitations) {
    final applicable = limitations
        .where(
          (l) =>
              l.type != LimitationType.unrestrict &&
              l.type != LimitationType.bannedPair,
        )
        .sorted((a, b) => (a.date ?? '').compareTo(b.date ?? ''));
    if (applicable.isEmpty) return null;

    final latest = applicable.last;
    if (_liftedAfter(limitations, latest.date)) return null;
    return latest;
  }

  /// The banned-pair entries from [limitations] that still apply.
  ///
  /// A card can be named in more than one ruling, so unlike [activeIn] the
  /// newest does not replace the ones before it — every pairing that has not
  /// been lifted still stands.
  static List<CardLimitation> pairBansIn(List<CardLimitation> limitations) => [
    for (final limitation in limitations)
      if (limitation.type == LimitationType.bannedPair &&
          !_liftedAfter(limitations, limitation.date))
        limitation,
  ];

  /// Whether an `unrestrict` entry postdates [date] and so lifts it.
  static bool _liftedAfter(List<CardLimitation> limitations, String? date) {
    final lifted = limitations
        .where((l) => l.type == LimitationType.unrestrict)
        .map((l) => l.date ?? '')
        .maxOrNull;
    return lifted != null && lifted.compareTo(date ?? '') > 0;
  }

  /// Copies of a card the restriction list allows, defaulting to 4.
  static int copyLimitIn(List<CardLimitation> limitations) =>
      activeIn(limitations)?.effectiveAllowance ?? 4;
}

/// The copies a deck may contain of one card number.
///
/// Three things can decide it, in this order:
///  * the official restriction list, which overrides everything;
///  * the card's own ⟨Rule⟩ text — a handful of cards say "you can include up
///    to 50 copies", which is how decks of nothing but that card are legal;
///  * otherwise the standard four.
abstract final class CopyLimit {
  static const standard = 4;

  /// Matches the printed rule, e.g. "⟨Rule⟩ You can include up to 50 copies of
  /// cards with this card's card number in your deck." The apostrophe varies
  /// between straight and typographic across sets.
  static final _rule = RegExp(
    r'include up to (\d+) copies of cards with this card.s card number',
    caseSensitive: false,
  );

  /// The limit a card's own text grants, or null when it says nothing.
  static int? fromRuleText(Iterable<String?> texts) {
    for (final text in texts) {
      if (text == null || text.isEmpty) continue;
      final match = _rule.firstMatch(text);
      if (match != null) return int.tryParse(match.group(1)!);
    }
    return null;
  }

  /// Resolves the three sources against each other.
  static int resolve({
    required List<CardLimitation> limitations,
    int? ruleLimit,
  }) {
    final restriction = CardLimitation.activeIn(limitations);
    if (restriction != null) return restriction.effectiveAllowance;
    return ruleLimit ?? standard;
  }
}

/// The second face of a dual card — the BT-25 cards that are a Digimon on one
/// side and an Option on the other. Both faces share a single physical card
/// and therefore a single image.
class CardFace {
  const CardFace({
    required this.name,
    required this.category,
    required this.colors,
    this.rarity,
    this.useCost,
    this.playCost,
    this.effect,
  });

  final String name;
  final CardCategory category;
  final List<CardColor> colors;
  final String? rarity;
  final int? useCost;
  final int? playCost;
  final String? effect;

  int? get cost => category == CardCategory.option ? useCost : playCost;

  factory CardFace.fromJson(Map<String, dynamic> json) {
    final rawColors = json['color'];
    return CardFace(
      name: json['name'] as String? ?? '',
      category:
          CardCategory.tryParse(json['category'] as String?) ??
          CardCategory.option,
      // Dual faces spell colours as `[{index: 0, color: "yellow"}]` rather
      // than the flat list the main attributes use.
      colors: rawColors is List
          ? rawColors
                .map(
                  (c) => CardColor.tryParse(
                    c is Map<String, dynamic>
                        ? c['color'] as String?
                        : c as String?,
                  ),
                )
                .whereType<CardColor>()
                .toList()
          : const [],
      rarity: json['rarity'] as String?,
      useCost: json['use-cost'] as int?,
      playCost: json['play-cost'] as int?,
      effect: json['effect'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category.apiValue,
    'color': colors.map((c) => c.apiValue).toList(),
    if (rarity != null) 'rarity': rarity,
    if (useCost != null) 'use-cost': useCost,
    if (playCost != null) 'play-cost': playCost,
    if (effect != null) 'effect': effect,
  };
}

/// A single printing of a card.
///
/// The API models every alternate art as its own card, distinguished from the
/// base printing by [parallelId] while sharing a [number]. The library groups
/// printings by number and shows the base printing; see [isBasePrinting].
class DigimonCard {
  const DigimonCard({
    required this.id,
    required this.number,
    required this.parallelId,
    required this.name,
    required this.category,
    required this.colors,
    required this.imageUrl,
    this.rarity,
    this.supplementalStars,
    this.level,
    this.playCost,
    this.useCost,
    this.dp,
    this.form,
    this.attribute,
    this.blockIcon,
    this.traits = const [],
    this.keywords = const [],
    this.effect,
    this.inheritedEffect,
    this.securityEffect,
    this.digivolutionRequirements = const [],
    this.notes,
    this.faqs = const [],
    this.errata,
    this.limitations = const [],
    this.releaseIds = const [],
    this.alternateArtIds = const [],
    this.dualFace,
    this.isAce = false,
    this.ruleCopyLimit,
  });

  /// Card id as used by the API path, e.g. `ST1-07` or `ST1-07_P1`.
  final String id;

  /// Printed collector number, shared by every art of the same card.
  final String number;

  /// `0` for the base printing, `1..n` for alternate arts.
  final int parallelId;

  final String name;
  final CardCategory category;
  final List<CardColor> colors;
  final String imageUrl;

  final String? rarity;

  /// Extra "star" rarity marker some alternate arts carry on top of [rarity].
  final int? supplementalStars;

  final int? level;
  final int? playCost;
  final int? useCost;
  final int? dp;
  final String? form;
  final String? attribute;
  final int? blockIcon;

  /// Traits, split from the API's slash-separated `type` field.
  final List<String> traits;

  /// Keywords parsed out of the effect text, e.g. `Blocker`, `Rush`. The API
  /// has no keyword field, so these are derived at sync time.
  final List<String> keywords;

  final String? effect;
  final String? inheritedEffect;
  final String? securityEffect;
  final List<DigivolveRequirement> digivolutionRequirements;

  /// The product this printing came from, as printed on the card.
  final String? notes;

  final List<CardFaq> faqs;
  final CardErrata? errata;
  final List<CardLimitation> limitations;
  final List<String> releaseIds;

  /// Ids of the other printings sharing this [number].
  final List<String> alternateArtIds;

  /// The Option face of a dual card, if this card has one.
  final CardFace? dualFace;

  /// True for ACE cards, which can be played early for an Overflow cost.
  final bool isAce;

  /// Copies the card's own ⟨Rule⟩ text allows, if it grants more than the
  /// standard four. Null for the vast majority of cards.
  final int? ruleCopyLimit;

  bool get isBasePrinting => parallelId == 0;

  bool get isDual => dualFace != null;

  /// Whether this is a token, which can never be put in a deck.
  bool get isToken => TokenCard.hasTokenNumber(number);

  /// The section of a deck list this card is written under.
  ///
  /// A dual card is a Digimon on one face and an Option on the other, and
  /// players file it with the Digimon: that is the face that digivolves and
  /// the one the deck is built around. Whichever way the data happens to list
  /// the two faces, the Digimon one wins.
  CardCategory get deckCategory {
    if (dualFace case final dual?
        when category != CardCategory.digimon &&
            dual.category == CardCategory.digimon) {
      return CardCategory.digimon;
    }
    return category;
  }

  /// The cost shown on the card, which lives in a different field for Options.
  int? get cost => category == CardCategory.option ? useCost : playCost;

  /// The most recent limitation that still applies, or `null` if unrestricted.
  CardLimitation? get activeLimitation => CardLimitation.activeIn(limitations);

  /// The pairings this card is banned in, which the restriction list records
  /// on one of the two cards only. Empty on the other side of the pairing.
  List<CardLimitation> get pairBans => CardLimitation.pairBansIn(limitations);

  /// Card numbers this card may not share a deck with, as far as its own
  /// entries say.
  Set<String> get bannedWith => {
    for (final ban in pairBans) ...ban.pairedCardNumbers,
  };

  /// Copies of this card a deck may contain.
  int get copyLimit =>
      CopyLimit.resolve(limitations: limitations, ruleLimit: ruleCopyLimit);

  /// True when the card's own text raises the usual four-copy cap.
  bool get hasRaisedCopyLimit =>
      ruleCopyLimit != null && ruleCopyLimit! > CopyLimit.standard;

  String get traitsLabel => traits.join(' / ');
}
