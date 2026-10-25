import 'package:digi_card_app/core/app_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  test('the version sent to the card APIs is the one installed', () async {
    // The User-Agent is the only thing an API operator has to go on when one
    // release of this app starts behaving badly, so it has to be the version
    // the build was stamped with, not a number somebody kept in step by hand.
    PackageInfo.setMockInitialValues(
      appName: 'DigiCard App',
      packageName: 'io.github.braispastoriza.digicard',
      version: '9.8.7',
      buildNumber: '42',
      buildSignature: '',
    );

    await AppInfo.load();

    expect(AppInfo.version, '9.8.7');
  });

  test('identifies the app, its version and where to find the source', () {
    expect(
      AppInfo.userAgent,
      'DigiCardApp/${AppInfo.version} (+${AppInfo.repositoryUrl})',
    );
    expect(AppInfo.repositoryUrl, startsWith('https://'));
  });
}
