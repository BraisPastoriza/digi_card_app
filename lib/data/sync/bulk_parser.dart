import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import '../../core/utils/keyword_parser.dart';
import '../../domain/models/card_enums.dart';
import '../../domain/models/digimon_card.dart';

/// A card from the bulk dump, flattened into the shape the database stores.
///
/// This is deliberately a plain data holder so it can be sent back from the
/// parsing isolate.
class ParsedCard {
  ParsedCard({
    required this.id,
    required this.number,
    required this.parallelId,
    required this.name,
    required this.category,
    required this.colors,
    required this.imageUrl,
    required this.traits,
    required this.keywords,
    required this.releaseIds,
    required this.numberSort,
    required this.copyLimit,
    required this.digivolutionRequirements,
    required this.faqs,
    required this.limitations,
    this.isPrimary = true,
    this.rarity,
    this.supplementalStars,
    this.level,
    this.playCost,
    this.useCost,
    this.cost,
    this.dp,
    this.form,
    this.attribute,
    this.blockIcon,
    this.effect,
    this.inheritedEffect,
    this.securityEffect,
    this.digivolveCostMin,
    this.digivolveCostMax,
    this.notes,
    this.errata,
    this.dualFace,
    this.dualCategory,
    this.ruleCopyLimit,
  });

  final String id;
  final String number;
  final int parallelId;
  final String name;
  final String category;
  final List<String> colors;
  final String imageUrl;
  final List<String> traits;
  final List<String> keywords;
  final List<String> releaseIds;
  final String numberSort;
  final int copyLimit;

  /// Pre-encoded JSON, kept as text because the UI decodes it lazily.
  final String digivolutionRequirements;
  final String faqs;
  final String limitations;

  bool isPrimary;

  final String? rarity;
  final int? supplementalStars;
  final int? level;
  final int? playCost;
  final int? useCost;
  final int? cost;
  final int? dp;
  final String? form;
  final String? attribute;
  final int? blockIcon;
  final String? effect;
  final String? inheritedEffect;
  final String? securityEffect;
  final int? digivolveCostMin;
  final int? digivolveCostMax;
  final String? notes;
  final String? errata;
  final String? dualFace;
  final String? dualCategory;

  /// Copies the card's own rule text allows, when it raises the usual cap.
  final int? ruleCopyLimit;

  /// True for ACE cards. Derived from the printed name, which is the only
  /// place the API records it.
  bool get isAce => name.trimRight().endsWith('ACE');
}

/// Parses the downloaded bulk dump off the UI isolate.
///
/// The English dump is ~25 MB of JSON; decoding it on the main isolate would
/// freeze the app for seconds.
Future<List<ParsedCard>> parseBulkFile(String path) =>
    Isolate.run(() => _parseBulkFileSync(path));

List<ParsedCard> _parseBulkFileSync(String path) {
  // Decode UTF-8 straight into objects instead of going through a String:
  // the dump is ~25 MB, and the intermediate string would add ~50 MB of peak
  // memory on top of the object graph for no benefit.
  final documents = const Utf8Decoder()
      .fuse(const JsonDecoder())
      .convert(File(path).readAsBytesSync());
  if (documents is! List) return const [];

  final cards = <ParsedCard>[];
  for (final document in documents) {
    if (document is! Map<String, dynamic>) continue;
    final card = _parseDocument(document);
    if (card != null) cards.add(card);
  }
  _markPrimaryPrintings(cards);
  return cards;
}

ParsedCard? _parseDocument(Map<String, dynamic> document) {
  final data = document['data'];
  if (data is! Map<String, dynamic>) return null;
  final attributes = data['attributes'];
  if (attributes is! Map<String, dynamic>) return null;

  final number = attributes['number'] as String?;
  final image = attributes['image'];
  if (number == null || image is! String) return null;

  final id = _lastPathSegment(data['id'] as String? ?? number);
  final parallelId = attributes['parallel-id'] as int? ?? 0;
  final category = attributes['category'] as String? ?? 'digimon';

  final effect = attributes['effect'] as String?;
  final inheritedEffect = attributes['inherited-effect'] as String?;
  final securityEffect = attributes['security-effect'] as String?;

  final dual = attributes['dual'];
  final dualMap = dual is Map<String, dynamic> ? dual : null;
  final dualEffect = dualMap?['effect'] as String?;

  final requirements = _asMapList(attributes['digivolution-requirements']);
  final requirementCosts = requirements
      .map((r) => r['cost'])
      .whereType<int>()
      .toList();

  final limitations = _asMapList(
    attributes['limitations'],
  ).map(CardLimitation.fromJson).toList();

  // A few cards carry a ⟨Rule⟩ line raising the four-copy cap, which is what
  // makes decks built almost entirely out of one card legal.
  final ruleCopyLimit = CopyLimit.fromRuleText([
    effect,
    inheritedEffect,
    securityEffect,
    dualEffect,
  ]);

  final playCost = attributes['play-cost'] as int?;
  final useCost = attributes['use-cost'] as int?;

  final supplemental = attributes['supplemental-rarity'];

  return ParsedCard(
    id: id,
    number: number,
    parallelId: parallelId,
    name: attributes['name'] as String? ?? '',
    category: category,
    colors: _parseColors(attributes['color']),
    imageUrl: image,
    traits: _parseTraits(attributes['type'] as String?),
    // Dual faces carry their own effect text, and its keywords belong to the
    // same physical card.
    keywords: KeywordParser.extract([
      effect,
      inheritedEffect,
      securityEffect,
      dualEffect,
    ]),
    releaseIds: _parseReleaseIds(data['relationships']),
    numberSort: buildNumberSort(number, parallelId),
    copyLimit: CopyLimit.resolve(
      limitations: limitations,
      ruleLimit: ruleCopyLimit,
    ),
    ruleCopyLimit: ruleCopyLimit,
    digivolutionRequirements: jsonEncode(requirements),
    faqs: jsonEncode(_asMapList(attributes['faqs'])),
    limitations: jsonEncode(limitations.map((l) => l.toJson()).toList()),
    rarity: _parseRarity(attributes['rarity'] as String?),
    supplementalStars: supplemental is Map<String, dynamic>
        ? supplemental['stars'] as int?
        : null,
    level: attributes['level'] as int?,
    playCost: playCost,
    useCost: useCost,
    cost: category == CardCategory.option.apiValue ? useCost : playCost,
    dp: attributes['dp'] as int?,
    form: attributes['form'] as String?,
    attribute: attributes['attribute'] as String?,
    blockIcon: attributes['block-icon'] as int?,
    effect: effect,
    inheritedEffect: inheritedEffect,
    securityEffect: securityEffect,
    digivolveCostMin: requirementCosts.isEmpty
        ? null
        : requirementCosts.reduce((a, b) => a < b ? a : b),
    digivolveCostMax: requirementCosts.isEmpty
        ? null
        : requirementCosts.reduce((a, b) => a > b ? a : b),
    notes: attributes['notes'] as String?,
    errata: attributes['errata'] is Map<String, dynamic>
        ? jsonEncode(attributes['errata'])
        : null,
    dualFace: dualMap == null
        ? null
        : jsonEncode(CardFace.fromJson(dualMap).toJson()),
    dualCategory: dualMap?['category'] as String?,
  );
}

/// Flags one printing per card number as the one the library shows when
/// alternate arts are collapsed: the lowest parallel id, which is the base
/// printing whenever there is one.
void _markPrimaryPrintings(List<ParsedCard> cards) {
  final lowestByNumber = <String, ParsedCard>{};
  for (final card in cards) {
    final current = lowestByNumber[card.number];
    if (current == null || card.parallelId < current.parallelId) {
      lowestByNumber[card.number] = card;
    }
  }
  for (final card in cards) {
    card.isPrimary = identical(lowestByNumber[card.number], card);
  }
}

List<String> _parseColors(Object? raw) {
  if (raw is! List) return const [];
  return raw
      .map((value) {
        if (value is String) return value;
        // Dual faces spell colours as `{index: 0, color: "yellow"}`.
        if (value is Map<String, dynamic>) return value['color'] as String?;
        return null;
      })
      .whereType<String>()
      .toList();
}

/// Keeps only values that look like a printed rarity code (`C`, `U`, `R`,
/// `SR`, `SEC`, `UR`, `P`).
///
/// A stray token card in the English data carries Japanese text in this field,
/// which would otherwise show up as its own option in the rarity filter.
String? _parseRarity(String? raw) {
  if (raw == null) return null;
  final rarity = raw.trim();
  if (rarity.isEmpty) return null;
  return RegExp(r'^[A-Za-z]{1,4}$').hasMatch(rarity) ? rarity : null;
}

/// Splits the API's slash-separated `type` field into individual traits.
List<String> _parseTraits(String? raw) {
  if (raw == null || raw.isEmpty) return const [];
  return raw
      .split('/')
      .map((trait) => trait.trim())
      .where((trait) => trait.isNotEmpty)
      .toList();
}

List<String> _parseReleaseIds(Object? relationships) {
  if (relationships is! Map<String, dynamic>) return const [];
  final releases = relationships['releases'];
  if (releases is! Map<String, dynamic>) return const [];
  final entries = releases['data'];
  if (entries is! List) return const [];
  return entries
      .map((entry) => entry is Map<String, dynamic> ? entry['id'] : null)
      .whereType<String>()
      .map(_lastPathSegment)
      .toList();
}

List<Map<String, dynamic>> _asMapList(Object? raw) {
  if (raw is! List) return const [];
  return raw.whereType<Map<String, dynamic>>().toList();
}

String _lastPathSegment(String path) => path.split('/').last;

/// Builds a sort key that orders card numbers the way they are printed:
/// `BT25-002` after `BT25-001`, and `BT9-001` before `BT10-001`.
///
/// Plain lexicographic ordering gets both wrong, because `BT10` sorts before
/// `BT9` and `-10` before `-9`.
String buildNumberSort(String number, int parallelId) {
  final separator = number.indexOf('-');
  final head = separator == -1 ? number : number.substring(0, separator);
  final tail = separator == -1 ? '' : number.substring(separator + 1);

  final headMatch = RegExp(r'^([A-Za-z]*)(\d*)').firstMatch(head)!;
  final prefix = (headMatch.group(1) ?? '').toUpperCase().padRight(6);
  final setNumber = (headMatch.group(2) ?? '').padLeft(4, '0');

  final tailDigits = RegExp(r'^\d+').firstMatch(tail)?.group(0);
  // Non-numeric suffixes (the TOKEN cards) sort after every numbered card.
  final cardNumber = tailDigits?.padLeft(5, '0') ?? '99999$tail';

  return '$prefix$setNumber$cardNumber${parallelId.toString().padLeft(2, '0')}';
}
