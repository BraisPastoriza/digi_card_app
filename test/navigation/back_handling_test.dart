import 'package:digi_card_app/core/router/navigation.dart';
import 'package:digi_card_app/l10n/l10n.dart';
import 'package:digi_card_app/shared/widgets/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// The app's shape: two branches under the real [AppShell], with a detail
/// route pushed inside a branch rather than at the root. That nesting is the
/// whole point — the root navigator holds one page, the shell, however deep
/// the branch the user is looking at happens to be.
GoRouter _buildRouter() => GoRouter(
  initialLocation: '/library',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => AppShell(shell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/library',
              builder: (_, _) => const Scaffold(body: Text('library')),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/decks',
              builder: (_, _) => const Scaffold(body: Text('deck list')),
              routes: [
                GoRoute(
                  path: ':deckId',
                  builder: (_, state) => Scaffold(
                    body: Text('deck ${state.pathParameters['deckId']}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  ],
);

void main() {
  late List<String> platformCalls;

  setUp(() {
    resetPushGuard();
    platformCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          platformCalls.add(call.method);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('back inside a branch goes back rather than leaving the app', (
    tester,
  ) async {
    final router = _buildRouter();
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    router.go('/decks');
    await tester.pumpAndSettle();

    final context = router.routerDelegate.navigatorKey.currentContext!;
    context.pushOnce('/decks/5');
    await tester.pumpAndSettle();

    await router.routerDelegate.popRoute();
    await tester.pumpAndSettle();

    expect(find.text('deck list'), findsOneWidget);
    expect(
      platformCalls,
      isNot(contains('SystemNavigator.pop')),
      reason: 'there was a page to go back to',
    );
  });

  testWidgets('back on the heels of a tap does not leave the app', (
    tester,
  ) async {
    // The reported bug: tap a deck, flick back before it has opened, and the
    // app closes. The push is in the router but the navigator holding it has
    // not been rebuilt, so everything that asks the navigator says there is
    // nothing to go back to — and an unhandled back means "leave the app".
    final router = _buildRouter();
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    router.go('/decks');
    await tester.pumpAndSettle();

    final context = router.routerDelegate.navigatorKey.currentContext!;
    context.pushOnce('/decks/5');
    // No pump: the page is opening, and the back arrives in that gap.
    await router.routerDelegate.popRoute();
    await tester.pumpAndSettle();

    expect(
      platformCalls,
      isNot(contains('SystemNavigator.pop')),
      reason:
          'closing the app is never the right answer to a back press that '
          'landed while a page was opening',
    );
  });

  testWidgets('back at the root of a tab still leaves the app', (tester) async {
    // The other half: at the root there genuinely is nowhere to go, and
    // Android expects back to leave the app.
    final router = _buildRouter();
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    router.go('/decks');
    await tester.pumpAndSettle();
    // Well clear of the window that protects a page still opening.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );

    await router.routerDelegate.popRoute();
    await tester.pumpAndSettle();

    expect(platformCalls, contains('SystemNavigator.pop'));
  });

  testWidgets('a push stops being protected once it has settled', (
    tester,
  ) async {
    final router = _buildRouter();
    await tester.pumpWidget(MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ));
    await tester.pumpAndSettle();

    expect(isPushSettling, isFalse, reason: 'nothing pushed yet');

    router.routerDelegate.navigatorKey.currentContext!.pushOnce('/decks/5');
    expect(isPushSettling, isTrue);

    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );
    expect(
      isPushSettling,
      isFalse,
      reason:
          'a page that has arrived must not keep back presses from '
          'closing the app at the root',
    );
  });
}
