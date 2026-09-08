import 'package:digi_card_app/core/router/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// A router shaped like the app's: two tab branches under a shell, with card
/// detail as a top-level route pushed over it.
GoRouter _buildRouter() => GoRouter(
  initialLocation: '/library',
  routes: [
    GoRoute(
      path: '/card/:number',
      builder: (_, state) =>
          Scaffold(body: Text('card ${state.pathParameters['number']}')),
    ),
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => Scaffold(body: shell),
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
              builder: (_, _) => const Scaffold(body: Text('decks')),
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
  setUp(resetPushGuard);

  testWidgets('back during a page transition goes back, it does not close the '
      'app', (tester) async {
    // The bug a user reported: tap a deck, then flick back before the page has
    // finished opening. The push is already in the router's configuration but
    // the navigator has not rebuilt with it, so its `maybePop` finds nothing to
    // pop — and Android takes an unhandled back as "leave the app".
    final router = _buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    // A deck lives inside the Decks branch, not at the root: that is the
    // navigator the back has to reach.
    router.go('/decks');
    await tester.pumpAndSettle();

    final context = router.routerDelegate.navigatorKey.currentContext!;
    context.pushOnce('/decks/5');
    // One frame, deliberately: the route is on its way in, not settled.
    await tester.pump();

    final handled = await router.routerDelegate.popRoute();

    expect(
      handled,
      isTrue,
      reason:
          'an unhandled back is what closes the app out from under the '
          'user, and the router had a page to pop',
    );
    await tester.pumpAndSettle();
    expect(find.text('decks'), findsOneWidget);
  });

  testWidgets('a bare push stacks the same page twice, and back looks dead', (
    tester,
  ) async {
    // The defect this guard exists for. Kept as a test so that if anyone
    // reintroduces a plain `context.push` on a tile, the reason is on record.
    final router = _buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    final context = router.routerDelegate.navigatorKey.currentContext!;
    context.push('/card/BT1-001');
    context.push('/card/BT1-001');
    await tester.pumpAndSettle();

    router.pop();
    await tester.pumpAndSettle();
    expect(
      router.state.uri.toString(),
      '/card/BT1-001',
      reason: 'going back off the duplicate lands on a copy of the same card',
    );
  });

  testWidgets('pushOnce ignores a second tap on the page already open', (
    tester,
  ) async {
    final router = _buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    final context = router.routerDelegate.navigatorKey.currentContext!;
    context.pushOnce('/card/BT1-001');
    context.pushOnce('/card/BT1-001');
    await tester.pumpAndSettle();

    router.pop();
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), '/library');
    expect(find.text('library'), findsOneWidget);
  });

  testWidgets(
    'pushOnce ignores a stray tap on a different tile mid-transition',
    (tester) async {
      final router = _buildRouter();
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      final context = router.routerDelegate.navigatorKey.currentContext!;
      context.pushOnce('/card/BT1-001');
      context.pushOnce('/card/BT1-002');
      await tester.pumpAndSettle();

      expect(router.state.uri.toString(), '/card/BT1-001');
      router.pop();
      await tester.pumpAndSettle();
      expect(router.state.uri.toString(), '/library');
    },
  );

  testWidgets('a page can be opened again after being left', (tester) async {
    // The failure a user hit: the deck they had been reading would not open
    // again, while every other deck did. The guard has to expire, not latch.
    final router = _buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    final context = router.routerDelegate.navigatorKey.currentContext!;
    context.pushOnce('/card/BT1-001');
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();

    // Real time, because the guard is on the wall clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 2100)),
    );
    context.pushOnce('/card/BT1-001');
    await tester.pumpAndSettle();

    expect(find.text('card BT1-001'), findsOneWidget);
  });

  testWidgets('the guard does not depend on where the router thinks it is', (
    tester,
  ) async {
    // The router's location and what is on screen can come apart — a push
    // interrupted by the app going to the background leaves the location
    // pointing at a page that never arrived. A guard that read the location
    // would drop every later tap on that tile, for good.
    final router = _buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    final context = router.routerDelegate.navigatorKey.currentContext!;
    context.pushOnce('/card/BT1-001');
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), '/card/BT1-001');

    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 2100)),
    );
    // Asking for the page the router is already showing: it opens a second
    // copy rather than being swallowed, and back closes it again.
    context.pushOnce('/card/BT1-001');
    await tester.pumpAndSettle();
    router.pop();
    await tester.pumpAndSettle();

    expect(find.text('card BT1-001'), findsOneWidget);
  });

  testWidgets('pushOnce still navigates once the first page has settled', (
    tester,
  ) async {
    final router = _buildRouter();
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    final context = router.routerDelegate.navigatorKey.currentContext!;
    context.pushOnce('/card/BT1-001');
    await tester.pumpAndSettle();
    // Real time, not pumped time: the guard is deliberately on the wall clock,
    // because what it is measuring is how fast a thumb moves.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 500)),
    );

    context.pushOnce('/card/BT1-002');
    await tester.pumpAndSettle();

    expect(router.state.uri.toString(), '/card/BT1-002');
    router.pop();
    await tester.pumpAndSettle();
    expect(router.state.uri.toString(), '/card/BT1-001');
  });
}
