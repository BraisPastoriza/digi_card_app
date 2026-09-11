import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/digimon_card.dart';
import 'package:digi_card_app/domain/models/pair_restrictions.dart';
import 'package:flutter_test/flutter_test.dart';

DigimonCard _card({
  required String number,
  required String name,
  List<CardLimitation> limitations = const [],
}) => DigimonCard(
  id: number,
  number: number,
  parallelId: 0,
  name: name,
  category: CardCategory.digimon,
  colors: const [CardColor.white],
  imageUrl: 'https://example.invalid/$number.webp',
  limitations: limitations,
);

/// EX2-007 Mother D-Reaper, which carries the March 2025 ruling naming
/// EX7-064 Shoto Kazama. Shoto itself carries nothing.
final _motherDReaper = _card(
  number: 'EX2-007',
  name: 'Mother D-Reaper',
  limitations: const [
    CardLimitation(
      type: LimitationType.bannedPair,
      date: '2025-03-28',
      pairedCardNumbers: ['EX7-064'],
      note: 'Banned together.',
    ),
  ],
);

void main() {
  test('the card carrying the ruling knows what it cannot run with', () {
    final restrictions = PairRestrictions.from(
      [_motherDReaper],
      namesByNumber: const {'EX7-064': 'Shoto Kazama'},
    );

    final found = restrictions.forNumber('EX2-007').single;
    expect(found.partnerNumber, 'EX7-064');
    expect(found.partnerLabel, 'Shoto Kazama (EX7-064)');
    expect(found.date, '2025-03-28');
    expect(found.note, 'Banned together.');
  });

  test('so does the card the ruling was not written on', () {
    final restrictions = PairRestrictions.from(
      [_motherDReaper],
      namesByNumber: const {'EX7-064': 'Shoto Kazama'},
    );

    final found = restrictions.forNumber('EX7-064').single;
    expect(found.partnerLabel, 'Mother D-Reaper (EX2-007)');
    expect(found.note, 'Banned together.');
  });

  test('a number with no ruling comes back empty', () {
    final restrictions = PairRestrictions.from([_motherDReaper]);

    expect(restrictions.forNumber('BT1-001'), isEmpty);
    expect(const PairRestrictions.empty().isEmpty, isTrue);
  });

  test('the number stands in for a card the library has not got', () {
    final restrictions = PairRestrictions.from([_motherDReaper]);

    expect(restrictions.forNumber('EX2-007').single.partnerLabel, 'EX7-064');
  });

  test('one ruling naming several cards reaches all of them', () {
    // BT20-037 Chaosmon: Valdur Arm, banned alongside either of two cards.
    final chaosmon = _card(
      number: 'BT20-037',
      name: 'Chaosmon: Valdur Arm',
      limitations: const [
        CardLimitation(
          type: LimitationType.bannedPair,
          date: '2025-09-01',
          pairedCardNumbers: ['BT17-035', 'EX8-037'],
        ),
      ],
    );

    final restrictions = PairRestrictions.from([chaosmon]);

    expect(restrictions.forNumber('BT20-037'), hasLength(2));
    expect(
      restrictions.forNumber('BT17-035').single.partnerNumber,
      'BT20-037',
    );
    expect(restrictions.forNumber('EX8-037').single.partnerNumber, 'BT20-037');
  });

  test('a pairing written on both cards is still listed once each way', () {
    final shoto = _card(
      number: 'EX7-064',
      name: 'Shoto Kazama',
      limitations: const [
        CardLimitation(
          type: LimitationType.bannedPair,
          date: '2025-03-28',
          pairedCardNumbers: ['EX2-007'],
        ),
      ],
    );

    final restrictions = PairRestrictions.from([_motherDReaper, shoto]);

    expect(restrictions.forNumber('EX2-007'), hasLength(1));
    expect(restrictions.forNumber('EX7-064'), hasLength(1));
  });

  test('a lifted pairing is not in the index', () {
    final lifted = _card(
      number: 'EX2-007',
      name: 'Mother D-Reaper',
      limitations: const [
        CardLimitation(
          type: LimitationType.bannedPair,
          date: '2025-03-28',
          pairedCardNumbers: ['EX7-064'],
        ),
        CardLimitation(type: LimitationType.unrestrict, date: '2026-01-01'),
      ],
    );

    expect(PairRestrictions.from([lifted]).isEmpty, isTrue);
  });
}
