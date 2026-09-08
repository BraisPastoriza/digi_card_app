import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:digi_card_app/data/api/digimoncard_io_api.dart';
import 'package:digi_card_app/data/api/heroi_api.dart';
import 'package:digi_card_app/data/db/app_database.dart';
import 'package:digi_card_app/data/db/tables.dart';
import 'package:digi_card_app/data/sync/card_sync_service.dart';
import 'package:digi_card_app/domain/models/card_release.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers every request with one canned payload, so a refresh can be run
/// against a known set listing without touching the network.
class _CannedAdapter implements HttpClientAdapter {
  _CannedAdapter(this.rows);

  List<Map<String, dynamic>> rows;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(rows),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _row(String id, String name, {String? effect}) => {
  'id': id,
  'name': name,
  'type': 'Digimon',
  'color': 'Red',
  'level': '4',
  'play_cost': '4',
  'dp': '5000',
  'main_effect': effect,
};

void main() {
  late AppDatabase db;
  late _CannedAdapter adapter;
  late CardSyncService service;

  const preview = PreviewRelease(
    id: 'ex-13',
    name: 'CHIVALROUS XIII [EX-13]',
    pack: 'EX-13',
  );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');

    adapter = _CannedAdapter([]);
    final dio = Dio()..httpClientAdapter = adapter;
    service = CardSyncService(
      db,
      HeroiApi(dio: Dio()),
      DigimonCardIoApi(dio: dio),
    );

    // A published set with a card in it, and the preview set holding one card
    // of its own — the state the app is in between full syncs.
    await db.batch((batch) {
      batch.insertAll(db.releases, [
        ReleasesCompanion.insert(
          id: 'bt-25',
          name: 'DUAL REVOLUTION [BT-25]',
          groupName: 'booster',
          cardCount: const Value(1),
        ),
        ReleasesCompanion.insert(
          id: preview.id,
          name: preview.name,
          groupName: 'ex',
          cardCount: const Value(1),
          dataSource: const Value(secondarySourceName),
        ),
      ]);
      batch.insertAll(db.cards, [
        CardsCompanion.insert(
          id: 'BT25-008',
          number: 'BT25-008',
          name: 'Coronamon',
          category: 'digimon',
          imageUrl: 'https://example.test/BT25-008.webp',
          releaseIds: Value(encodeList(const ['bt-25'])),
        ),
        CardsCompanion.insert(
          id: 'EX13-001',
          number: 'EX13-001',
          name: 'Old Name',
          category: 'digimon',
          imageUrl: 'https://example.test/EX13-001.jpg',
          releaseIds: Value(encodeList(const ['ex-13'])),
        ),
      ]);
      batch.insertAll(db.cardReleaseLinks, [
        CardReleaseLinksCompanion.insert(
          cardId: 'BT25-008',
          releaseId: 'bt-25',
        ),
        CardReleaseLinksCompanion.insert(
          cardId: 'EX13-001',
          releaseId: preview.id,
        ),
      ]);
    });
  });

  tearDown(() => db.close());

  Future<Set<String>> cardIdsIn(String releaseId) async {
    final links = await (db.select(
      db.cardReleaseLinks,
    )..where((l) => l.releaseId.equals(releaseId))).get();
    return links.map((l) => l.cardId).toSet();
  }

  test('picks up cards revealed since the last refresh', () async {
    adapter.rows = [
      _row('EX13-001', 'Old Name'),
      _row('EX13-002', 'Newly Revealed'),
    ];

    expect(await service.refreshPreviews(), ['ex-13']);
    expect(await cardIdsIn('ex-13'), {'EX13-001', 'EX13-002'});

    final release = await db.releaseDao.releaseById('ex-13');
    expect(release!.cardCount, 2);
  });

  test('picks up a correction to a card it already had', () async {
    adapter.rows = [
      _row('EX13-001', 'Corrected Name', effect: '[On Play] Draw 1.'),
    ];

    expect(await service.refreshPreviews(), ['ex-13']);

    final card = await db.cardDao.cardById('EX13-001');
    expect(card!.name, 'Corrected Name');
    expect(card.effect, '[On Play] Draw 1.');
  });

  test('reports no change when the set is the same as last time', () async {
    adapter.rows = [_row('EX13-001', 'Old Name')];

    expect(await service.refreshPreviews(), isEmpty);
    expect(await cardIdsIn('ex-13'), {'EX13-001'});
  });

  test('drops a card the source has withdrawn', () async {
    adapter.rows = [_row('EX13-002', 'Replacement')];

    expect(await service.refreshPreviews(), ['ex-13']);
    expect(await cardIdsIn('ex-13'), {'EX13-002'});
    expect(await db.cardDao.cardById('EX13-001'), isNull);
  });

  test('links a reprint rather than overwriting the real card', () async {
    // A Limited pack lists cards the primary source owns. Refreshing it must
    // link that printing, not replace it with the secondary source's thinner
    // copy — and must never delete it.
    adapter.rows = [
      _row('BT25-008', 'Coronamon'),
      _row('EX13-001', 'Old Name'),
    ];

    await service.refreshPreviews();

    expect(await cardIdsIn('ex-13'), {'BT25-008', 'EX13-001'});
    final reprint = await db.cardDao.cardById('BT25-008');
    expect(reprint, isNotNull);
    expect(
      reprint!.imageUrl,
      'https://example.test/BT25-008.webp',
      reason: 'the real printing keeps its own artwork',
    );
    expect(await cardIdsIn('bt-25'), {'BT25-008'});
  });

  test('leaves a set alone once the primary source publishes it', () async {
    await (db.update(db.releases)..where((r) => r.id.equals('ex-13'))).write(
      const ReleasesCompanion(dataSource: Value(null)),
    );
    adapter.rows = [_row('EX13-002', 'Should not be stored')];

    expect(await service.refreshPreviews(), isEmpty);
    expect(await cardIdsIn('ex-13'), {'EX13-001'});
  });

  test('keeps what it has when the source answers with nothing', () async {
    adapter.rows = [];

    expect(await service.refreshPreviews(), isEmpty);
    expect(await cardIdsIn('ex-13'), {'EX13-001'});
  });

  test('refreshes only the set asked for', () async {
    adapter.rows = [_row('EX13-002', 'Newly Revealed')];

    expect(await service.refreshPreviews(onlyReleaseId: 'bt-26'), isEmpty);
    expect(await cardIdsIn('ex-13'), {'EX13-001'});
  });

  test('keeps the search index in step with the cards', () async {
    await db.rebuildSearchIndex();
    adapter.rows = [_row('EX13-002', 'Newly Revealed')];

    await service.refreshPreviews();

    final indexed = await db
        .customSelect('SELECT card_id FROM $cardSearchTable')
        .get();
    expect(
      indexed.map((row) => row.read<String>('card_id')),
      contains('EX13-002'),
    );
    expect(
      indexed.map((row) => row.read<String>('card_id')),
      isNot(contains('EX13-001')),
    );
  });
}
