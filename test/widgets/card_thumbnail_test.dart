import 'package:digi_card_app/core/providers.dart';
import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/digimon_card.dart';
import 'package:digi_card_app/domain/models/pair_restrictions.dart';
import 'package:digi_card_app/shared/widgets/card_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

DigimonCard _card({
  String number = 'BT2-047',
  String name = 'Machinedramon',
  List<CardLimitation> limitations = const [],
}) => DigimonCard(
  id: number,
  number: number,
  parallelId: 0,
  name: name,
  category: CardCategory.digimon,
  colors: const [CardColor.black],
  imageUrl: 'https://example.invalid/$number.webp',
  limitations: limitations,
);

const _pairedWithShoto = CardLimitation(
  type: LimitationType.bannedPair,
  date: '2025-03-28',
  pairedCardNumbers: ['EX7-064'],
);

const _restrictedToOne = CardLimitation(
  type: LimitationType.restrict,
  date: '2025-09-01',
  allowance: 1,
);

/// Puts a thumbnail on screen at a size a grid would give it.
///
/// [pairedCards] stands in for the library's banned-pair index, which the real
/// thumbnail reads from the database.
Future<void> _pump(
  WidgetTester tester,
  DigimonCard card, {
  double width = 150,
  List<DigimonCard> pairedCards = const [],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        pairRestrictionsProvider.overrideWith(
          (ref) => PairRestrictions.from(pairedCards),
        ),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: width,
              height: width / cardAspectRatio,
              child: CardThumbnail(card: card),
            ),
          ),
        ),
      ),
    ),
  );
  // The index arrives a frame later, the same as it would on a real screen.
  await tester.pump();
}

void main() {
  testWidgets('an unrestricted card carries no badge', (tester) async {
    await _pump(tester, _card());

    expect(find.text('BAN'), findsNothing);
    expect(find.textContaining('×'), findsNothing);
  });

  testWidgets('a banned card is called banned', (tester) async {
    await _pump(
      tester,
      _card(
        limitations: const [
          CardLimitation(type: LimitationType.ban, date: '2023-04-14'),
        ],
      ),
    );

    expect(find.text('BAN'), findsOneWidget);
  });

  testWidgets('a restricted card carries the copies it allows', (tester) async {
    await _pump(
      tester,
      _card(
        limitations: const [
          CardLimitation(type: LimitationType.restrict, date: '2023-04-14'),
        ],
      ),
    );

    expect(find.text('×1'), findsOneWidget);
  });

  testWidgets('a lifted restriction leaves no badge', (tester) async {
    // Restriction entries accumulate; an unrestrict that postdates the limit
    // puts the card back to four copies, and the badge has to follow.
    await _pump(
      tester,
      _card(
        limitations: const [
          CardLimitation(type: LimitationType.restrict, date: '2023-04-14'),
          CardLimitation(type: LimitationType.unrestrict, date: '2024-06-21'),
        ],
      ),
    );

    expect(find.text('×1'), findsNothing);
    expect(find.text('BAN'), findsNothing);
  });

  testWidgets('the badge follows an allowance the list spells out', (
    tester,
  ) async {
    await _pump(
      tester,
      _card(
        limitations: const [
          CardLimitation(
            type: LimitationType.restrict,
            date: '2023-04-14',
            allowance: 2,
          ),
        ],
      ),
    );

    expect(find.text('×2'), findsOneWidget);
  });

  group('banned pairs', () {
    // EX2-007 Mother D-Reaper carries the ruling; EX7-064 Shoto Kazama, the
    // card it names, carries nothing at all.
    final motherDReaper = _card(
      number: 'EX2-007',
      name: 'Mother D-Reaper',
      limitations: const [_pairedWithShoto],
    );
    final shotoKazama = _card(number: 'EX7-064', name: 'Shoto Kazama');

    /// Mother D-Reaper as she would be if the list also cut her to one copy:
    /// the two entries are separate rulings and both have to show.
    final restrictedAndPaired = _card(
      number: 'EX2-007',
      name: 'Mother D-Reaper',
      limitations: const [_pairedWithShoto, _restrictedToOne],
    );

    testWidgets('the card the ruling is written on is marked', (tester) async {
      await _pump(tester, motherDReaper, pairedCards: [motherDReaper]);

      expect(find.text('PAIR'), findsOneWidget);
      // It is not a copy limit, and must not be mistaken for one.
      expect(find.text('BAN'), findsNothing);
      expect(find.textContaining('×'), findsNothing);
    });

    testWidgets('so is the card on the other side of it', (tester) async {
      await _pump(tester, shotoKazama, pairedCards: [motherDReaper]);

      expect(find.text('PAIR'), findsOneWidget);
    });

    testWidgets('a card in no pairing is left alone', (tester) async {
      await _pump(tester, _card(), pairedCards: [motherDReaper]);

      expect(find.text('PAIR'), findsNothing);
    });

    testWidgets('a restricted card in a pairing carries both', (tester) async {
      await _pump(
        tester,
        restrictedAndPaired,
        pairedCards: [restrictedAndPaired],
      );

      expect(find.text('×1'), findsOneWidget);
      expect(find.text('PAIR'), findsOneWidget);
    });

    testWidgets('both badges still fit a dealt card', (tester) async {
      await _pump(
        tester,
        restrictedAndPaired,
        pairedCards: [restrictedAndPaired],
        width: 70,
      );

      expect(find.text('×1'), findsOneWidget);
      expect(find.text('PAIR'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('it still fits on a thumbnail the size of a dealt card', (
    tester,
  ) async {
    // The hand and the list previews are around 70px wide; the badge shrinks
    // rather than covering the art or overflowing it.
    await _pump(
      tester,
      _card(
        limitations: const [
          CardLimitation(type: LimitationType.ban, date: '2023-04-14'),
        ],
      ),
      width: 70,
    );

    expect(find.text('BAN'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
