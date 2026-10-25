import 'package:digi_card_app/domain/models/restriction_change.dart';
import 'package:flutter_test/flutter_test.dart';

RestrictionSnapshot _snapshot(
  Map<String, int> limits, [
  Set<(String, String)> pairs = const {},
]) => RestrictionSnapshot(
  limits: limits,
  pairs: {for (final (a, b) in pairs) RestrictionSnapshot.pair(a, b)},
  names: {for (final number in limits.keys) number: 'Card $number'},
);

void main() {
  group('changes between two lists', () {
    test('finds a card restricted and a card freed', () {
      final before = _snapshot({'BT1-001': 4, 'BT2-002': 1, 'BT3-003': 4});
      final after = _snapshot({'BT1-001': 1, 'BT2-002': 4, 'BT3-003': 4});

      final changes = before.changesTo(after).cast<LimitChange>();

      expect(changes.map((c) => (c.cardNumber, c.oldLimit, c.newLimit)), {
        ('BT1-001', 4, 1),
        ('BT2-002', 1, 4),
      });
    });

    test('ignores cards that arrived with the sync', () {
      final before = _snapshot({'BT1-001': 4});
      final after = _snapshot({'BT1-001': 4, 'BT9-009': 0});

      expect(before.changesTo(after), isEmpty);
    });

    test('finds a pairing banned, whichever side records it', () {
      final before = _snapshot({'A-001': 4, 'B-002': 4});
      final after = _snapshot({'A-001': 4, 'B-002': 4}, {('B-002', 'A-001')});

      final change = before.changesTo(after).single as PairChange;

      expect(change.banned, isTrue);
      expect({change.cardNumber, change.partnerNumber}, {'A-001', 'B-002'});
    });

    test('finds a pairing lifted', () {
      final before = _snapshot({'A-001': 4, 'B-002': 4}, {('A-001', 'B-002')});
      final after = _snapshot({'A-001': 4, 'B-002': 4});

      expect((before.changesTo(after).single as PairChange).banned, isFalse);
    });
  });

  group('what a change does to a deck', () {
    const limited = LimitChange(
      cardNumber: 'BT1-001',
      cardName: 'Agumon',
      oldLimit: 4,
      newLimit: 1,
    );
    const freed = LimitChange(
      cardNumber: 'BT2-002',
      cardName: 'Gabumon',
      oldLimit: 1,
      newLimit: 4,
    );
    const pair = PairChange(
      cardNumber: 'A-001',
      cardName: 'A',
      partnerNumber: 'B-002',
      partnerName: 'B',
      banned: true,
    );

    test('a tighter limit matters only past the new cap', () {
      expect(impactOn({'BT1-001': 4}, [limited]).single.breaksDeck, isTrue);
      expect(impactOn({'BT1-001': 1}, [limited]), isEmpty);
    });

    test('a looser limit matters to a deck that was at the old cap', () {
      final impact = impactOn({'BT2-002': 1}, [freed]).single;
      expect(impact.breaksDeck, isFalse);
      expect(impact.copies, 1);
    });

    test('a pairing matters only to a deck running both cards', () {
      expect(impactOn({'A-001': 4, 'B-002': 1}, [pair]), hasLength(1));
      expect(impactOn({'A-001': 4}, [pair]), isEmpty);
    });

    test('a change to a card the deck does not run is not its business', () {
      expect(impactOn({'EX1-001': 4}, [limited, freed, pair]), isEmpty);
    });
  });
}
