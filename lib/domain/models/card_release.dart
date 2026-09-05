import 'card_enums.dart';

/// A product release: a booster set, starter deck, promo bucket, and so on.
class CardRelease {
  const CardRelease({
    required this.id,
    required this.name,
    required this.group,
    required this.cardCount,
    required this.sortIndex,
    this.printingCount = 0,
    this.genre,
    this.date,
    this.imageUrl,
    this.thumbnailUrl,
    this.productUri,
    this.cardlistUri,
  });

  /// Slug used by the API path, e.g. `bt-25`.
  final String id;

  /// Full printed name, e.g. `DUAL REVOLUTION [BT-25]`.
  final String name;

  final ReleaseGroup group;

  /// Distinct cards, counting a card once however many alternate arts of it
  /// the release contains.
  final int cardCount;

  /// Every printing, alternate arts included.
  final int printingCount;

  /// Position in the API's own release ordering, which is chronological and
  /// the order players expect to browse in.
  final int sortIndex;

  final String? genre;
  final String? date;
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? productUri;
  final String? cardlistUri;

  /// The set code shown as a badge, extracted from the trailing bracket in
  /// [name] when there is one (`DUAL REVOLUTION [BT-25]` -> `BT-25`).
  String? get setCode {
    final match = RegExp(r'\[([^\]]+)\]\s*$').firstMatch(name);
    return match?.group(1);
  }

  /// [name] without the trailing set code, which the UI shows separately.
  String get displayName {
    final code = setCode;
    if (code == null) return name;
    return name.substring(0, name.length - code.length - 2).trim();
  }

  String? get releaseYear {
    final date = this.date;
    if (date == null || date.length < 4) return null;
    return date.substring(0, 4);
  }
}

/// Id of the synthetic release that gathers every promotional card.
///
/// Promos are spread across half a dozen products by where they were handed
/// out, which is exactly the thing a player looking one up does not know. This
/// release is assembled at sync time so that lookup has somewhere to happen.
const allPromosReleaseId = 'all-promos';

/// Sorts releases into the buckets the library lists them under.
///
/// The API's own `genre` field lumps BT, EX and AD together as "Booster Pack",
/// so the grouping comes from the release slug instead.
ReleaseGroup classifyRelease(String id) {
  final slug = id.toLowerCase();
  if (slug == allPromosReleaseId) return ReleaseGroup.promo;
  if (slug.startsWith('bt')) return ReleaseGroup.booster;
  if (slug.startsWith('ex')) return ReleaseGroup.ex;
  if (slug.startsWith('st-') || slug.startsWith('st')) {
    // `store-events` also starts with "st"; keep it in the promo bucket.
    if (slug.startsWith('store')) return ReleaseGroup.promo;
    return ReleaseGroup.starter;
  }
  if (slug.startsWith('ad-') || slug.startsWith('ad')) {
    return ReleaseGroup.advanceDeck;
  }
  if (slug.startsWith('lm-') || slug.startsWith('lm')) {
    return ReleaseGroup.limited;
  }
  if (slug.startsWith('rb-') || slug.startsWith('rb')) {
    return ReleaseGroup.resurgence;
  }
  const promoSlugs = {
    'p',
    'large-scale-tournaments',
    'store-events',
    'premium-bandai',
    'other-promos',
  };
  if (promoSlugs.contains(slug)) return ReleaseGroup.promo;
  return ReleaseGroup.other;
}
