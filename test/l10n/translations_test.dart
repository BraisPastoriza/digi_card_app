import 'dart:convert';
import 'dart:io';

import 'package:digi_card_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _arb(String locale) =>
    jsonDecode(File('lib/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

Set<String> _keys(Map<String, dynamic> arb) =>
    arb.keys.where((key) => !key.startsWith('@')).toSet();

void main() {
  test('every string the app asks for exists in both languages', () {
    // A missing Spanish key does not fail the build — gen_l10n quietly falls
    // back to English — so it has to fail here instead.
    expect(_keys(_arb('es')), _keys(_arb('en')));
  });

  test('a placeholder left out of a translation would break the line', () {
    final en = _arb('en');
    final es = _arb('es');
    // Only the named values, not the text inside a plural's branches.
    final placeholder = RegExp(r'\{(\w+)\s*[,}]');

    for (final key in _keys(en)) {
      expect(
        placeholder
            .allMatches(es[key] as String)
            .map((m) => m.group(1))
            .toSet(),
        placeholder
            .allMatches(en[key] as String)
            .map((m) => m.group(1))
            .toSet(),
        reason: '$key does not name the same values in both languages',
      );
    }
  });

  testWidgets('the app answers in the language the device is set to', (
    tester,
  ) async {
    final en = await AppLocalizations.delegate.load(const Locale('en'));
    final es = await AppLocalizations.delegate.load(const Locale('es'));

    expect(en.navDecks, 'Decks');
    expect(es.navDecks, 'Mazos');

    // Card text is not translated: what the card says is what it says.
    expect(es.categoryDigimon, en.categoryDigimon);
    expect(es.facetToken, en.facetToken);
  });

  testWidgets('a language with no translation falls back to English', (
    tester,
  ) async {
    late AppLocalizations resolved;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            resolved = AppLocalizations.of(context);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(resolved.navDecks, 'Decks');
  });
}
