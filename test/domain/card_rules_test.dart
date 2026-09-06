import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/deck.dart';
import 'package:digi_card_app/domain/models/digimon_card.dart';
import 'package:flutter_test/flutter_test.dart';

DigimonCard _card({
  required String number,
  String name = 'Agumon',
  CardCategory category = CardCategory.digimon,
  int? level,
}) => DigimonCard(
  id: number,
  number: number,
  parallelId: 0,
  name: name,
  category: category,
  colors: const [CardColor.red],
  imageUrl: 'https://example.invalid/$number.webp',
  level: level,
);

void main() {
  group('CardRarity ordering', () {
    test('runs from least to most rare', () {
      final rarities = ['SEC', 'C', 'UR', 'P', 'R', 'U', 'SR']
        ..sort(CardRarity.compare);

      expect(rarities, ['C', 'U', 'R', 'SR', 'UR', 'SEC', 'P']);
    });

    test('puts a code the game has not printed yet last', () {
      final rarities = ['XR', 'C', 'SEC']..sort(CardRarity.compare);

      expect(rarities, ['C', 'SEC', 'XR']);
    });
  });

  group('CardRarity.normalize', () {
    test('keeps the printed codes, folding case', () {
      expect(CardRarity.normalize('C'), 'C');
      expect(CardRarity.normalize('sr'), 'SR');
      expect(CardRarity.normalize(' sec '), 'SEC');
    });

    test('falls back to R for anything the game has not printed', () {
      // A BT-26 Tamer arrives as RC from the secondary source but is printed R.
      expect(CardRarity.normalize('RC'), 'R');
      expect(CardRarity.normalize('XYZ'), 'R');
    });

    test('gives a token no rarity, whatever the source publishes', () {
      // Tokens are not collected, so none is printed on them. Six of the seven
      // arrive with the field empty; BT24-TOKEN carries a stray Japanese word.
      expect(CardRarity.normalize('デジモン', isToken: true), isNull);
      expect(CardRarity.normalize('SR', isToken: true), isNull);
      expect(CardRarity.normalize(null, isToken: true), isNull);
    });

    test('leaves a card with no rarity without one', () {
      expect(CardRarity.normalize(null), isNull);
      expect(CardRarity.normalize('  '), isNull);
    });
  });

  group('CardTrait.normalize', () {
    test('drops the App Name qualifier', () {
      expect(CardTrait.normalize('Tweet (App Name)'), 'Tweet');
      expect(CardTrait.normalize('Copy & Paste (App Name)'), 'Copy & Paste');
      expect(CardTrait.normalize('Role-playing (App Name)'), 'Role-playing');
    });

    test('folds the hyphenated X Antibody into the printed spelling', () {
      expect(CardTrait.normalize('X-Antibody'), 'X Antibody');
      expect(CardTrait.normalize('X Antibody'), 'X Antibody');
    });

    test('leaves every other trait alone', () {
      expect(CardTrait.normalize('Dark Animal'), 'Dark Animal');
      expect(CardTrait.normalize('Appmon'), 'Appmon');
      expect(CardTrait.normalize('App Driver'), 'App Driver');
    });

    test('merges the two spellings a card may carry at once', () {
      expect(CardTrait.normalizeAll(['Tweet (App Name)', 'Tweet']), ['Tweet']);
      expect(CardTrait.normalizeAll(['X-Antibody', 'X Antibody']), [
        'X Antibody',
      ]);
    });

    test('drops a trait that normalises to nothing', () {
      expect(CardTrait.normalizeAll(['(App Name)', '  ', 'Beast']), ['Beast']);
    });
  });

  group('DigimonCard.isToken', () {
    test('recognises every shape of printed token number', () {
      for (final number in [
        'TOKEN',
        'BT22-TOKEN',
        'BT24-TOKEN',
        'ST22-TOKEN01',
      ]) {
        expect(_card(number: number).isToken, isTrue, reason: number);
        expect(TokenCard.hasTokenNumber(number), isTrue, reason: number);
      }
    });

    test('leaves ordinary cards alone', () {
      for (final number in ['BT1-010', 'ST23-09', 'P-001', 'EX12-018']) {
        expect(_card(number: number).isToken, isFalse, reason: number);
      }
    });
  });

  group('tokens in a deck', () {
    test('are reported as an error, so an old deck holding one says why', () {
      final composition = DeckComposition([
        DeckEntry(
          cardNumber: 'BT22-TOKEN',
          quantity: 1,
          card: _card(number: 'BT22-TOKEN', name: 'Familiar'),
        ),
      ]);

      expect(composition.isLegal, isFalse);
      expect(
        composition.issues.map((i) => i.message),
        contains(contains('is a token')),
      );
    });

    test('a deck without one is not flagged', () {
      final composition = DeckComposition([
        DeckEntry(
          cardNumber: 'BT1-010',
          quantity: 4,
          card: _card(number: 'BT1-010', level: 3),
        ),
      ]);

      expect(
        composition.issues.map((i) => i.message),
        isNot(contains(contains('is a token'))),
      );
    });
  });
}
