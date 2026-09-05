import 'package:collection/collection.dart';

import 'card_enums.dart';

/// One requirement line from a card's digivolution conditions, e.g.
/// "Lv.3 red — cost 2".
class DigivolveRequirement {
  const DigivolveRequirement({
    this.level,
    this.cost,
    this.category,
    this.colors = const [],
    this.text,
  });

  final int? level;
  final int? cost;
  final CardCategory? category;
  final List<CardColor> colors;

  /// Free-form requirement text used by cards whose condition is not a plain
  /// level/colour pair (DNA digivolution, DigiXros, and similar).
  final String? text;

  factory DigivolveRequirement.fromJson(Map<String, dynamic> json) {
    final rawColors = json['color'];
    return DigivolveRequirement(
      level: json['level'] as int?,
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
    if (cost != null) 'cost': cost,
    if (category != null) 'category': category!.apiValue,
    if (colors.isNotEmpty) 'color': colors.map((c) => c.apiValue).toList(),
    if (text != null) 'text': text,
  };

  String describe() {
    if (text != null && text!.isNotEmpty) return text!;
    final parts = <String>[
      if (level != null) 'Lv.$level',
      if (colors.isNotEmpty) colors.map((c) => c.label).join('/'),
      if (category != null && category != CardCategory.digimon) category!.label,
    ];
    final requirement = parts.isEmpty ? 'Any' : parts.join(' ');
    return cost == null ? requirement : '$requirement — cost $cost';
  }
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
  });

  final LimitationType type;
  final String? date;
  final int? allowance;
  final String? note;

  /// Copies of this card number a deck may legally contain.
  int get effectiveAllowance => allowance ?? type.allowance;

  factory CardLimitation.fromJson(Map<String, dynamic> json) => CardLimitation(
    type:
        LimitationType.tryParse(json['type'] as String?) ??
        LimitationType.restrict,
    date: json['date'] as String?,
    allowance: json['allowance'] as int?,
    note: json['note'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'type': type.apiValue,
    if (date != null) 'date': date,
    if (allowance != null) 'allowance': allowance,
    if (note != null) 'note': note,
  };

  /// The limitation from [limitations] that still applies, or `null` if the
  /// card is unrestricted.
  ///
  /// Entries accumulate over time, so the newest restriction wins — unless an
  /// `unrestrict` entry postdates it, which lifts the card again.
  static CardLimitation? activeIn(List<CardLimitation> limitations) {
    final applicable = limitations
        .where((l) => l.type != LimitationType.unrestrict)
        .sorted((a, b) => (a.date ?? '').compareTo(b.date ?? ''));
    if (applicable.isEmpty) return null;

    final latest = applicable.last;
    final lifted = limitations
        .where((l) => l.type == LimitationType.unrestrict)
        .map((l) => l.date ?? '')
        .maxOrNull;
    if (lifted != null && lifted.compareTo(latest.date ?? '') > 0) return null;
    return latest;
  }

  /// Copies of a card the restriction list allows, defaulting to 4.
  static int copyLimitIn(List<CardLimitation> limitations) =>
      activeIn(limitations)?.effectiveAllowance ?? 4;
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

  bool get isBasePrinting => parallelId == 0;

  bool get isDual => dualFace != null;

  /// The cost shown on the card, which lives in a different field for Options.
  int? get cost => category == CardCategory.option ? useCost : playCost;

  /// The most recent limitation that still applies, or `null` if unrestricted.
  CardLimitation? get activeLimitation => CardLimitation.activeIn(limitations);

  /// Copies of this card a deck may contain: 4 unless the restriction list
  /// says otherwise.
  int get copyLimit => CardLimitation.copyLimitIn(limitations);

  String get traitsLabel => traits.join(' / ');
}
