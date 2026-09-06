import 'package:dio/dio.dart';

/// Read-only client for the digimoncard.io public API.
///
/// This is the app's *secondary* card source. It exists for one job: the two
/// sets the primary API has not published yet (see `previewReleases`). Every
/// other card in the app comes from the primary source.
///
/// Their documented rate limit is 15 requests per 10 seconds per IP, with a
/// block of up to an hour for repeat offenders. A sync makes one request per
/// preview set — two — and makes them one at a time, so the limit is never
/// anywhere near in play.
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
  /// eventually require it.
  static const userAgent = 'DigiCardApp/1.0';

  final Dio _dio;

  static bool _isReadable(int? status) =>
      status != null && status >= 200 && status < 500;

  /// Every card row the API lists for a pack, e.g. `BT-26`.
  ///
  /// Returns an empty list when the pack is unknown or the API answers with
  /// its error object: a preview set that has not been revealed yet is an
  /// expected outcome, not an error.
  Future<List<Map<String, dynamic>>> cardsInPack(String pack) async {
    final response = await _dio.get<dynamic>(
      '/search',
      queryParameters: {'pack': pack, 'series': 'Digimon Card Game'},
    );
    final data = response.data;
    if (data is! List) return const [];
    return data.whereType<Map<String, dynamic>>().toList();
  }
}
