import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/digimon_card.dart';
import 'package:digi_card_app/shared/widgets/card_thumbnail.dart';
import 'package:flutter/material.dart';
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

/// Puts a thumbnail on screen at a size a grid would give it.
Future<void> _pump(
  WidgetTester tester,
  DigimonCard card, {
  double width = 150,
}) {
  return tester.pumpWidget(
    MaterialApp(
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
  );
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
