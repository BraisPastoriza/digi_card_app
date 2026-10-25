import 'package:collection/collection.dart';

import 'digimon_card.dart';

/// A card and the cards a deck running it may not also run — any one of them,
/// not all of them together.
class BannedPair {
  const BannedPair({
    required this.cardNumber,
    required this.partnerNumbers,
    this.cards = const {},
    this.date,
  });

  final String cardNumber;
  final List<String> partnerNumbers;

  /// The cards of the pairing the library has, by number. A ruling can name a
  /// card the device has not downloaded yet, and its number still says which.
  final Map<String, DigimonCard> cards;

  /// When the newest of these pairings came into force.
  final String? date;
}

/// The restriction list as it stands, grouped the way it is published.
class Banlist {
  const Banlist({
    this.banned = const [],
    this.limited = const {},
    this.pairs = const [],
  });

  /// Builds the list from the cards the library has restricted.
  ///
  /// [restricted] are the cards capped below the usual four copies, and
  /// [pairCarriers] the cards carrying a banned-pair entry; [partners]
  /// supplies the cards those entries name.
  factory Banlist.from({
    required Iterable<DigimonCard> restricted,
    required Iterable<DigimonCard> pairCarriers,
    Map<String, DigimonCard> partners = const {},
  }) {
    final banned = <DigimonCard>[];
    final limited = <int, List<DigimonCard>>{};
    for (final card in restricted) {
      final limit = card.copyLimit;
      if (limit == 0) {
        banned.add(card);
      } else {
        limited.putIfAbsent(limit, () => []).add(card);
      }
    }

    final pairs = _pairsFrom(pairCarriers, partners);

    return Banlist(
      banned: banned,
      // Strictest first: one copy reads before two.
      limited: {
        for (final limit in limited.keys.sorted((a, b) => a.compareTo(b)))
          limit: limited[limit]!,
      },
      pairs: pairs,
    );
  }

  /// Cards no deck may run at all.
  final List<DigimonCard> banned;

  /// Cards a deck may run fewer than four of, keyed by how many it may.
  final Map<int, List<DigimonCard>> limited;

  final List<BannedPair> pairs;

  /// Groups the pairings the carriers record into one row per card.
  ///
  /// The list is inconsistent about which side a ruling is written on: one
  /// pairing is recorded on both cards, another only on the three cards
  /// banned alongside a fourth that carries nothing. So the pairings are
  /// first collected without a direction, each once, and then handed out to
  /// rows greedily — the card in the most pairings takes all of its own — so
  /// a card banned alongside several reads as the one row it is.
  static List<BannedPair> _pairsFrom(
    Iterable<DigimonCard> carriers,
    Map<String, DigimonCard> partners,
  ) {
    final cards = {...partners, for (final card in carriers) card.number: card};
    // Partners by card, both ways, with the date of each pairing.
    final edges = <String, Map<String, String?>>{};
    // First-seen order, so ties go the same way every time.
    final order = <String>[];
    void link(String a, String b, String? date) {
      for (final (from, to) in [(a, b), (b, a)]) {
        if (!edges.containsKey(from)) order.add(from);
        final dates = edges.putIfAbsent(from, () => {});
        final known = dates[to];
        if (!dates.containsKey(to) || (date ?? '').compareTo(known ?? '') > 0) {
          dates[to] = date;
        }
      }
    }

    for (final card in carriers) {
      for (final ban in card.pairBans) {
        for (final partner in ban.pairedCardNumbers) {
          if (partner != card.number) link(card.number, partner, ban.date);
        }
      }
    }

    final pairs = <BannedPair>[];
    while (true) {
      String? hub;
      for (final number in order) {
        final count = edges[number]!.length;
        if (count > 0 && (hub == null || count > edges[hub]!.length)) {
          hub = number;
        }
      }
      if (hub == null) break;
      final taken = edges[hub]!;
      final partnerNumbers = taken.keys.toList();
      pairs.add(
        BannedPair(
          cardNumber: hub,
          partnerNumbers: partnerNumbers,
          cards: {
            for (final number in [hub, ...partnerNumbers])
              number: ?cards[number],
          },
          date: taken.values.nonNulls.maxOrNull,
        ),
      );
      edges[hub] = {};
      for (final partner in partnerNumbers) {
        edges[partner]!.remove(hub);
      }
    }
    // Newest rulings first, the ones a player is least likely to know yet.
    return pairs.sorted((a, b) => (b.date ?? '').compareTo(a.date ?? ''));
  }

  bool get isEmpty => banned.isEmpty && limited.isEmpty && pairs.isEmpty;

  /// The date of the newest ruling still in force, which is as close as the
  /// data comes to saying when the list was last changed.
  String? get latestDate => [
    for (final card in [...banned, ...limited.values.flattened])
      card.activeLimitation?.date,
    for (final pair in pairs) pair.date,
  ].nonNulls.maxOrNull;
}
