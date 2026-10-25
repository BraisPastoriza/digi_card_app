import 'package:digi_card_app/domain/models/draw_odds.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cards seen', () {
    test('is the opening hand before the first turn', () {
      expect(DrawOdds.cardsSeen(turn: 0, goingFirst: true), 5);
      expect(DrawOdds.cardsSeen(turn: 0, goingFirst: false), 5);
    });

    test('skips the first draw for the player going first', () {
      expect(DrawOdds.cardsSeen(turn: 1, goingFirst: true), 5);
      expect(DrawOdds.cardsSeen(turn: 1, goingFirst: false), 6);
      expect(DrawOdds.cardsSeen(turn: 3, goingFirst: true), 7);
      expect(DrawOdds.cardsSeen(turn: 3, goingFirst: false), 8);
    });
  });

  group('at least one copy', () {
    test('matches the hypergeometric distribution', () {
      // 1 - C(46,5) / C(50,5), worked out by hand.
      expect(
        DrawOdds.atLeastOne(deckSize: 50, copies: 4, drawn: 5),
        closeTo(0.35304, 0.00001),
      );
      // 1 - C(49,5) / C(50,5) = 5/50.
      expect(
        DrawOdds.atLeastOne(deckSize: 50, copies: 1, drawn: 5),
        closeTo(0.1, 1e-12),
      );
    });

    test('rises as more cards are drawn', () {
      final opening = DrawOdds.atLeastOne(deckSize: 50, copies: 4, drawn: 5);
      final later = DrawOdds.atLeastOne(deckSize: 50, copies: 4, drawn: 8);
      expect(later, greaterThan(opening));
    });

    test('is certain or impossible at the edges', () {
      expect(DrawOdds.atLeastOne(deckSize: 50, copies: 0, drawn: 5), 0);
      expect(DrawOdds.atLeastOne(deckSize: 50, copies: 4, drawn: 0), 0);
      expect(DrawOdds.atLeastOne(deckSize: 50, copies: 50, drawn: 1), 1);
      // Only 3 cards are not copies, so a 5-card draw must hit one.
      expect(DrawOdds.atLeastOne(deckSize: 50, copies: 47, drawn: 5), 1);
    });
  });
}
