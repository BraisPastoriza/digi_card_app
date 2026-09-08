/// Who the app says it is when it talks to somebody else's server.
///
/// Both card APIs are public, unauthenticated and run as a courtesy to the
/// community, so the least this app can do is be identifiable: a maintainer
/// looking at their access log should be able to tell which client the traffic
/// is, what version of it, and where to find the source — without having to
/// ask around.
abstract final class AppInfo {
  static const name = 'DigiCardApp';

  /// Kept in step with `version` in pubspec.yaml by hand. It is one line in
  /// the release checklist, and it buys a server operator the ability to say
  /// "the 1.1.0 client is the one hammering me".
  static const version = '1.1.0';

  static const repositoryUrl =
      'https://github.com/BraisPastoriza/digi_card_app';

  /// `Product/Version (+url)` — the shape crawlers have used for decades, and
  /// the one an operator's log tooling already knows how to read.
  static const userAgent = '$name/$version (+$repositoryUrl)';
}
