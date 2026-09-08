import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/deck.dart';
import 'package:digi_card_app/domain/models/deck_list.dart';
import 'package:digi_card_app/domain/models/digimon_card.dart';
import 'package:flutter_test/flutter_test.dart';

DigimonCard _card({
  required String number,
  required String name,
  CardCategory category = CardCategory.digimon,
  int? level,
  int? playCost,
  CardFace? dualFace,
}) => DigimonCard(
  id: number,
  number: number,
  parallelId: 0,
  name: name,
  category: category,
  colors: const [CardColor.red],
  imageUrl: 'https://example.invalid/$number.webp',
  level: level,
  playCost: playCost,
  dualFace: dualFace,
);

DeckEntry _entry(DigimonCard card, int quantity) =>
    DeckEntry(cardNumber: card.number, quantity: quantity, card: card);

void main() {
  group('deck sections', () {
    test('run eggs, then Digimon by level, then Tamers and Options', () {
      final composition = DeckComposition([
        _entry(
          _card(
            number: 'BT1-050',
            name: 'Ice Wall',
            category: CardCategory.option,
          ),
          2,
        ),
        _entry(
          _card(number: 'BT1-040', name: 'Tai', category: CardCategory.tamer),
          3,
        ),
        _entry(_card(number: 'BT1-020', name: 'Greymon', level: 4), 4),
        _entry(_card(number: 'BT1-010', name: 'Agumon', level: 3), 4),
        _entry(
          _card(
            number: 'BT1-001',
            name: 'Koromon',
            category: CardCategory.digiEgg,
          ),
          4,
        ),
        _entry(_card(number: 'BT1-030', name: 'MetalGreymon', level: 5), 2),
      ]);

      expect(composition.sections.map((s) => s.label), [
        'Digi-Eggs · Lv.2',
        'Digimon · Lv.3',
        'Digimon · Lv.4',
        'Digimon · Lv.5',
        'Tamers',
        'Options',
      ]);
      expect(composition.sections.first.limit, DeckRules.maxEggDeckSize);
      expect(composition.sections[1].count, 4);
    });

    test('files a dual card under its Digimon face, not its Option face', () {
      // The data lists these the other way round from BT-25's printing, so
      // that the Digimon face has to be found on the dual rather than assumed.
      final dual = _card(
        number: 'BT25-043',
        name: 'Habakiri',
        category: CardCategory.option,
        dualFace: const CardFace(
          name: 'Habakirimon',
          category: CardCategory.digimon,
          colors: [CardColor.yellow],
        ),
      );

      final composition = DeckComposition([_entry(dual, 3)]);

      expect(composition.sections.single.title, 'Digimon');
      expect(composition.countOfCategory(CardCategory.option), 0);
      expect(composition.countOfCategory(CardCategory.digimon), 3);
    });

    test('leaves empty blocks out', () {
      final composition = DeckComposition([
        _entry(_card(number: 'BT1-010', name: 'Agumon', level: 3), 4),
      ]);

      expect(composition.sections.map((s) => s.label), ['Digimon · Lv.3']);
    });
  });

  group('writeDeckList', () {
    final composition = DeckComposition([
      _entry(_card(number: 'BT1-010', name: 'Agumon', level: 3), 4),
      _entry(
        _card(
          number: 'BT1-001',
          name: 'Koromon',
          category: CardCategory.digiEgg,
        ),
        4,
      ),
    ]);

    test('writes the default format, eggs first', () {
      expect(
        writeDeckList(composition, DeckListFormat.standard),
        '4 Koromon BT1-001\n4 Agumon BT1-010',
      );
    });

    test('brackets the card number for Untap', () {
      expect(
        writeDeckList(composition, DeckListFormat.untap),
        '4 Koromon (BT1-001)\n4 Agumon (BT1-010)',
      );
    });
  });

  group('writeStapleList', () {
    final cards = [
      _card(number: 'BT1-090', name: 'Gravity Crush'),
      _card(number: 'BT4-111', name: 'Jack Raid'),
    ];

    test('writes one copy of each card, in the order the list holds them', () {
      // A staple list is a set of cards; the copies belong to whatever deck
      // the reader puts them in.
      expect(
        writeStapleList(cards, DeckListFormat.standard),
        '1 Gravity Crush BT1-090\n1 Jack Raid BT4-111',
      );
    });

    test('takes the same formats a deck list does', () {
      expect(
        writeStapleList(cards, DeckListFormat.untap),
        '1 Gravity Crush (BT1-090)\n1 Jack Raid (BT4-111)',
      );
    });

    test('reads back through the deck list parser', () {
      // What it writes has to be what the importer can read, or the pair is
      // useless.
      final lines = readDeckList(
        writeStapleList(cards, DeckListFormat.standard),
      );

      expect(lines.map((l) => l.cardNumber), ['BT1-090', 'BT4-111']);
      expect(lines.map((l) => l.quantity), [1, 1]);
    });

    test('writes nothing for an empty list', () {
      expect(writeStapleList(const [], DeckListFormat.standard), isEmpty);
    });
  });

  group('readDeckList', () {
    test('reads both formats the app writes', () {
      final lines = readDeckList('4 Agumon BT1-010\n3 Koromon (BT1-001)');

      expect(lines.map((l) => l.quantity), [4, 3]);
      expect(lines.map((l) => l.cardNumber), ['BT1-010', 'BT1-001']);
      expect(lines.map((l) => l.name), ['Agumon', 'Koromon']);
    });

    test('accepts the quantity spellings lists are pasted with', () {
      final lines = readDeckList(
        '4x Agumon BT1-010\nx2 Greymon BT1-020\n'
        '1. Tai BT1-040',
      );

      expect(lines.map((l) => l.quantity), [4, 2, 1]);
      expect(lines.map((l) => l.cardNumber), ['BT1-010', 'BT1-020', 'BT1-040']);
    });

    test('skips blank lines, comments and section headings', () {
      final lines = readDeckList('''
// Egg deck
Egg Deck

4 Koromon BT1-001

Digimon
4 Agumon BT1-010
''');

      expect(lines.map((l) => l.cardNumber), ['BT1-001', 'BT1-010']);
    });

    test('does not mistake a hyphenated card name for a card number', () {
      final lines = readDeckList('4 Omnimon X-Antibody');

      expect(lines.single.cardNumber, isNull);
      expect(lines.single.name, 'Omnimon X-Antibody');
    });

    test('reads the odd number shapes the game prints', () {
      final lines = readDeckList('''
1 Promo Agumon P-001
2 Atratusmon ST23-09
3 Siriusmon (EX12-018)
4 Something BT11-TOKEN
''');

      expect(lines.map((l) => l.cardNumber), [
        'P-001',
        'ST23-09',
        'EX12-018',
        'BT11-TOKEN',
      ]);
    });
  });

  group('matchDeckList', () {
    final agumon = _card(number: 'BT1-010', name: 'Agumon', level: 3);
    final byNumber = {'BT1-010': agumon};
    final byName = {'agumon': agumon};

    test('matches on the printed number, whatever case it was typed in', () {
      final matches = matchDeckList(
        readDeckList('4 agumon bt1-010'),
        byNumber: byNumber,
        byName: const {},
      );

      expect(matches.single.card, agumon);
    });

    test('falls back to the name when the line carries no number', () {
      final matches = matchDeckList(
        readDeckList('4 Agumon'),
        byNumber: const {},
        byName: byName,
      );

      expect(matches.single.card, agumon);
    });

    test('reports a line the library does not know', () {
      final matches = matchDeckList(
        readDeckList('4 Nothingmon BT99-999'),
        byNumber: byNumber,
        byName: byName,
      );

      expect(matches.single.isResolved, isFalse);
      expect(matches.single.line.raw, '4 Nothingmon BT99-999');
    });

    test('sums two lines naming the same card', () {
      final matches = matchDeckList(
        readDeckList('3 Agumon BT1-010\n1 Agumon BT1-010'),
        byNumber: byNumber,
        byName: byName,
      );

      expect(quantitiesOf(matches), {'BT1-010': 4});
    });
  });

  test('a written list reads back into the same copies', () {
    final composition = DeckComposition([
      _entry(_card(number: 'BT1-010', name: 'Agumon', level: 3), 4),
      _entry(_card(number: 'BT1-020', name: 'Greymon', level: 4), 3),
      _entry(
        _card(
          number: 'BT1-001',
          name: 'Koromon',
          category: CardCategory.digiEgg,
        ),
        4,
      ),
    ]);
    final byNumber = {
      for (final entry in composition.allEntries) entry.cardNumber: entry.card,
    };

    for (final format in DeckListFormat.values) {
      final read = matchDeckList(
        readDeckList(writeDeckList(composition, format)),
        byNumber: byNumber,
        byName: const {},
      );

      expect(quantitiesOf(read), {
        'BT1-001': 4,
        'BT1-010': 4,
        'BT1-020': 3,
      }, reason: format.label);
    }
  });
}
