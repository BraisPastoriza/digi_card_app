import 'package:digi_card_app/domain/models/app_release.dart';
import 'package:flutter_test/flutter_test.dart';

/// Trimmed from GitHub's answer for v1.3.0.
Map<String, dynamic> _release({
  String tag = 'v1.3.0',
  List<String> apks = const [
    'app-arm64-v8a-release.apk',
    'app-armeabi-v7a-release.apk',
    'app-release.apk',
  ],
}) => {
  'tag_name': tag,
  'name': '$tag — Parejas prohibidas y app en español',
  'body': '## Novedades\n\n- Parejas prohibidas',
  'html_url':
      'https://github.com/BraisPastoriza/digi_card_app/releases/tag/$tag',
  'draft': false,
  'prerelease': false,
  'assets': [
    for (final name in apks)
      {
        'name': name,
        'size': 22756389,
        'digest':
            'sha256:319a2989e8975f47bcd4e8a1320eb6d7405d581603752057580412d9b0a7ac97',
        'browser_download_url':
            'https://github.com/BraisPastoriza/digi_card_app/releases/download/$tag/$name',
      },
  ],
};

void main() {
  group('comparing versions', () {
    test('orders by each number, not by the text', () {
      expect(compareVersions('1.10.0', '1.9.2'), greaterThan(0));
      expect(compareVersions('1.3.0', '1.3.1'), lessThan(0));
      expect(compareVersions('2.0.0', '1.99.99'), greaterThan(0));
    });

    test('treats a missing part as zero', () {
      expect(compareVersions('1.3', '1.3.0'), 0);
    });

    test('ignores a suffix after the number', () {
      expect(compareVersions('1.4.0-beta', '1.4.0'), 0);
      expect(compareVersions('1.4.0-beta', '1.3.0'), greaterThan(0));
    });
  });

  group('a release', () {
    test('reads what GitHub says about it', () {
      final release = AppRelease.fromJson(_release());

      expect(release.tag, 'v1.3.0');
      expect(release.version, '1.3.0');
      expect(release.title, 'v1.3.0 — Parejas prohibidas y app en español');
      expect(release.notes, startsWith('## Novedades'));
      expect(release.assets, hasLength(3));
      expect(
        release.assets.first.sha256,
        '319a2989e8975f47bcd4e8a1320eb6d7405d581603752057580412d9b0a7ac97',
      );
    });

    test('is newer only than an older installed version', () {
      final release = AppRelease.fromJson(_release(tag: 'v1.4.0'));

      expect(release.isNewerThan('1.3.0'), isTrue);
      expect(release.isNewerThan('1.4.0'), isFalse);
      expect(release.isNewerThan('1.5.0'), isFalse);
    });

    test('survives being stored and read back', () {
      final release = AppRelease.fromJson(_release());
      final again = AppRelease.fromJson(release.toJson());

      expect(again.tag, release.tag);
      expect(again.title, release.title);
      expect(again.notes, release.notes);
      expect(again.pageUrl, release.pageUrl);
      expect(
        again.assets.map((a) => a.name),
        release.assets.map((a) => a.name),
      );
      expect(again.assets.first.sha256, release.assets.first.sha256);
      expect(again.assets.first.size, release.assets.first.size);
    });

    test('falls back to the tag when it has no title', () {
      expect(AppRelease.fromJson({..._release(), 'name': ''}).title, 'v1.3.0');
    });
  });

  group('the APK for a device', () {
    final release = AppRelease.fromJson(_release());

    test("is the device's own ABI when the release has it", () {
      expect(
        release.apkFor(['arm64-v8a', 'armeabi-v7a', 'armeabi'])?.name,
        'app-arm64-v8a-release.apk',
      );
      expect(
        release.apkFor(['armeabi-v7a', 'armeabi'])?.name,
        'app-armeabi-v7a-release.apk',
      );
    });

    test('is the universal one for an ABI without its own', () {
      expect(
        release.apkFor(['x86_64', 'arm64-v8a'])?.name,
        'app-arm64-v8a-release.apk',
        reason: 'a later ABI the device also runs beats the universal APK',
      );
      expect(release.apkFor(['x86_64'])?.name, 'app-release.apk');
    });

    test('is nothing when the release has no APK that fits', () {
      final noUniversal = AppRelease.fromJson(
        _release(apks: ['app-arm64-v8a-release.apk']),
      );
      expect(noUniversal.apkFor(['x86_64']), isNull);
    });
  });
}
