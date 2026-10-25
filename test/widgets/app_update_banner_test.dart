import 'package:digi_card_app/domain/models/app_release.dart';
import 'package:digi_card_app/features/update/app_update_banner.dart';
import 'package:digi_card_app/features/update/app_update_providers.dart';
import 'package:digi_card_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _release = AppRelease(
  tag: 'v1.4.0',
  title: 'v1.4.0 — Something new',
  notes:
      '## Installation\n\nGet **`app-release.apk`** from [GitHub](x).\n\n'
      '- **Banlist** screen',
  pageUrl:
      'https://github.com/BraisPastoriza/digi_card_app/releases/tag/v1.4.0',
  assets: [],
);

/// Holds a release on offer without asking anybody for it.
class _Offering extends AppUpdateNotifier {
  @override
  AppUpdateState build() => const AppUpdateState(release: _release);
}

Future<void> _pump(WidgetTester tester, Widget child) => tester.pumpWidget(
  ProviderScope(
    overrides: [appUpdateProvider.overrideWith(_Offering.new)],
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  ),
);

String _allText(WidgetTester tester) => tester
    .widgetList<RichText>(find.byType(RichText))
    .map((text) => text.text.toPlainText())
    .join('\n');

void main() {
  testWidgets('release notes read without their Markdown', (tester) async {
    await _pump(tester, ReleaseNotes(_release.notes));

    final text = _allText(tester);
    expect(text, contains('Installation'));
    expect(text, contains('Get app-release.apk from GitHub.'));
    expect(text, contains('Banlist screen'));
    expect(text, isNot(contains('**')));
    expect(text, isNot(contains('##')));
    expect(text, isNot(contains('](')));
  });

  testWidgets(
    'offers to install on Android',
    (tester) async {
      await _pump(tester, const AppUpdateBanner());

      expect(find.text('DigiCard App 1.4.0 is available'), findsOneWidget);
      expect(find.text('Install'), findsOneWidget);
      expect(find.text(_release.pageUrl), findsNothing);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.android),
  );

  testWidgets(
    'says where to get it everywhere else',
    (tester) async {
      await _pump(tester, const AppUpdateBanner());

      expect(find.text('Install'), findsNothing);
      expect(find.text(_release.pageUrl), findsOneWidget);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.windows),
  );
}
