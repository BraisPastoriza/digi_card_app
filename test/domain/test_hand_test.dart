import 'dart:math';

import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/deck.dart';
import 'package:digi_card_app/domain/models/digimon_card.dart';
import 'package:digi_card_app/domain/models/test_hand.dart';
import 'package:flutter_test/flutter_test.dart';

DigimonCard _card(
  String number, {
  CardCategory category = CardCategory.digimon,
}) => DigimonCard(
  id: number,
  number: number,
  parallelId: 0,
  name: number,
  category: category,
  colors: const [CardColor.red],
  imageUrl: 'https://example.invalid/$number.webp',
);

DeckEntry _entry(String number, int quantity, {CardCategory? category}) =>
    DeckEntry(
      cardNumber: number,
      quantity: quantity,
      card: category == null
          ? _card(number)
          : _card(number, category: category),
    );

/// 50 main-deck cards as distinct 4-ofs plus a 2-of, and 5 Digi-Eggs.
List<DeckEntry> _legalDeck() => [
  for (var i = 0; i < 12; i++) _entry('BT1-${i.toString().padLeft(3, '0')}', 4),
  _entry('BT1-999', 2),
  _entry('BT1-EGG', 5, category: CardCategory.digiEgg),
];

void main() {
  group('TestHand.deal', () {
    test('deals five cards and five security off the main deck', () {
      final hand = TestHand.deal(
        DeckComposition(_legalDeck()),
        random: Random(7),
      )!;

      expect(hand.hand, hasLength(TestHand.handSize));
      expect(hand.security, hasLength(TestHand.securitySize));
    });

    test('never deals the same card twice over', () {
      // Ten cards off a 50-card deck, so the count of any one of them can
      // never be more than the copies the deck holds.
      final hand = TestHand.deal(
        DeckComposition(_legalDeck()),
        random: Random(11),
      )!;

      final dealt = <String, int>{};
      for (final card in [...hand.hand, ...hand.security]) {
        dealt[card.number] = (dealt[card.number] ?? 0) + 1;
      }
      for (final entry in dealt.entries) {
        expect(
          entry.value,
          lessThanOrEqualTo(entry.key == 'BT1-999' ? 2 : 4),
          reason: 'copies of ${entry.key} dealt',
        );
      }
    });

    test('leaves the Digi-Eggs out of the deck it deals from', () {
      // The egg deck is played from the breeding area, so an egg in the
      // opening hand would be a bug rather than a bad draw.
      for (var seed = 0; seed < 25; seed++) {
        final hand = TestHand.deal(
          DeckComposition(_legalDeck()),
          random: Random(seed),
        )!;
        expect(
          [...hand.hand, ...hand.security].map((c) => c.number),
          isNot(contains('BT1-EGG')),
        );
      }
    });

    test('refuses a main deck that is not 50 cards', () {
      final short = DeckComposition([
        _entry('BT1-001', 4),
        _entry('BT1-EGG', 5, category: CardCategory.digiEgg),
      ]);
      final over = DeckComposition([
        for (var i = 0; i < 13; i++)
          _entry('BT1-${i.toString().padLeft(3, '0')}', 4),
      ]);

      expect(TestHand.canDeal(short), isFalse);
      expect(TestHand.deal(short), isNull);
      expect(TestHand.canDeal(over), isFalse);
      expect(TestHand.deal(over), isNull);
    });

    test('deals a full egg deck no differently', () {
      // Legality is not the bar: a deck over its copy limit still deals.
      final composition = DeckComposition([
        _entry('BT1-001', 50),
        _entry('BT1-EGG', 9, category: CardCategory.digiEgg),
      ]);

      expect(composition.isLegal, isFalse);
      expect(TestHand.deal(composition, random: Random(3))?.hand, hasLength(5));
    });

    test('the same seed deals the same opening', () {
      // The screen re-deals only when asked to, so a rebuild must not reshuffle
      // the cards the user is reading.
      final first = TestHand.deal(
        DeckComposition(_legalDeck()),
        random: Random(42),
      )!;
      final second = TestHand.deal(
        DeckComposition(_legalDeck()),
        random: Random(42),
      )!;

      expect(first.hand.map((c) => c.number), second.hand.map((c) => c.number));
      expect(
        first.security.map((c) => c.number),
        second.security.map((c) => c.number),
      );
    });
  });
}
