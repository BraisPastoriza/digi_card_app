import 'card_enums.dart';
import 'digimon_card.dart';

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
    this.dataSource,
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

  /// Which API the release's cards came from. Null for the primary source;
  /// see [PreviewRelease] for the sets filled in from elsewhere.
  final String? dataSource;

  /// True for a set the primary API has not published yet, whose data is
  /// community-sourced and still changing.
  bool get isPreview => dataSource != null;

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

  /// Letters and set number of a code like `BT-25` or a card's `BT25-001`,
  /// with leading zeros dropped so `AD-01` and `AD1-002` line up.
  static final _codeParts = RegExp(r'^([A-Za-z]+)-?0*(\d*)$');

  /// Whether [cardNumber] was printed as part of this release, rather than
  /// included in the product as a reprint of a card from another set.
  ///
  /// Products bundle alternate arts of older cards — BT-25 ships eight among
  /// its 137, and AD-01 has four times as many reprints as cards of its own —
  /// and by printed number those sort to the front, because `BT2-047` reads as
  /// an earlier number than `BT25-001`. They belong at the end instead.
  ///
  /// A release with no set code in its name has nothing to compare against, so
  /// everything in it counts as its own and the order is left alone.
  bool isOwnCardNumber(String cardNumber) {
    final code = setCode;
    if (code == null) return true;

    final set = _codeParts.firstMatch(code.toUpperCase());
    final card = _codeParts.firstMatch(
      cardNumber.toUpperCase().split('-').first,
    );
    if (set == null || card == null) return true;
    if (set.group(1) != card.group(1)) return false;

    // One side without a number is still the same product: the Limited packs
    // are `LM-08` while the cards they introduce are numbered plain `LM-057`.
    final setNumber = set.group(2)!;
    final cardSetNumber = card.group(2)!;
    if (setNumber.isEmpty || cardSetNumber.isEmpty) return true;
    return setNumber == cardSetNumber;
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

/// Id of the Special Limited Set, a box product made up of Limited Card Pack
/// cards. Its slug shares no prefix with the LM releases, so it is named here.
const specialLimitedSetReleaseId = 'special-limited-set';

/// A set the primary card API has not published yet, filled in from the
/// secondary source so the newest cards are searchable and deck-buildable
/// before the canonical data catches up.
///
/// These are named here rather than discovered because the point is to keep
/// the secondary source on a very short leash: two known sets, two requests.
/// No retirement code is needed — the sync skips any preview whose id the
/// primary API has started publishing, so each one disappears on its own the
/// day the real data lands.
class PreviewRelease {
  const PreviewRelease({
    required this.id,
    required this.name,
    required this.pack,
    this.genre,
  });

  /// Slug in the primary API's own style, so [classifyRelease] files it in
  /// the right library group without a special case.
  final String id;

  /// Printed name in the primary API's format, `NAME [SET-CODE]`, so the
  /// library's set-code badge keeps working.
  final String name;

  /// Value for the secondary API's `pack` parameter.
  final String pack;

  final String? genre;
}

/// Name of the secondary source, stored on the releases it provided and shown
/// wherever its data is.
const secondarySourceName = 'digimoncard.io';

/// The sets currently filled in from the secondary source.
const previewReleases = [
  PreviewRelease(
    id: 'bt-26',
    name: 'TIMELESS BONDS [BT-26]',
    pack: 'BT-26',
    genre: 'Booster Pack',
  ),
  PreviewRelease(
    id: 'ex-13',
    name: 'CHIVALROUS XIII [EX-13]',
    pack: 'EX-13',
    genre: 'Booster Pack',
  ),
  // The Limited packs are mostly reprints of cards from other sets, plus six
  // new `LM-` cards each. Only the six are new to the database; the reprints
  // are linked to the pack rather than stored a second time.
  PreviewRelease(
    id: 'lm-08',
    name: 'LIMITED CARD PACK FINAL CREST [LM-08]',
    pack: 'LM-08',
    genre: 'Premium Bandai',
  ),
  PreviewRelease(
    id: 'lm-09',
    name: 'LIMITED CARD PACK DISTANCIA CERO [LM-09]',
    pack: 'LM-09',
    genre: 'Premium Bandai',
  ),
];

/// [cards] with the release's own cards first and the reprints it bundles
/// after them, each group keeping the printed order it came in.
///
/// A partition rather than a sort, so the card-number ordering the query
/// already applied survives inside each group.
List<DigimonCard> withOwnCardsFirst(
  List<DigimonCard> cards,
  CardRelease? release,
) {
  if (release == null) return cards;
  final own = <DigimonCard>[];
  final extras = <DigimonCard>[];
  for (final card in cards) {
    (release.isOwnCardNumber(card.number) ? own : extras).add(card);
  }
  return extras.isEmpty ? cards : [...own, ...extras];
}

/// Releases whose published thumbnail is a shared placeholder rather than a
/// photo of the product.
///
/// Five releases serve the same image byte for byte — a generic picture of a
/// card back — which left their tiles impossible to tell apart. Four of them
/// are the promotional buckets, already covered by their group; this one is
/// not, so it is named.
const releasesWithPlaceholderThumbnail = {'other-products'};

/// Whether a release needs one of its own cards to stand for it, because the
/// product photo it publishes cannot.
///
/// Three cases: no photo at all (every synthetic release and every preview
/// set), the promotional buckets, and the releases that serve the shared
/// placeholder.
bool needsCardArt(CardRelease release) =>
    release.thumbnailUrl == null ||
    release.group == ReleaseGroup.promo ||
    releasesWithPlaceholderThumbnail.contains(release.id);

/// Id of the synthetic release that gathers every Limited card.
///
/// Cards numbered `LM-` are handed out six at a time as bonuses inside other
/// products: the 56 published ones are spread across thirteen releases, from
/// booster sets to starter decks. Like the promos, the product a Limited card
/// came in is exactly what someone holding it does not know, so they are
/// gathered here as well as left in the products they shipped with.
const allLimitedReleaseId = 'all-lm';

/// Sorts releases into the buckets the library lists them under.
///
/// The API's own `genre` field lumps BT, EX and AD together as "Booster Pack",
/// so the grouping comes from the release slug instead.
ReleaseGroup classifyRelease(String id) {
  final slug = id.toLowerCase();
  if (slug == allPromosReleaseId) return ReleaseGroup.promo;
  if (slug == allLimitedReleaseId) return ReleaseGroup.limited;
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
  // The Special Limited Set is a box of LM cards rather than a product line of
  // its own, so it belongs with the Limited Card Packs its cards came from.
  if (slug.startsWith('lm-') ||
      slug.startsWith('lm') ||
      slug == specialLimitedSetReleaseId) {
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
