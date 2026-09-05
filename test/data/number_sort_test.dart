import 'package:digi_card_app/data/sync/bulk_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildNumberSort', () {
    /// Sorts card numbers the way the generated keys would in SQL.
    List<String> sorted(List<String> numbers) => numbers.toList()
      ..sort((a, b) => buildNumberSort(a, 0).compareTo(buildNumberSort(b, 0)));

    test('orders card numbers numerically, not lexicographically', () {
      expect(sorted(['BT1-010', 'BT1-002', 'BT1-100', 'BT1-009']), [
        'BT1-002',
        'BT1-009',
        'BT1-010',
        'BT1-100',
      ]);
    });

    test('orders set numbers numerically', () {
      expect(sorted(['BT10-001', 'BT9-001', 'BT2-001']), [
        'BT2-001',
        'BT9-001',
        'BT10-001',
      ]);
    });

    test('groups by set prefix before number', () {
      expect(sorted(['ST1-01', 'BT1-001', 'EX1-001', 'AD1-001']), [
        'AD1-001',
        'BT1-001',
        'EX1-001',
        'ST1-01',
      ]);
    });

    test('sorts token cards after every numbered card in their set', () {
      final key = buildNumberSort('BT22-TOKEN', 0);
      final last = buildNumberSort('BT22-999', 0);
      expect(key.compareTo(last), greaterThan(0));
    });

    test('keeps alternate arts next to their base printing', () {
      final base = buildNumberSort('BT25-043', 0);
      final parallel = buildNumberSort('BT25-043', 1);
      final next = buildNumberSort('BT25-044', 0);

      expect(base.compareTo(parallel), lessThan(0));
      expect(parallel.compareTo(next), lessThan(0));
    });

    test('handles a number with no set digits', () {
      expect(() => buildNumberSort('P-001', 0), returnsNormally);
      expect(() => buildNumberSort('TOKEN', 0), returnsNormally);
    });
  });
}
