import 'dart:io';

import 'package:digi_card_app/core/app_info.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the version sent to the card APIs is the version being shipped', () {
    // The User-Agent is the only thing an API operator has to go on when one
    // release of this app starts behaving badly, so a stale number there is
    // worse than none. This is the check that catches a forgotten bump.
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final declared = RegExp(
      r'^version:\s*([\d.]+)',
      multiLine: true,
    ).firstMatch(pubspec)?.group(1);

    expect(declared, isNotNull, reason: 'pubspec.yaml has no version');
    expect(AppInfo.version, declared);
  });

  test('identifies the app, its version and where to find the source', () {
    expect(
      AppInfo.userAgent,
      'DigiCardApp/${AppInfo.version} (+${AppInfo.repositoryUrl})',
    );
    expect(AppInfo.repositoryUrl, startsWith('https://'));
  });
}
