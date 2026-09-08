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
/// Two guards, both measured against what this app itself last pushed:
///
///  * the same location again within [_duplicateWindow] is the double tap on
///    one tile, however slowly the second tap arrives; and
///  * any location within [_settleWindow] is the tap that lands on a second
///    tile while the first page is still animating in — that tile is under the
///    user's finger by accident, not by choice.
///
/// What it deliberately does *not* consult is the router's current location.
/// It did once, dropping any push to the page the router said was on top, and
/// that reads well until the router's idea of the top and what is on screen
/// come apart — which they do when the app is sent to the background mid-push.
/// The tile the user was last on then becomes permanently dead: every tap on
/// it is dropped, every other tile still works, and nothing about that is
/// discoverable from the outside. A guard against a stray tap has no business
/// outliving the stray tap.
extension AppForwardNavigation on BuildContext {
  /// Long enough to swallow a stray second tap, short enough that nobody
  /// deliberately navigating twice in a row notices it. A page transition is
  /// 300 ms, so this ends before the first screen has finished arriving.
  static const _settleWindow = Duration(milliseconds: 400);

  /// How long the *same* tile stays guarded. Longer than [_settleWindow]
  /// because a second tap on a tile that has not visibly opened yet is still
  /// impatience rather than intent, and a slow phone stretches that out.
  static const _duplicateWindow = Duration(seconds: 2);

  void pushOnce(String location) {
    final now = DateTime.now();
    final last = _lastPush;
    if (last != null) {
      final since = now.difference(last.at);
      if (since < _settleWindow) return;
      if (since < _duplicateWindow && last.location == location) return;
    }
    _lastPush = (location: location, at: now);

    GoRouter.of(this).push(location);
  }
}

/// The last push this app made, shared across widgets rather than kept
/// per-widget: the taps to guard against land on different tiles, and often on
/// ones being disposed as the first page arrives.
({String location, DateTime at})? _lastPush;

/// Whether a page was pushed too recently for the navigator holding it to have
/// been rebuilt yet.
///
/// In that window the router knows about the new page and the navigator does
/// not, so anything that asks the navigator — `canPop`, `maybePop` — answers
/// as though the page were not there. The shell's back handling checks this
/// before deciding that a back press means "leave the app": a back that lands
/// on the heels of a tap is impatience, not an instruction to close the app,
/// and answering it by closing the app is how a user ends up back at their
/// home screen having lost the deck they were reading.
bool get isPushSettling {
  final last = _lastPush;
  if (last == null) return false;
  return DateTime.now().difference(last.at) <
      AppForwardNavigation._settleWindow;
}

/// Clears the guard so one test's taps cannot suppress the next one's.
@visibleForTesting
void resetPushGuard() => _lastPush = null;
