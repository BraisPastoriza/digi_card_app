import 'package:digi_card_app/data/db/default_staples.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('defaultStapleLists', () {
    test('every list is named and has cards in it', () {
      for (final list in defaultStapleLists) {
        expect(list.name.trim(), isNotEmpty);
        expect(list.cardNumbers, isNotEmpty, reason: list.name);
      }
    });

    test('no two lists share a name', () {
      final names = defaultStapleLists.map((l) => l.name).toList();

      expect(names.toSet(), hasLength(names.length));
    });

    test('no list holds the same card twice', () {
      // A list is a set of cards, and the table's key would drop the second
      // copy anyway — better to catch a duplicate here than to seed a list
      // whose count is a card short.
      for (final list in defaultStapleLists) {
        expect(
          list.cardNumbers.toSet(),
          hasLength(list.cardNumbers.length),
          reason: list.name,
        );
      }
    });

    test('every entry looks like a printed card number', () {
      // Deck entries and staples both key on the printed number, so a typo
      // here is a card that silently never resolves.
      final cardNumber = RegExp(r'^[A-Z]+\d*-\d+$');
      for (final list in defaultStapleLists) {
        for (final number in list.cardNumbers) {
          expect(
            cardNumber.hasMatch(number),
            isTrue,
            reason: '${list.name}: "$number"',
          );
        }
      }
    });
  });
}
