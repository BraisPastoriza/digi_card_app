import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Back navigation for the app's own back buttons.
///
/// Every forward move in this app is a `push`, so going back is a `pop` — the
/// same thing the Android gesture and the system back button do. Sending a
/// back button to `go` instead made those three disagree: `go` rebuilds the
/// whole route stack rather than popping one page off it, and one issued while
/// a route was still animating was dropped, which is what left a back button
/// looking dead while the phone's own gesture still worked.
///
/// [fallback] covers the case where there is nothing to pop: the screen was
/// the first of its branch, or the one it came from has been deleted.
extension AppBackNavigation on BuildContext {
  void goBack(String fallback) {
    if (canPop()) {
      pop();
    } else {
      go(fallback);
    }
  }
}

/// Forward navigation for the app's own taps.
///
/// This exists because of a bug that made the app look frozen. Every tile in
/// the app pushed with a bare `context.push`, and a push does not care whether
/// the page it is opening is the one already on screen — so a card tapped
/// twice was pushed twice. The two pages are identical, so the second one is
/// invisible; the only sign of it is that going back appears to do nothing,
/// because it uncovers a copy of the same screen. Tap four times and four back
/// presses do nothing, at which point the app has stopped responding as far as
/// anyone using it is concerned.
///
/// It reproduced whenever a tap landed twice, which is exactly what people do
/// when a screen is slow to open — so it happened under load, on cold caches,
/// on slower phones, and never when anyone went looking for it.
///
/// Two guards, because the taps arrive in two different ways:
///
///  * a push to the location already on top is dropped, which covers the
///    double tap on one tile; and
///  * a push within [_settleWindow] of the last one is dropped, which covers
///    the taps that land on two different tiles while the first page is still
///    animating in — the second tile is under the user's finger by accident,
///    not by choice.
extension AppForwardNavigation on BuildContext {
  /// Long enough to swallow a stray second tap, short enough that nobody
  /// deliberately navigating twice in a row notices it. A page transition is
  /// 300 ms, so this ends before the first screen has finished arriving.
  static const _settleWindow = Duration(milliseconds: 400);

  void pushOnce(String location) {
    final router = GoRouter.of(this);
    if (router.state.uri.toString() == location) return;

    final now = DateTime.now();
    final last = _lastPush;
    if (last != null && now.difference(last) < _settleWindow) return;
    _lastPush = now;

    router.push(location);
  }
}

/// Shared across the app rather than per-widget: the taps to guard against
/// land on different widgets, and often on ones being disposed as the first
/// page arrives.
DateTime? _lastPush;

/// Clears the guard so one test's taps cannot suppress the next one's.
@visibleForTesting
void resetPushGuard() => _lastPush = null;
