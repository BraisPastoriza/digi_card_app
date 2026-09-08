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
            ),
          ],
        ),
      ],
    ),
  ],
);

void main() {
  setUp(resetPushGuard);

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
