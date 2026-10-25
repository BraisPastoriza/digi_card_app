import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:digi_card_app/data/api/digimoncard_io_api.dart';
import 'package:digi_card_app/data/api/heroi_api.dart';
import 'package:digi_card_app/data/db/app_database.dart';
import 'package:digi_card_app/data/sync/card_sync_service.dart';
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

Map<String, dynamic> _card(
  String number,
  String name, {
  List<Map<String, dynamic>> limitations = const [],
}) => {
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
      'limitations': limitations,
    },
  },
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tmp;
  late AppDatabase db;
  late CardSyncService service;

  /// What the next sync downloads.
  late List<Map<String, dynamic>> dump;
  late String dumpId;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('restriction_changes');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => tmp.path,
        );

    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customStatement('PRAGMA foreign_keys = ON');
    dump = [_card('BT1-010', 'Agumon'), _card('BT1-020', 'Gabumon')];
    dumpId = 'first';

    final primary = Dio(BaseOptions(baseUrl: HeroiApi.baseUrl))
      ..httpClientAdapter = _RoutedAdapter(
        (options) => switch (options.uri.path) {
          '/bulk-data' => {
            'data': [
              {
                'type': 'bulk-data',
                'id': dumpId,
                'attributes': {
                  'name': 'English Cards',
                  'size': 1,
                  'updated-at': dumpId,
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
                'releases': {'data': <Object>[]},
              },
            },
          },
          '/bulk-data/en-1.json' => dump,
          final path => throw StateError('unexpected request: $path'),
        },
      );

    service = CardSyncService(
      db,
      HeroiApi(dio: primary),
      DigimonCardIoApi(
        dio: Dio()..httpClientAdapter = _RoutedAdapter((_) => <Object>[]),
      ),
    );
  });

  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  test('records a card the new list restricts', () async {
    await service.sync().drain<void>();
    expect(await db.select(db.restrictionChanges).get(), isEmpty);

    dump = [
      _card(
        'BT1-010',
        'Agumon',
        limitations: [
          {'date': '2026-11-01', 'type': 'restrict', 'allowance': 1},
        ],
      ),
      _card('BT1-020', 'Gabumon'),
    ];
    dumpId = 'second';
    await service.sync().drain<void>();

    final change = (await db.select(db.restrictionChanges).get()).single;
    expect(change.cardNumber, 'BT1-010');
    expect(change.cardName, 'Agumon');
    expect((change.oldLimit, change.newLimit), (4, 1));
  });

  test('records nothing for the first sync of a fresh install', () async {
    dump = [
      _card(
        'BT1-010',
        'Agumon',
        limitations: [
          {'date': '2026-11-01', 'type': 'ban', 'allowance': 0},
        ],
      ),
    ];

    await service.sync().drain<void>();

    expect(await db.select(db.restrictionChanges).get(), isEmpty);
  });
}
