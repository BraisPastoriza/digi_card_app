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
