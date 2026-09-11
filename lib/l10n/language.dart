import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_localizations.dart';

/// The language setting: a locale the user picked, or null to follow the
/// device.
///
/// Null is the default and is not the same as picking English — a phone set to
/// Spanish should come up in Spanish without anyone choosing anything, and
/// should follow if that phone is later set to something else.
class LanguageNotifier extends Notifier<Locale?> {
  static const storageKey = 'interface_language';

  @override
  Locale? build() => ref.read(storedLanguageProvider);

  /// Switches the interface, keeping the choice for next launch.
  Future<void> select(Locale? locale) async {
    state = locale;
    final prefs = await SharedPreferences.getInstance();
    if (locale == null) {
      await prefs.remove(storageKey);
    } else {
      await prefs.setString(storageKey, locale.languageCode);
    }
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, Locale?>(
  LanguageNotifier.new,
);

/// The setting as it was on disk when the app started.
///
/// Overridden in `main` from preferences that are read before the first frame,
/// so the app opens in the language the user chose rather than flashing the
/// device's for a frame and then correcting itself.
final storedLanguageProvider = Provider<Locale?>(
  (ref) => throw UnimplementedError('override storedLanguageProvider in main'),
);

/// Reads the stored setting, ignoring a language this build no longer ships.
Locale? storedLanguage(SharedPreferences prefs) {
  final code = prefs.getString(LanguageNotifier.storageKey);
  if (code == null) return null;
  return AppLocalizations.supportedLocales
      .where((l) => l.languageCode == code)
      .firstOrNull;
}

/// What a language calls itself, which is what a language picker has to say:
/// someone looking for Spanish is looking for "Español", whatever language the
/// app happens to be in while they look.
String languageName(Locale locale) => switch (locale.languageCode) {
  'es' => 'Español',
  _ => 'English',
};
