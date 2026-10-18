import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:digi_card_app/core/providers.dart';
import 'package:digi_card_app/data/api/digimoncard_io_api.dart';
import 'package:digi_card_app/data/api/heroi_api.dart';
import 'package:digi_card_app/data/db/app_database.dart';
import 'package:digi_card_app/data/sync/card_sync_service.dart';
import 'package:digi_card_app/features/sync/sync_screen.dart';
import 'package:digi_card_app/l10n/l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Records what was asked for and answers every request with a server error,
/// which is as far as these tests need a sync to get.
class _RecordingAdapter implements HttpClientAdapter {
  final paths = <String>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    paths.add(options.uri.path);
    return ResponseBody.fromString('', 500);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  testWidgets(
    'checking for updates asks the card API, even with cards stored',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);
      await db
          .into(db.cards)
          .insert(
            CardsCompanion.insert(
              id: 'BT1-001',
              number: 'BT1-001',
              name: 'Yokomon',
              category: 'digi-egg',
              imageUrl: 'https://example.test/BT1-001.webp',
            ),
          );

      final primary = _RecordingAdapter();
      final service = CardSyncService(
        db,
        HeroiApi(dio: Dio()..httpClientAdapter = primary),
        DigimonCardIoApi(dio: Dio()..httpClientAdapter = _RecordingAdapter()),
      );

      final container = ProviderContainer(
        overrides: [cardSyncServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);
      // What "Check for updates" does before the sync screen opens.
      container.read(resyncRequestedProvider.notifier).state = true;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const SyncScreen(),
          ),
        ),
      );
      // A few frames for the check to get past the stored cards and out to the
      // API; pumpAndSettle would wait on the progress spinner forever.
      for (var i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      expect(primary.paths, contains('/bulk-data'));
      expect(container.read(resyncRequestedProvider), isFalse);
    },
  );
}
