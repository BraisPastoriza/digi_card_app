import 'package:dio/dio.dart';

import '../../core/app_info.dart';
import '../../domain/models/app_release.dart';

/// Read-only client for this app's own releases on GitHub.
///
/// Unauthenticated, which GitHub allows 60 requests an hour per IP. The app
/// asks at most once a day, so the limit only matters to somebody sharing an
/// IP with a lot of other unauthenticated GitHub traffic — and then the check
/// fails quietly and tries again the next day.
class GitHubApi {
  GitHubApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.github.com',
              connectTimeout: const Duration(seconds: 20),
              // Generous, because the same client downloads the APK.
              receiveTimeout: const Duration(seconds: 120),
              headers: {
                'Accept': 'application/vnd.github+json',
                'X-GitHub-Api-Version': '2022-11-28',
                'User-Agent': AppInfo.userAgent,
              },
            ),
          );

  final Dio _dio;

  /// `owner/name`, taken from [AppInfo.repositoryUrl] so the two cannot
  /// disagree.
  static String get repository =>
      Uri.parse(AppInfo.repositoryUrl).path.replaceFirst('/', '');

  /// The newest published release, or null when the repository has none.
  ///
  /// GitHub's "latest" already leaves out drafts and pre-releases, so a build
  /// shared for testing is never offered to everybody.
  Future<AppRelease?> latestRelease() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/repos/$repository/releases/latest',
      options: Options(
        validateStatus: (status) => status == 200 || status == 404,
      ),
    );
    final data = response.data;
    if (response.statusCode == 404 || data == null) return null;
    return AppRelease.fromJson(data);
  }

  /// Saves [asset] to [path], reporting the bytes received so far.
  Future<void> download(
    ReleaseAsset asset,
    String path, {
    void Function(int received, int total)? onProgress,
  }) => _dio.download(
    asset.downloadUrl,
    path,
    // The client asks the API for JSON; the file is no such thing.
    options: Options(headers: {'Accept': 'application/octet-stream'}),
    onReceiveProgress: (received, total) =>
        // `total` is -1 when the server omits Content-Length; the size GitHub
        // listed for the asset is the same number.
        onProgress?.call(received, total > 0 ? total : asset.size),
  );
}
