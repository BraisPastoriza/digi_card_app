import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/language.dart';
import 'l10n/l10n.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppSurfaces.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  // Read before the first frame: the alternative is opening in the device's
  // language and correcting it a frame later, which the user sees.
  final prefs = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        storedLanguageProvider.overrideWithValue(storedLanguage(prefs)),
      ],
      child: const DigiCardApp(),
    ),
  );
}

class DigiCardApp extends ConsumerWidget {
  const DigiCardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      onGenerateTitle: (context) => context.l10n.appTitle,
      debugShowCheckedModeBanner: false,
      // Null follows the device language, falling back to English for any
      // locale the app has no translation for. Card text is not translated:
      // the game is played in English here whatever the interface says.
      locale: ref.watch(languageProvider),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.dark(),
      // The app commits to a single dark look rather than following the system
      // theme: card art is designed against dark borders and reads best here.
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      routerConfig: ref.watch(routerProvider),
    );
  }
}
