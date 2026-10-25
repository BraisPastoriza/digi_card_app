/// A published release of this app on GitHub.
///
/// Read from, and stored as, the GitHub REST API's own release shape, so a
/// release remembered between launches is parsed by exactly the code that
/// parsed it the first time.
class AppRelease {
  const AppRelease({
    required this.tag,
    required this.title,
    required this.notes,
    required this.pageUrl,
    required this.assets,
  });

  factory AppRelease.fromJson(Map<String, dynamic> json) {
    final tag = json['tag_name'] as String? ?? '';
    return AppRelease(
      tag: tag,
      title: (json['name'] as String?)?.trim().nonEmpty ?? tag,
      notes: (json['body'] as String?)?.trim() ?? '',
      pageUrl: json['html_url'] as String? ?? '',
      assets: [
        for (final raw in (json['assets'] as List?) ?? const [])
          if (raw is Map<String, dynamic>) ReleaseAsset.fromJson(raw),
      ],
    );
  }

  /// The git tag, e.g. `v1.3.0`.
  final String tag;

  /// What the release is called on GitHub, e.g. `v1.3.0 — Parejas
  /// prohibidas y app en español`.
  final String title;

  /// The release notes, as written: Markdown.
  final String notes;

  final String pageUrl;
  final List<ReleaseAsset> assets;

  /// [tag] without its leading `v`, comparable with the installed version.
  String get version => tag.startsWith('v') ? tag.substring(1) : tag;

  bool isNewerThan(String installedVersion) =>
      compareVersions(version, installedVersion) > 0;

  /// The APK to install on a device that runs [supportedAbis], best first as
  /// Android lists them.
  ///
  /// Releases ship one APK per ABI plus a universal one three times the size.
  /// The device's own ABI is preferred; the universal APK is the fallback for
  /// anything without its own, such as an x86_64 emulator.
  ReleaseAsset? apkFor(List<String> supportedAbis) {
    final apks = {
      for (final asset in assets)
        if (asset.name.endsWith('.apk')) asset.name: asset,
    };
    for (final abi in supportedAbis) {
      final own = apks['app-$abi-release.apk'];
      if (own != null) return own;
    }
    return apks['app-release.apk'];
  }

  Map<String, dynamic> toJson() => {
    'tag_name': tag,
    'name': title,
    'body': notes,
    'html_url': pageUrl,
    'assets': [for (final asset in assets) asset.toJson()],
  };
}

/// One file attached to a release.
class ReleaseAsset {
  const ReleaseAsset({
    required this.name,
    required this.downloadUrl,
    required this.size,
    this.sha256,
  });

  factory ReleaseAsset.fromJson(Map<String, dynamic> json) {
    final digest = json['digest'] as String?;
    return ReleaseAsset(
      name: json['name'] as String? ?? '',
      downloadUrl: json['browser_download_url'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      sha256: digest != null && digest.startsWith('sha256:')
          ? digest.substring('sha256:'.length).toLowerCase()
          : null,
    );
  }

  final String name;
  final String downloadUrl;

  /// In bytes.
  final int size;

  /// Hex digest GitHub computed when the file was uploaded, or null for an
  /// asset uploaded before GitHub started recording one.
  final String? sha256;

  Map<String, dynamic> toJson() => {
    'name': name,
    'browser_download_url': downloadUrl,
    'size': size,
    if (sha256 != null) 'digest': 'sha256:$sha256',
  };
}

/// Orders two dotted version numbers, `1.10.0` after `1.9.2`.
///
/// Only the leading digits of each part count, so a suffix such as `-beta`
/// neither breaks the comparison nor outranks the plain release; a missing
/// part counts as zero, so `1.3` and `1.3.0` are the same version.
int compareVersions(String a, String b) {
  List<int> parts(String version) => [
    for (final part in version.split('.'))
      int.tryParse(RegExp(r'^\d+').stringMatch(part) ?? '') ?? 0,
  ];
  final left = parts(a);
  final right = parts(b);
  for (var i = 0; i < left.length || i < right.length; i++) {
    final x = i < left.length ? left[i] : 0;
    final y = i < right.length ? right[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}

extension on String {
  String? get nonEmpty => isEmpty ? null : this;
}
