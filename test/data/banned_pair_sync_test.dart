import 'dart:convert';
import 'dart:io';

import 'package:digi_card_app/data/db/app_database.dart';
import 'package:digi_card_app/data/sync/bulk_parser.dart';
import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/digimon_card.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// EX2-007 Mother D-Reaper as the bulk dump publishes it: a banned-pair entry
/// naming EX7-064 Shoto Kazama, with an allowance of zero that belongs to the
/// pairing rather than to the card.
Map<String, dynamic> _document({
  String number = 'EX2-007',
  String name = 'Mother D-Reaper',
  List<Map<String, dynamic>> limitations = const [
    {
      'date': '2025-03-28',
      'type': 'banned-pair',
      'allowance': 0,
      'paired-card-numbers': ['EX7-064'],
      'note': 'We will ban the use of these two cards in the same deck.',
    },
  ],
}) => {
  'data': {
    'type': 'card',
    'id': '/cards/en/$number',
    'attributes': {
      'number': number,
      'name': name,
      'category': 'digi-egg',
      'color': ['white'],
      'parallel-id': 0,
      'image': 'https://images.heroi.cc/cards/en/$number.webp',
      'limitations': limitations,
    },
  },
};

void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('bulk_pair_test');
  });

  tearDown(() => dir.delete(recursive: true));

  Future<List<ParsedCard>> parse(List<Map<String, dynamic>> documents) async {
    final file = File('${dir.path}/bulk.json');
    await file.writeAsString(jsonEncode(documents));
    return parseBulkFile(file.path);
  }

  test('a banned-pair card stays playable at four copies', () async {
    final card = (await parse([_document()])).single;

    expect(card.copyLimit, 4);
  });

  test('the cards it may not be run with are kept', () async {
    final card = (await parse([_document()])).single;

    final stored =
        (jsonDecode(card.limitations) as List).single as Map<String, dynamic>;
    expect(stored['type'], 'banned-pair');
    expect(stored['paired-card-numbers'], ['EX7-064']);

    // The entry is stored as it arrived, allowance and all, and it is reading
    // it that leaves the zero alone.
    expect(stored['allowance'], 0);
    expect(CardLimitation.fromJson(stored).effectiveAllowance, 4);
  });

  test('an outright ban still allows nothing', () async {
    final card = (await parse([
      _document(
        limitations: const [
          {'date': '2024-01-01', 'type': 'ban', 'allowance': 0},
        ],
      ),
    ])).single;

    expect(card.copyLimit, 0);
  });

  group('CardDao.pairRestrictedCards', () {
    late AppDatabase db;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.customStatement('PRAGMA foreign_keys = ON');
    });

    tearDown(() => db.close());

    Future<void> insert(ParsedCard card) => db
        .into(db.cards)
        .insert(
          CardsCompanion.insert(
            id: card.id,
            number: card.number,
            name: card.name,
            category: card.category,
            imageUrl: card.imageUrl,
            limitations: Value(card.limitations),
            copyLimit: Value(card.copyLimit),
          ),
        );

    test('finds the cards carrying a pairing and no others', () async {
      for (final card in await parse([
        _document(),
        _document(
          number: 'BT1-090',
          name: 'Gravity Crush',
          limitations: const [
            {'date': '2025-09-01', 'type': 'restrict', 'allowance': 1},
          ],
        ),
        _document(number: 'BT1-001', name: 'Agumon', limitations: const []),
      ])) {
        await insert(card);
      }

      final found = await db.cardDao.pairRestrictedCards();

      expect(found.map((c) => c.number), ['EX2-007']);
      expect(found.single.bannedWith, {'EX7-064'});
      expect(found.single.pairBans.single.type, LimitationType.bannedPair);
      expect(found.single.copyLimit, 4);
    });
  });
}
