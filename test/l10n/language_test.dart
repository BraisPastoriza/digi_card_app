import 'package:digi_card_app/l10n/language.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

ProviderContainer _container(Locale? stored) {
  final container = ProviderContainer(
    overrides: [storedLanguageProvider.overrideWithValue(stored)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('storedLanguage', () {
    test('is nothing until the reader picks one', () async {
      SharedPreferences.setMockInitialValues({});

      expect(storedLanguage(await SharedPreferences.getInstance()), isNull);
    });

    test('reads back the language that was chosen', () async {
      SharedPreferences.setMockInitialValues({
        LanguageNotifier.storageKey: 'es',
      });

      expect(
        storedLanguage(await SharedPreferences.getInstance()),
        const Locale('es'),
      );
    });

    test('a language this build no longer ships falls back to the device', () {
      // Rather than opening in a language with no strings behind it.
      SharedPreferences.setMockInitialValues({
        LanguageNotifier.storageKey: 'ja',
      });

      expectLater(
        SharedPreferences.getInstance().then(storedLanguage),
        completion(isNull),
      );
    });
  });

  group('the language setting', () {
    test('starts at whatever was on disk', () {
      expect(
        _container(const Locale('es')).read(languageProvider),
        const Locale('es'),
      );
      expect(_container(null).read(languageProvider), isNull);
    });

    test('a choice applies at once and survives the next launch', () async {
      SharedPreferences.setMockInitialValues({});
      final container = _container(null);

      await container
          .read(languageProvider.notifier)
          .select(const Locale('es'));

      expect(container.read(languageProvider), const Locale('es'));
      expect(
        storedLanguage(await SharedPreferences.getInstance()),
        const Locale('es'),
      );
    });

    test('going back to the device forgets the choice', () async {
      SharedPreferences.setMockInitialValues({
        LanguageNotifier.storageKey: 'es',
      });
      final container = _container(const Locale('es'));

      await container.read(languageProvider.notifier).select(null);

      expect(container.read(languageProvider), isNull);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(LanguageNotifier.storageKey), isFalse);
    });
  });

  test('every language the app offers has a name of its own', () {
    // Shown in that language, so a reader can find theirs whatever the app is
    // currently set to.
    expect(languageName(const Locale('en')), 'English');
    expect(languageName(const Locale('es')), 'Español');
  });
}
