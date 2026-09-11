import 'package:digi_card_app/features/library/widgets/language_sheet.dart';
import 'package:digi_card_app/l10n/l10n.dart';
import 'package:digi_card_app/l10n/language.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// An app with one button, which opens the language sheet.
Future<void> _pump(WidgetTester tester, {Locale? stored}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [storedLanguageProvider.overrideWithValue(stored)],
      child: Consumer(
        builder: (context, ref, _) => MaterialApp(
          locale: ref.watch(languageProvider),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showLanguageSheet(context),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('offers the device and every language the app ships', (
    tester,
  ) async {
    await _pump(tester);

    expect(find.text('Match my device'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('Español'), findsOneWidget);
  });

  testWidgets('picking one switches the app over and closes the sheet', (
    tester,
  ) async {
    await _pump(tester);

    await tester.tap(find.text('Español'));
    await tester.pumpAndSettle();

    expect(find.text('Español'), findsNothing, reason: 'the sheet closed');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(LanguageNotifier.storageKey), 'es');
  });

  testWidgets('the sheet itself is in the language being used', (tester) async {
    await _pump(tester, stored: const Locale('es'));

    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('El del dispositivo'), findsOneWidget);
  });
}
