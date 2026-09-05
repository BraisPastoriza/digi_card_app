import 'package:dio/dio.dart';

/// One of the pre-built card dumps offered by `/bulk-data`.
class BulkDataFile {
  const BulkDataFile({
    required this.id,
    required this.name,
    required this.downloadUrl,
    required this.updatedAt,
    required this.sizeInBytes,
  });

  final String id;
  final String name;
  final String downloadUrl;

  /// Date the dump was generated, used to decide whether a re-sync is needed.
  final String updatedAt;

  final int sizeInBytes;
}

/// A release as returned by `/releases/:language/:id`, together with the cards
/// it contains.
class ReleaseDetail {
  const ReleaseDetail({
    required this.id,
    required this.name,
    required this.cardIds,
    this.genre,
    this.date,
    this.imageUrl,
    this.thumbnailUrl,
    this.productUri,
    this.cardlistUri,
  });

  final String id;
  final String name;

  /// Card ids in the release, e.g. `ST1-07`, in printed order.
  final List<String> cardIds;

  final String? genre;
  final String? date;
  final String? imageUrl;
  final String? thumbnailUrl;
  final String? productUri;
  final String? cardlistUri;
}

/// Read-only client for the Heroicc Digimon Card Game API.
///
/// The API is public and unauthenticated, but asks callers to identify
/// themselves with a User-Agent, so every request carries one.
class HeroiApi {
  HeroiApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 60),
              headers: const {
                'Accept': 'application/vnd.api+json',
                'User-Agent': userAgent,
              },
            ),
          );

  static const baseUrl = 'https://api.heroi.cc';
  static const userAgent = 'DigiCardApp/1.0';

  /// The app ships English cards only; the API also serves ja, ko and zh-Hans.
  static const language = 'en';

  final Dio _dio;

  /// The English card dump, or null if the API stops publishing one.
  Future<BulkDataFile?> latestEnglishBulk() async {
    final response = await _dio.get<Map<String, dynamic>>('/bulk-data');
    final entries = (response.data?['data'] as List?) ?? const [];
    for (final raw in entries) {
      final entry = raw as Map<String, dynamic>;
      final attributes = entry['attributes'] as Map<String, dynamic>? ?? {};
      final download = (entry['links'] as Map<String, dynamic>?)?['download'];
      if (download is! String) continue;
      // The English dump is the only one whose file name is the bare language
      // code; matching on that is steadier than matching the display name.
      if (!download.contains('/$language-')) continue;
      return BulkDataFile(
        id: entry['id'] as String? ?? '',
        name: attributes['name'] as String? ?? 'English Cards',
        downloadUrl: download,
        updatedAt: attributes['updated-at'] as String? ?? '',
        sizeInBytes: attributes['size'] as int? ?? 0,
      );
    }
    return null;
  }

  /// Release ids for the language, oldest first, as ordered by the API.
  Future<List<String>> releaseIds() async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/releases/$language',
    );
    final relationships =
        (response.data?['data'] as Map<String, dynamic>?)?['relationships']
            as Map<String, dynamic>?;
    final entries =
        ((relationships?['releases'] as Map<String, dynamic>?)?['data']
            as List?) ??
        const [];
    return entries
        .map((raw) => (raw as Map<String, dynamic>)['id'])
        .whereType<String>()
        .map(_lastPathSegment)
        .toList();
  }

  Future<ReleaseDetail> release(String id) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/releases/$language/$id',
    );
    final data = response.data?['data'] as Map<String, dynamic>? ?? {};
    final attributes = data['attributes'] as Map<String, dynamic>? ?? {};
    final relationships = data['relationships'] as Map<String, dynamic>? ?? {};
    final cardEntries =
        ((relationships['cards'] as Map<String, dynamic>?)?['data'] as List?) ??
        const [];

    return ReleaseDetail(
      id: id,
      name: attributes['name'] as String? ?? id,
      cardIds: cardEntries
          .map((raw) => (raw as Map<String, dynamic>)['id'])
          .whereType<String>()
          .map(_lastPathSegment)
          .toList(),
      genre: attributes['genre'] as String?,
      date: attributes['date'] as String?,
      imageUrl: attributes['image'] as String?,
      thumbnailUrl: attributes['thumbnail'] as String?,
      productUri: attributes['product-uri'] as String?,
      cardlistUri: attributes['cardlist-uri'] as String?,
    );
  }

  /// Fetches release details with a bounded number of requests in flight, so a
  /// sync does not open 93 connections at once.
  Future<List<ReleaseDetail>> releaseDetails(
    List<String> ids, {
    int concurrency = 6,
    void Function(int completed, int total)? onProgress,
  }) async {
    final results = List<ReleaseDetail?>.filled(ids.length, null);
    var completed = 0;
    var next = 0;

    Future<void> worker() async {
      while (true) {
        final index = next++;
        if (index >= ids.length) return;
        results[index] = await release(ids[index]);
        onProgress?.call(++completed, ids.length);
      }
    }

    await Future.wait([
      for (var i = 0; i < concurrency && i < ids.length; i++) worker(),
    ]);
    return results.whereType<ReleaseDetail>().toList();
  }

  /// Streams the bulk dump to [savePath]. Returns the number of bytes written.
  Future<int> downloadBulk(
    BulkDataFile file,
    String savePath, {
    void Function(int received, int total)? onProgress,
  }) async {
    await _dio.download(
      file.downloadUrl,
      savePath,
      options: Options(headers: const {'User-Agent': userAgent}),
      onReceiveProgress: (received, total) {
        // `total` is -1 when the server omits Content-Length; fall back to the
        // size the index reported so the progress bar still moves.
        onProgress?.call(received, total > 0 ? total : file.sizeInBytes);
      },
    );
    return file.sizeInBytes;
  }

  static String _lastPathSegment(String path) => path.split('/').last;
}
