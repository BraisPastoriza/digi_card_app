import 'package:digi_card_app/domain/models/banlist.dart';
import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/digimon_card.dart';
import 'package:flutter_test/flutter_test.dart';

DigimonCard _card(
  String number, {
  List<CardLimitation> limitations = const [],
}) => DigimonCard(
  id: number,
  number: number,
  parallelId: 0,
  name: 'Card $number',
  category: CardCategory.digimon,
  colors: const [CardColor.red],
  imageUrl: 'https://example.invalid/$number.webp',
  limitations: limitations,
);

void main() {
  test('separates banned cards from limited ones, by allowance', () {
    final banned = _card(
      'BT1-001',
      limitations: const [
        CardLimitation(type: LimitationType.ban, date: '2024-01-01'),
      ],
    );
    final one = _card(
      'BT1-002',
      limitations: const [
        CardLimitation(type: LimitationType.restrict, date: '2025-03-01'),
      ],
    );
    final two = _card(
      'BT1-003',
      limitations: const [
        CardLimitation(
          type: LimitationType.restrict,
          allowance: 2,
          date: '2023-06-01',
        ),
      ],
    );

    final banlist = Banlist.from(
      restricted: [banned, two, one],
      pairCarriers: const [],
    );

    expect(banlist.banned, [banned]);
    expect(banlist.limited.keys, [1, 2]);
    expect(banlist.limited[1], [one]);
    expect(banlist.limited[2], [two]);
    expect(banlist.latestDate, '2025-03-01');
  });

  test('lists each pairing with the partners the library has', () {
    final carrier = _card(
      'EX2-007',
      limitations: const [
        CardLimitation(
          type: LimitationType.bannedPair,
          date: '2025-07-01',
          pairedCardNumbers: ['EX7-064', 'BT9-999'],
        ),
      ],
    );
    final partner = _card('EX7-064');

    final banlist = Banlist.from(
      restricted: const [],
      pairCarriers: [carrier],
      partners: {'EX7-064': partner},
    );

    expect(banlist.banned, isEmpty);
    final pair = banlist.pairs.single;
    expect(pair.cardNumber, 'EX2-007');
    expect(pair.partnerNumbers, ['EX7-064', 'BT9-999']);
    expect(pair.cards, {'EX2-007': carrier, 'EX7-064': partner});
    expect(banlist.latestDate, '2025-07-01');
  });

  test('a pairing recorded on both cards is listed once', () {
    CardLimitation ban(List<String> partners) => CardLimitation(
      type: LimitationType.bannedPair,
      date: '2025-09-01',
      pairedCardNumbers: partners,
    );
    final taomon = _card(
      'BT17-035',
      limitations: [
        ban(['BT20-037']),
      ],
    );
    final chaosmon = _card(
      'BT20-037',
      limitations: [
        ban(['BT17-035', 'EX8-037']),
      ],
    );

    final pairs = Banlist.from(
      restricted: const [],
      pairCarriers: [taomon, chaosmon],
    ).pairs;

    expect(pairs, hasLength(1));
    expect(pairs.single.cardNumber, 'BT20-037');
    expect(pairs.single.partnerNumbers, ['BT17-035', 'EX8-037']);
  });

  test('cards banned alongside one that carries nothing share its row', () {
    CardLimitation ban(String date) => CardLimitation(
      type: LimitationType.bannedPair,
      date: date,
      pairedCardNumbers: const ['EX5-065'],
    );
    final banlist = Banlist.from(
      restricted: const [],
      pairCarriers: [
        _card('BT13-102', limitations: [ban('2024-01-19')]),
        _card('P-097', limitations: [ban('2024-01-19')]),
        _card(
          'EX2-007',
          limitations: [
            const CardLimitation(
              type: LimitationType.bannedPair,
              date: '2025-03-28',
              pairedCardNumbers: ['EX7-064'],
            ),
          ],
        ),
      ],
    );

    expect(banlist.pairs.map((p) => p.cardNumber), ['EX2-007', 'EX5-065']);
    expect(banlist.pairs.last.partnerNumbers, ['BT13-102', 'P-097']);
  });

  test('a lifted pair ruling is not listed', () {
    final carrier = _card(
      'EX2-007',
      limitations: const [
        CardLimitation(
          type: LimitationType.bannedPair,
          date: '2025-07-01',
          pairedCardNumbers: ['EX7-064'],
        ),
        CardLimitation(type: LimitationType.unrestrict, date: '2026-01-01'),
      ],
    );

    expect(
      Banlist.from(restricted: const [], pairCarriers: [carrier]).isEmpty,
      isTrue,
    );
  });
}
