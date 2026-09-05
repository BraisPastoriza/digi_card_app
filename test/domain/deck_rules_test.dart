import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/deck.dart';
import 'package:digi_card_app/domain/models/digimon_card.dart';
import 'package:flutter_test/flutter_test.dart';

DigimonCard _card({
  String number = 'BT1-001',
  String name = 'Agumon',
  CardCategory category = CardCategory.digimon,
  List<CardColor> colors = const [CardColor.red],
  int? level,
  int? playCost,
  int? dp,
  List<CardLimitation> limitations = const [],
}) => DigimonCard(
  id: number,
  number: number,
  parallelId: 0,
  name: name,
  category: category,
  colors: colors,
  imageUrl: 'https://example.invalid/$number.webp',
  level: level,
  playCost: playCost,
  dp: dp,
  limitations: limitations,
);

DeckEntry _entry(DigimonCard card, int quantity) =>
    DeckEntry(cardNumber: card.number, quantity: quantity, card: card);

/// Builds a legal 50-card main deck out of distinct 4-ofs plus a remainder.
List<DeckEntry> _fullMainDeck() => [
  for (var i = 0; i < 12; i++)
    _entry(_card(number: 'BT1-${i.toString().padLeft(3, '0')}'), 4),
  _entry(_card(number: 'BT1-999'), 2),
];

void main() {
  group('DeckComposition split', () {
    test('separates Digi-Eggs from the main deck', () {
      final composition = DeckComposition([
        _entry(_card(number: 'BT1-001'), 4),
        _entry(
          _card(number: 'BT1-002', category: CardCategory.digiEgg),
          4,
        ),
        _entry(_card(number: 'BT1-003', category: CardCategory.tamer), 2),
      ]);

      expect(composition.mainDeckCount, 6);
      expect(composition.eggDeckCount, 4);
      expect(composition.countOfCategory(CardCategory.tamer), 2);
    });

    test('counts a multi-colour card once per colour', () {
      final composition = DeckComposition([
        _entry(
          _card(colors: const [CardColor.red, CardColor.blue]),
          3,
        ),
      ]);

      expect(composition.colorSpread, {CardColor.red: 3, CardColor.blue: 3});
    });

    test('builds the cost curve from the main deck only', () {
      final composition = DeckComposition([
        _entry(_card(number: 'BT1-001', playCost: 3), 4),
        _entry(_card(number: 'BT1-002', playCost: 3), 2),
        _entry(_card(number: 'BT1-003', playCost: 5), 1),
        _entry(
          _card(
            number: 'BT1-004',
            category: CardCategory.digiEgg,
            playCost: 0,
          ),
          4,
        ),
      ]);

      expect(composition.costCurve, {3: 6, 5: 1});
    });
  });

  group('DeckComposition legality', () {
    test('a 50-card deck with eggs is legal', () {
      final composition = DeckComposition([
        ..._fullMainDeck(),
        _entry(
          _card(number: 'BT1-500', category: CardCategory.digiEgg),
          4,
        ),
      ]);

      expect(composition.mainDeckCount, DeckRules.mainDeckSize);
      expect(composition.isLegal, isTrue);
      expect(composition.issues, isEmpty);
    });

    test('reports how many cards the main deck is missing', () {
      final composition = DeckComposition([_entry(_card(), 4)]);

      expect(composition.isLegal, isFalse);
      expect(
        composition.issues.first.message,
        contains('needs 46 more cards'),
      );
    });

    test('reports an oversized main deck', () {
      final composition = DeckComposition([
        ..._fullMainDeck(),
        _entry(_card(number: 'BT1-998'), 3),
      ]);

      expect(
        composition.issues
            .where((i) => i.severity == DeckIssueSeverity.error)
            .map((i) => i.message),
        contains(contains('over by 3 cards')),
      );
    });

    test('rejects more than five Digi-Eggs', () {
      final composition = DeckComposition([
        ..._fullMainDeck(),
        _entry(
          _card(number: 'BT1-500', category: CardCategory.digiEgg),
          4,
        ),
        _entry(
          _card(number: 'BT1-501', category: CardCategory.digiEgg),
          2,
        ),
      ]);

      expect(composition.isLegal, isFalse);
      expect(
        composition.issues.map((i) => i.message),
        contains(contains('Egg deck is over by 1')),
      );
    });

    test('warns but stays legal when the egg deck is empty', () {
      final composition = DeckComposition(_fullMainDeck());

      expect(composition.isLegal, isTrue);
      expect(
        composition.issues.single.severity,
        DeckIssueSeverity.warning,
      );
    });

    test('rejects a fifth copy of a card', () {
      final composition = DeckComposition([
        _entry(_card(number: 'BT1-001'), 5),
      ]);

      expect(
        composition.issues.map((i) => i.message),
        contains(contains('max 4')),
      );
    });

    test('applies the restriction list copy limit', () {
      final restricted = _card(
        number: 'BT1-090',
        name: 'Gravity Crush',
        category: CardCategory.option,
        limitations: const [
          CardLimitation(
            type: LimitationType.restrict,
            date: '2025-09-01',
            allowance: 1,
          ),
        ],
      );

      expect(restricted.copyLimit, 1);
      final composition = DeckComposition([_entry(restricted, 2)]);
      expect(
        composition.issues.map((i) => i.message),
        contains(contains('restricted to 1 copy')),
      );
    });
  });

  group('CardLimitation', () {
    test('defaults to four copies with no limitations', () {
      expect(CardLimitation.copyLimitIn(const []), 4);
      expect(CardLimitation.activeIn(const []), isNull);
    });

    test('a ban allows no copies', () {
      expect(
        CardLimitation.copyLimitIn(const [
          CardLimitation(type: LimitationType.ban, date: '2024-01-01'),
        ]),
        0,
      );
    });

    test('the most recent restriction wins', () {
      final active = CardLimitation.activeIn(const [
        CardLimitation(
          type: LimitationType.restrict,
          date: '2023-01-01',
          allowance: 1,
        ),
        CardLimitation(type: LimitationType.ban, date: '2025-01-01'),
      ]);

      expect(active?.type, LimitationType.ban);
    });

    test('a later unrestrict lifts an earlier restriction', () {
      final limitations = const [
        CardLimitation(
          type: LimitationType.restrict,
          date: '2023-01-01',
          allowance: 1,
        ),
        CardLimitation(type: LimitationType.unrestrict, date: '2024-06-01'),
      ];

      expect(CardLimitation.activeIn(limitations), isNull);
      expect(CardLimitation.copyLimitIn(limitations), 4);
    });

    test('an unrestrict older than the restriction does not lift it', () {
      final limitations = const [
        CardLimitation(type: LimitationType.unrestrict, date: '2022-01-01'),
        CardLimitation(
          type: LimitationType.restrict,
          date: '2025-09-01',
          allowance: 1,
        ),
      ];

      expect(CardLimitation.copyLimitIn(limitations), 1);
    });
  });
}
