import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:digi_card_app/data/api/digimoncard_io_api.dart';
import 'package:digi_card_app/data/api/heroi_api.dart';
import 'package:digi_card_app/data/db/app_database.dart';
import 'package:digi_card_app/data/sync/card_sync_service.dart';
import 'package:digi_card_app/domain/models/card_release.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Answers each request with the JSON [routes] gives for it.
class _RoutedAdapter implements HttpClientAdapter {
  _RoutedAdapter(this.routes);

  final Object Function(RequestOptions options) routes;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(routes(options)),
    200,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _card(String number, String name) => {
  'data': {
    'type': 'card',
    'id': '/cards/en/$number',
    'attributes': {
      'number': number,
      'name': name,
      'category': 'digimon',
      'color': ['red'],
      'parallel-id': 0,
      'level': 3,
      'play-cost': 3,
      'dp': 4000,
      'image': 'https://images.heroi.cc/cards/en/$number.webp',
    },
  },
};

Map<String, dynamic> _release(String id, String name, List<String> numbers) => {
  'data': {
    'type': 'release',
    'id': '/releases/en/$id',
    'attributes': {'name': name, 'genre': 'Booster Pack'},
    'relationships': {
      'cards': {
        'data': [
          for (final number in numbers)
            {'type': 'card', 'id': '/cards/en/$number'},
        ],
      },
    },
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmp;
  late AppDatabase db;
  late CardSyncService service;

  // BT-26 is on the preview list, but the primary API now publishes it. EX-13
  // is on the list too and still is not published, so it stays a preview.
  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('preview_retirement');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => tmp.path,
        );

    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');

    final primary = Dio(BaseOptions(baseUrl: HeroiApi.baseUrl))
      ..httpClientAdapter = _RoutedAdapter(
        (options) => switch (options.uri.path) {
          '/bulk-data' => {
            'data': [
              {
                'type': 'bulk-data',
                'id': 'dump',
                'attributes': {
                  'name': 'English Cards',
                  'size': 1,
                  'updated-at': '2026-10-16',
                },
                'links': {
                  'download': 'https://assets.heroi.cc/bulk-data/en-1.json',
                },
              },
            ],
          },
          '/releases/en' => {
            'data': {
              'relationships': {
                'releases': {
                  'data': [
                    {'type': 'release', 'id': '/releases/en/bt-25'},
                    {'type': 'release', 'id': '/releases/en/bt-26'},
                  ],
                },
              },
            },
          },
          '/releases/en/bt-25' => _release('bt-25', 'DUAL REVOLUTION [BT-25]', [
            'BT25-001',
          ]),
          '/releases/en/bt-26' => _release('bt-26', 'TIMELESS BONDS [BT-26]', [
            'BT26-001',
          ]),
          '/bulk-data/en-1.json' => [
            _card('BT25-001', 'Agumon'),
            _card('BT26-001', 'Gabumon'),
          ],
          final path => throw StateError('unexpected request: $path'),
        },
      );

    final secondary = Dio()
      ..httpClientAdapter = _RoutedAdapter(
        (options) => options.uri.queryParameters['pack'] == 'EX-13'
            ? [
                {
                  'id': 'EX13-001',
                  'name': 'Gigimon',
                  'type': 'Digi-Egg',
                  'color': 'Red',
                  'level': '2',
                },
              ]
            : <Object>[],
      );

    service = CardSyncService(
      db,
      HeroiApi(dio: primary),
      DigimonCardIoApi(dio: secondary),
    );
  });

  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  Future<Map<String, Map<String, Object?>>> releases() async => {
    for (final row
        in await db
            .customSelect('SELECT id, data_source, sort_index FROM releases')
            .get())
      row.read<String>('id'): row.data,
  };

  test(
    'a preview set the primary API publishes stops being a preview',
    () async {
      expect(previewReleases.map((p) => p.id), containsAll(['bt-26', 'ex-13']));

      await service.sync(force: true).drain<void>();
      final stored = await releases();

      expect(stored['bt-26']?['data_source'], isNull);
      // It takes its place in the API's ordering instead of sorting past it.
      expect(stored['bt-26']?['sort_index'], 1);
    },
  );

  test('a preview set the primary API lacks is still a preview', () async {
    await service.sync(force: true).drain<void>();
    final stored = await releases();

    expect(stored['ex-13']?['data_source'], secondarySourceName);
  });
}
