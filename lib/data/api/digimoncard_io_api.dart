import 'package:dio/dio.dart';

import '../../core/app_info.dart';

/// Read-only client for the digimoncard.io public API.
///
/// This is the app's *secondary* card source. It exists for one job: the two
/// sets the primary API has not published yet (see `previewReleases`). Every
/// other card in the app comes from the primary source.
///
/// Their documented rate limit is 15 requests per 10 seconds per IP, with a
/// block of up to an hour for repeat offenders. A sync makes one request per
/// preview set, one at a time, so the limit is never anywhere near in play —
/// and a refresh of the preview sets, which the user can now ask for by
/// pulling down on a set, makes exactly one. [_backoff] is there anyway: if
/// this app ever does manage to annoy them, it should be by accident and
/// briefly, not by retrying into a block.
class DigimonCardIoApi {
  DigimonCardIoApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 40),
              headers: const {'User-Agent': userAgent},
              // A pack with no cards answers 400 with an `error` object rather
              // than an empty list, and that is a normal answer here, not a
              // failure worth throwing over.
              validateStatus: _isReadable,
            ),
          );

  static const baseUrl = 'https://digimoncard.io/api-public';

  /// Both APIs ask callers to identify themselves; the primary one says it may
  /// eventually require it. The header names the app, its version and its
  /// repository, so an operator can see what this traffic is. See [AppInfo].
  static const userAgent = AppInfo.userAgent;

  final Dio _dio;

  static bool _isReadable(int? status) =>
      status != null && status >= 200 && status < 500;

  /// How long to wait after being told to slow down, per attempt.
  ///
  /// Their window is 10 seconds, so one wait clears an accidental burst; the
  /// second is there for the case where somebody else on the same IP is the
  /// one being throttled. After that the caller gets an empty list and the
  /// preview set simply keeps the data it already had.
  static const _backoff = [Duration(seconds: 4), Duration(seconds: 11)];

  /// Every card row the API lists for a pack, e.g. `BT-26`.
  ///
  /// Returns an empty list when the pack is unknown or the API answers with
  /// its error object: a preview set that has not been revealed yet is an
  /// expected outcome, not an error.
  /// Backs off and retries when the API says it is being called too often,
  /// rather than treating a 429 as "this pack is empty" and moving on.
  Future<List<Map<String, dynamic>>> cardsInPack(String pack) async {
    for (var attempt = 0; ; attempt++) {
      final response = await _dio.get<dynamic>(
        '/search',
        queryParameters: {'pack': pack, 'series': 'Digimon Card Game'},
      );
      if (response.statusCode == 429 && attempt < _backoff.length) {
        await Future<void>.delayed(_backoff[attempt]);
        continue;
      }
      final data = response.data;
      if (data is! List) return const [];
      return data.whereType<Map<String, dynamic>>().toList();
    }
  }
}
