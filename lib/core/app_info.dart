import 'package:package_info_plus/package_info_plus.dart';

/// Who the app says it is when it talks to somebody else's server.
///
/// Both card APIs are public, unauthenticated and run as a courtesy to the
/// community, so the least this app can do is be identifiable: a maintainer
/// looking at their access log should be able to tell which client the traffic
/// is, what version of it, and where to find the source — without having to
/// ask around.
abstract final class AppInfo {
  static const name = 'DigiCardApp';

  static const repositoryUrl =
      'https://github.com/BraisPastoriza/digi_card_app';

  /// The installed version, e.g. `1.3.0`, as the build stamped it from
  /// `version` in pubspec.yaml.
  ///
  /// Read once at startup by [load] rather than written here by hand: a
  /// forgotten bump used to be the one way the User-Agent could lie, and the
  /// update check compares against this, so a stale number would offer users
  /// the version they already have.
  static String get version => _version;
  static String _version = '0.0.0';

  /// Reads [version] from the installed package. Called before the first
  /// frame, so nothing that talks to a server runs without it.
  static Future<void> load() async {
    _version = (await PackageInfo.fromPlatform()).version;
  }

  /// `Product/Version (+url)` — the shape crawlers have used for decades, and
  /// the one an operator's log tooling already knows how to read.
  static String get userAgent => '$name/$version (+$repositoryUrl)';
}
