import 'deck.dart';
import 'test_hand.dart';

/// How likely a deck is to have drawn a card by a given point of the game.
///
/// The question a deck's ratios answer — four of a Lv.3 or three, two Tamers
/// or three — is "will I have one when I need it", and that is a
/// hypergeometric draw from the main deck. Security does not change it: the
/// five security cards are as random as the rest, so the hand is still a fair
/// sample of the whole deck. The Digi-Egg deck is drawn from separately and
/// never counts.
abstract final class DrawOdds {
  /// The furthest turn worth asking about: past it nearly everything is above
  /// 90% and the numbers stop telling decks apart.
  static const lastTurn = 4;

  /// Cards a player has drawn into hand by the start of their [turn], where
  /// turn 0 is the opening hand before anything is played.
  ///
  /// The player going first skips the draw of their very first turn.
  static int cardsSeen({required int turn, required bool goingFirst}) {
    if (turn <= 0) return TestHand.handSize;
    return TestHand.handSize + (goingFirst ? turn - 1 : turn);
  }

  /// The chance of holding at least one of [copies] cards after drawing
  /// [drawn] from a deck of [deckSize].
  ///
  /// One minus the chance that every card drawn is something else, built up a
  /// draw at a time rather than from binomial coefficients, which overflow
  /// long before a 50-card deck does anything unusual.
  static double atLeastOne({
    required int deckSize,
    required int copies,
    required int drawn,
  }) {
    if (copies <= 0 || drawn <= 0 || deckSize <= 0) return 0;
    if (copies >= deckSize || drawn > deckSize - copies) return 1;
    var missAll = 1.0;
    for (var i = 0; i < drawn; i++) {
      missAll *= (deckSize - copies - i) / (deckSize - i);
    }
    return 1 - missAll;
  }

  /// [atLeastOne] for a card or group that makes up [copies] of [deck]'s
  /// main deck, by the start of [turn].
  static double of(
    DeckComposition deck, {
    required int copies,
    required int turn,
    required bool goingFirst,
  }) => atLeastOne(
    deckSize: deck.mainDeckCount,
    copies: copies,
    drawn: cardsSeen(turn: turn, goingFirst: goingFirst),
  );
}
