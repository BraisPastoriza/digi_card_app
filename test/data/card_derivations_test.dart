import 'dart:convert';

import 'package:digi_card_app/data/db/app_database.dart';
import 'package:digi_card_app/data/db/card_data_versions.dart';
import 'package:digi_card_app/data/db/tables.dart';
import 'package:digi_card_app/data/sync/bulk_parser.dart';
import 'package:digi_card_app/data/sync/card_derivations.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// BT22-062, whose Collision reminder text mentions Blocker. Stored as an
/// install running the old parser would have stored it: with Blocker.
const _collisionEffect =
    "＜Collision＞ (During this Digimon's attack, all of your opponent's "
    "Digimon gain ＜Blocker＞, and must block if possible.)\n"
    "[When Digivolving] This Digimon gets +4000 DP until your opponent's "
    'turn ends.';

void main() {
  late AppDatabase db;
  late CardDerivations derivations;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    derivations = CardDerivations(db);
  });

  tearDown(() => db.close());

  Future<void> insertCard({
    required String id,
    String? effect,
    String keywords = '',
    String numberSort = '',
    int copyLimit = 4,
    String requirements = '[]',
  }) async {
    await db
        .into(db.cards)
        .insert(
          CardsCompanion.insert(
            id: id,
            number: id,
            name: id,
            category: 'digimon',
            imageUrl: 'https://example.test/$id.webp',
            effect: Value(effect),
            keywords: Value(keywords),
            numberSort: Value(numberSort),
            copyLimit: Value(copyLimit),
            digivolutionRequirements: Value(requirements),
          ),
        );
    for (final keyword in decodeList(keywords)) {
      await db
          .into(db.cardKeywords)
          .insert(CardKeywordsCompanion.insert(cardId: id, keyword: keyword));
    }
  }

  Future<CardRow> card(String id) =>
      (db.select(db.cards)..where((c) => c.id.equals(id))).getSingle();

  Future<List<String>> keywordsOf(String id) async {
    final rows = await (db.select(
      db.cardKeywords,
    )..where((k) => k.cardId.equals(id))).get();
    return rows.map((r) => r.keyword).toList()..sort();
  }

  group('isStale', () {
    test('an install with no cards has nothing to re-read', () async {
      // The sync that fills it will write the current version itself.
      expect(await derivations.isStale(), isFalse);
    });

    test('cards stored before the mechanism existed are stale', () async {
      await insertCard(id: 'BT22-062', effect: _collisionEffect);

      expect(await derivations.storedVersion(), 0);
      expect(await derivations.isStale(), isTrue);
    });

    test('cards read by this build are not', () async {
      await insertCard(id: 'BT22-062', effect: _collisionEffect);
      await derivations.rederive();

      expect(await derivations.storedVersion(), CardDataVersions.derived);
      expect(await derivations.isStale(), isFalse);
    });
  });

  group('rederive', () {
    test('drops a keyword the card only explains', () async {
      await insertCard(
        id: 'BT22-062',
        effect: _collisionEffect,
        keywords: encodeList(const ['Collision', 'Blocker']),
      );

      expect(await derivations.rederive(), 1);

      expect(decodeList((await card('BT22-062')).keywords), ['Collision']);
      expect(
        await keywordsOf('BT22-062'),
        ['Collision'],
        reason: 'the normalised rows the filter searches are replaced too',
      );
    });

    test('leaves a card the parsers already agree with alone', () async {
      await insertCard(
        id: 'BT1-001',
        effect: '＜Rush＞',
        keywords: encodeList(const ['Rush']),
        numberSort: buildNumberSort('BT1-001', 0),
      );

      expect(
        await derivations.rederive(),
        0,
        reason: 'nothing to write, so nothing counted',
      );
      expect(await keywordsOf('BT1-001'), ['Rush']);
    });

    test('rebuilds the sort key and the copy limit from stored text', () async {
      await insertCard(
        id: 'BT7-071',
        effect:
            '⟨Rule⟩ You can include up to 50 copies of cards with this '
            "card's card number in your deck.",
        numberSort: 'wrong',
      );

      await derivations.rederive();

      final row = await card('BT7-071');
      expect(row.copyLimit, 50);
      expect(row.ruleCopyLimit, 50);
      expect(row.numberSort, isNot('wrong'));
    });

    test('takes the digivolution conditions in the effect box into '
        'account', () async {
      // Coronamon BT25-008: the cost box says 3, and the effect box prints a
      // cheaper route that only the text knows about.
      await insertCard(
        id: 'BT25-008',
        effect:
            '[Digivolve] Lv.2 w/[TS] trait: Cost 0\n'
            '[On Play] Gain 1 memory.',
        requirements: jsonEncode([
          {'level': 4, 'cost': 3, 'color': 'red'},
        ]),
      );

      await derivations.rederive();

      final row = await card('BT25-008');
      expect(row.digivolveCostMin, 0);
      expect(row.digivolveCostMax, 3);
    });

    test('reads every card, not just the first page', () async {
      // The pass runs in pages of 500; 600 cards proves the second one is
      // read and written as well.
      for (var i = 0; i < 600; i++) {
        await insertCard(
          id: 'BT1-${i.toString().padLeft(3, '0')}',
          effect: _collisionEffect,
          keywords: encodeList(const ['Collision', 'Blocker']),
        );
      }

      expect(await derivations.rederive(), 600);
      expect(await keywordsOf('BT1-599'), ['Collision']);
    });

    test('reports progress over the whole run', () async {
      await insertCard(id: 'BT1-001', effect: '＜Rush＞');
      await insertCard(id: 'BT1-002', effect: '＜Blocker＞');

      final seen = <int>[];
      await derivations.rederive(
        onProgress: (done, total) {
          expect(total, 2);
          seen.add(done);
        },
      );

      expect(seen.last, 2);
    });
  });
}
