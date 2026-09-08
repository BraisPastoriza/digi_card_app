import 'dart:math';

import 'deck.dart';
import 'digimon_card.dart';

/// A shuffled opening: the five cards drawn to hand and the five set aside as
/// security, dealt off a revision the way a game starts.
///
/// This is how a deck under construction is judged — a curve on a chart says
/// the Lv.3s are there, but only dealing them says how often they turn up
/// together with something to play them into.
class TestHand {
  const TestHand({required this.hand, required this.security});

  /// The five cards drawn, in the order they came off the deck.
  final List<DigimonCard> hand;

  /// The five security cards, top of the stack first — the order they will be
  /// checked in.
  final List<DigimonCard> security;

  static const handSize = 5;
  static const securitySize = 5;

  /// Whether [composition] can be dealt from at all.
  ///
  /// Only the main deck counts: the Digi-Eggs are a deck of their own, sitting
  /// in the breeding area rather than in the pile the opening comes off. A
  /// deck short of its 50 cards would deal an opening that says nothing about
  /// the finished list, so it is refused rather than padded.
  static bool canDeal(DeckComposition composition) =>
      composition.mainDeckCount == DeckRules.mainDeckSize;

  /// Shuffles the main deck and deals a game's opening, or null when there is
  /// not a full main deck to deal from.
  ///
  /// Security comes off the top first and the hand after it, which is the
  /// order the rules set a game up in.
  static TestHand? deal(DeckComposition composition, {Random? random}) {
    if (!canDeal(composition)) return null;

    final deck = [
      for (final entry in composition.mainDeck)
        for (var copy = 0; copy < entry.quantity; copy++) entry.card,
    ]..shuffle(random ?? Random());

    return TestHand(
      security: deck.take(securitySize).toList(),
      hand: deck.skip(securitySize).take(handSize).toList(),
    );
  }
}
