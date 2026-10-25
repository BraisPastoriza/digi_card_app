import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/deck.dart';
import 'package:digi_card_app/domain/models/deck_list.dart';
import 'package:digi_card_app/domain/models/deck_qr.dart';
import 'package:digi_card_app/domain/models/digimon_card.dart';
import 'package:flutter_test/flutter_test.dart';

DeckEntry _entry(
  String number,
  int quantity, {
  CardCategory category = CardCategory.digimon,
  int? level = 3,
}) => DeckEntry(
  cardNumber: number,
  quantity: quantity,
  card: DigimonCard(
    id: number,
    number: number,
    parallelId: 0,
    name: 'Card $number',
    category: category,
    colors: const [CardColor.red],
    imageUrl: 'https://example.invalid/$number.webp',
    level: level,
  ),
);

void main() {
  final deck = DeckComposition([
    _entry('BT1-001', 4, category: CardCategory.digiEgg, level: 2),
    _entry('BT1-010', 4),
    _entry('BT1-085', 2, category: CardCategory.tamer, level: null),
  ]);

  test('holds the name and one short line per card', () {
    expect(
      writeDeckQr('Red Hybrid', deck),
      '# Red Hybrid\n4 BT1-001\n4 BT1-010\n2 BT1-085',
    );
  });

  test('reads back through the ordinary deck list importer', () {
    final lines = readDeckList(writeDeckQr('Red Hybrid', deck));

    expect(
      {for (final line in lines) line.cardNumber: line.quantity},
      {'BT1-001': 4, 'BT1-010': 4, 'BT1-085': 2},
    );
  });

  test('carries the deck name, and only a name line counts as one', () {
    expect(deckNameInQr(writeDeckQr('Red Hybrid', deck)), 'Red Hybrid');
    expect(deckNameInQr('4 BT1-010\n4 BT1-020'), isNull);
    expect(deckNameInQr('#   \n4 BT1-010'), isNull);
  });

  test('keeps a name with a line break on its own line', () {
    expect(deckNameInQr(writeDeckQr('Red\nHybrid', deck)), 'Red Hybrid');
  });
}
