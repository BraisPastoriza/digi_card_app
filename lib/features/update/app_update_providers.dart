import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_info.dart';
import '../../core/providers.dart';
import '../../domain/models/app_release.dart';

/// How long a check for a newer app version is trusted.
///
/// Releases come weeks apart; a day keeps the offer prompt without asking
/// GitHub on every launch.
const appUpdateFreshness = Duration(days: 1);

/// Where getting a newer version onto the device has got to.
enum AppUpdatePhase { idle, downloading, failed }

/// Why getting the update failed, for the message under it.
enum AppUpdateFailure {
  /// The download did not finish.
  download,

  /// The file arrived, but not as GitHub recorded it, and was thrown away.
  corrupt,

  /// The release has no APK this device can run.
  noApk,

  /// Android's installer could not be opened.
  installer,
}

class AppUpdateState {
  const AppUpdateState({
    this.release,
    this.dismissedTag,
    this.checkedAt,
    this.phase = AppUpdatePhase.idle,
    this.progress,
    this.failure,
  });

  /// The newest release, when it is newer than the installed version.
  final AppRelease? release;

  /// The release the user said "not now" to.
  final String? dismissedTag;

  final DateTime? checkedAt;

  final AppUpdatePhase phase;

  /// 0..1 while downloading, null while the size is unknown.
  final double? progress;

  final AppUpdateFailure? failure;

  /// The release worth showing the user, if any.
  AppRelease? get offered {
    final release = this.release;
    if (release == null || release.tag == dismissedTag) return null;
    return release;
  }

  bool get isStale =>
      checkedAt == null ||
      DateTime.now().difference(checkedAt!) > appUpdateFreshness;

  AppUpdateState copyWith({
    AppRelease? release,
    bool clearRelease = false,
    String? dismissedTag,
    DateTime? checkedAt,
    AppUpdatePhase? phase,
    double? progress,
    AppUpdateFailure? failure,
  }) => AppUpdateState(
    release: clearRelease ? null : release ?? this.release,
    dismissedTag: dismissedTag ?? this.dismissedTag,
    checkedAt: checkedAt ?? this.checkedAt,
    phase: phase ?? this.phase,
    // Both only describe the phase they were set in, so a new phase starts
    // them over and anything else leaves them be.
    progress: phase == null ? this.progress : progress,
    failure: phase == null ? this.failure : failure,
  );
}

/// Offers, downloads and installs newer releases of the app from GitHub.
///
/// The release found is remembered between launches, so the offer stays up
/// until the user takes it or says no, not just until the next cold start
/// inside the day the check is trusted for.
class AppUpdateNotifier extends Notifier<AppUpdateState> {
  static const _releaseKey = 'app_update_release';
  static const _checkedKey = 'app_update_checked_at';
  static const _dismissedKey = 'app_update_dismissed';

  static const _apkType = 'application/vnd.android.package-archive';

  late final Future<void> _restored = _restore();

  @override
  AppUpdateState build() {
    unawaited(_restored);
    return const AppUpdateState();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final checked = prefs.getInt(_checkedKey);
    final stored = prefs.getString(_releaseKey);
    final release = stored == null
        ? null
        : AppRelease.fromJson(jsonDecode(stored) as Map<String, dynamic>);
    state = state.copyWith(
      // An offer the user has since installed is no offer.
      release: release != null && release.isNewerThan(AppInfo.version)
          ? release
          : null,
      checkedAt: checked == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(checked),
      dismissedTag: prefs.getString(_dismissedKey),
    );
  }

  /// Asks GitHub for a newer release if it has not been asked lately.
  Future<void> checkIfStale() async {
    await _restored;
    if (state.isStale) await check();
  }

  /// Asks GitHub for the latest release. Failing is quiet: the offer is a
  /// convenience, and the next check is a day away.
  Future<void> check() async {
    await _restored;
    final AppRelease? latest;
    try {
      latest = await ref.read(gitHubApiProvider).latestRelease();
    } on Object {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    await prefs.setInt(_checkedKey, now.millisecondsSinceEpoch);
    if (latest != null && latest.isNewerThan(AppInfo.version)) {
      await prefs.setString(_releaseKey, jsonEncode(latest.toJson()));
      state = state.copyWith(release: latest, checkedAt: now);
    } else {
      await prefs.remove(_releaseKey);
      state = state.copyWith(clearRelease: true, checkedAt: now);
    }
  }

  /// Hides the offer until a newer release than this one comes out.
  Future<void> dismiss() async {
    final release = state.release;
    if (release == null) return;
    state = state.copyWith(dismissedTag: release.tag);
    await (await SharedPreferences.getInstance()).setString(
      _dismissedKey,
      release.tag,
    );
  }

  /// Downloads the APK for this device, checks it, and opens Android's
  /// installer on it. Android asks the user to confirm the install, and the
  /// first time to allow installs from this app at all.
  Future<void> downloadAndInstall() async {
    final release = state.release;
    if (release == null || state.phase == AppUpdatePhase.downloading) return;

    final abis = (await DeviceInfoPlugin().androidInfo).supportedAbis;
    final asset = release.apkFor(abis);
    if (asset == null) {
      state = state.copyWith(
        phase: AppUpdatePhase.failed,
        failure: AppUpdateFailure.noApk,
      );
      return;
    }

    state = state.copyWith(phase: AppUpdatePhase.downloading);
    // The app's own cache: no storage permission needed to write it, nor for
    // the installer to read it, and Android clears it when space runs low.
    final file = File(
      p.join((await getTemporaryDirectory()).path, 'update-${asset.name}'),
    );
    try {
      // A download that already finished and checks out is not fetched
      // again: the user may have backed out of the installer and come back.
      if (!await _isIntact(file, asset)) {
        await ref
            .read(gitHubApiProvider)
            .download(
              asset,
              file.path,
              onProgress: (received, total) => state = state.copyWith(
                phase: AppUpdatePhase.downloading,
                progress: total > 0 ? received / total : null,
              ),
            );
      }
    } on Object {
      if (await file.exists()) await file.delete();
      state = state.copyWith(
        phase: AppUpdatePhase.failed,
        failure: AppUpdateFailure.download,
      );
      return;
    }

    if (!await _isIntact(file, asset)) {
      await file.delete();
      state = state.copyWith(
        phase: AppUpdatePhase.failed,
        failure: AppUpdateFailure.corrupt,
      );
      return;
    }

    final opened = await OpenFilex.open(file.path, type: _apkType);
    state = opened.type == ResultType.done
        ? state.copyWith(phase: AppUpdatePhase.idle)
        : state.copyWith(
            phase: AppUpdatePhase.failed,
            failure: AppUpdateFailure.installer,
          );
  }

  /// Whether [file] is [asset] as GitHub recorded it.
  ///
  /// Android only installs an update signed with the same key as the app it
  /// replaces, so a tampered APK would be refused anyway; this catches the
  /// commoner case, a download cut short, before the user meets Android's
  /// far less helpful "There was a problem parsing the package".
  static Future<bool> _isIntact(File file, ReleaseAsset asset) async {
    if (!await file.exists()) return false;
    if (await file.length() != asset.size) return false;
    final expected = asset.sha256;
    if (expected == null) return true;
    final digest = await sha256.bind(file.openRead()).first;
    return digest.toString() == expected;
  }
}

final appUpdateProvider = NotifierProvider<AppUpdateNotifier, AppUpdateState>(
  AppUpdateNotifier.new,
);
