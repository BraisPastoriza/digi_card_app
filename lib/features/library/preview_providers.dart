import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/providers.dart';
import 'library_providers.dart';

/// How long the preview sets are treated as current before the app checks them
/// again on its own.
///
/// Preview data moves on a scale of hours: a set is spoiled card by card over
/// the weeks before release, and corrections keep landing after that. Six
/// hours means somebody who opens the app daily is never more than a session
/// behind, at a cost of a handful of small requests.
const previewFreshness = Duration(hours: 6);

class PreviewRefreshState {
  const PreviewRefreshState({
    this.lastRefreshedAt,
    this.isRefreshing = false,
    this.latestBulkId,
    this.dismissedBulkId,
  });

  /// When every preview set was last checked, or null if never — which is the
  /// case right after the first sync, and after an app update.
  final DateTime? lastRefreshedAt;

  final bool isRefreshing;

  /// The card dump the primary API was publishing at the last check, or null
  /// if it has not been checked.
  final String? latestBulkId;

  /// The dump the user last said "not now" to.
  final String? dismissedBulkId;

  bool get isStale =>
      lastRefreshedAt == null ||
      DateTime.now().difference(lastRefreshedAt!) > previewFreshness;

  PreviewRefreshState copyWith({
    DateTime? lastRefreshedAt,
    bool? isRefreshing,
    String? latestBulkId,
    String? dismissedBulkId,
  }) => PreviewRefreshState(
    lastRefreshedAt: lastRefreshedAt ?? this.lastRefreshedAt,
    isRefreshing: isRefreshing ?? this.isRefreshing,
    latestBulkId: latestBulkId ?? this.latestBulkId,
    dismissedBulkId: dismissedBulkId ?? this.dismissedBulkId,
  );
}

/// Keeps the library up to date between full syncs.
///
/// A full sync is skipped whenever the primary card dump is unchanged, and
/// that dump is republished every few months — so before this existed, a
/// preview set was frozen at whatever the secondary source happened to have on
/// the day the user first synced. EX-13 in particular is revealed in batches,
/// and the app kept showing the first batch.
///
/// The same check notices when the primary dump *has* changed. Downloading it
/// is 25 MB, so that is offered rather than done: see
/// [cardUpdateAvailableProvider].
class PreviewRefreshNotifier extends Notifier<PreviewRefreshState> {
  static const _storageKey = 'previews_refreshed_at';
  static const _latestBulkKey = 'latest_bulk_id';
  static const _dismissedBulkKey = 'dismissed_bulk_id';

  @override
  PreviewRefreshState build() {
    unawaited(_restore());
    return const PreviewRefreshState();
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getInt(_storageKey);
    state = state.copyWith(
      lastRefreshedAt: stored == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(stored),
      latestBulkId: prefs.getString(_latestBulkKey),
      dismissedBulkId: prefs.getString(_dismissedBulkKey),
    );
  }

  /// Re-reads the preview sets and returns the ids of the ones that changed.
  ///
  /// [releaseId] narrows it to one set, which is what pulling down inside a
  /// set does. Only a refresh of all of them resets the staleness clock and
  /// asks the primary API for a newer dump: a pull on EX-13 says nothing about
  /// whether BT-26 has moved.
  Future<List<String>> refresh({String? releaseId}) async {
    if (state.isRefreshing) return const [];
    state = state.copyWith(isRefreshing: true);
    try {
      final service = ref.read(cardSyncServiceProvider);
      if (releaseId == null) await _checkPrimary();
      final changed = await service.refreshPreviews(onlyReleaseId: releaseId);

      if (releaseId == null) {
        final now = DateTime.now();
        await (await SharedPreferences.getInstance()).setInt(
          _storageKey,
          now.millisecondsSinceEpoch,
        );
        state = state.copyWith(lastRefreshedAt: now);
      }
      if (changed.isNotEmpty) _invalidateCardViews();
      return changed;
    } finally {
      state = state.copyWith(isRefreshing: false);
    }
  }

  /// Remembers which dump the primary API is publishing. Kept across launches
  /// so the offer to update survives until the user takes it, not just until
  /// the app is closed.
  Future<void> _checkPrimary() async {
    final latest = await ref.read(cardSyncServiceProvider).latestBulkId();
    if (latest == null) return;
    await (await SharedPreferences.getInstance()).setString(
      _latestBulkKey,
      latest,
    );
    state = state.copyWith(latestBulkId: latest);
  }

  /// Hides the offer to update until the primary API publishes another dump.
  Future<void> dismissUpdate() async {
    final latest = state.latestBulkId;
    if (latest == null) return;
    state = state.copyWith(dismissedBulkId: latest);
    await (await SharedPreferences.getInstance()).setString(
      _dismissedBulkKey,
      latest,
    );
  }

  /// Checks the preview sets if they have not been checked lately. Safe to
  /// call on every screen that would show stale data; it is a no-op until the
  /// data has actually aged.
  Future<void> refreshIfStale() async {
    if (!state.isStale || state.isRefreshing) return;
    await refresh();
  }

  /// Everything that has cards in it has to be re-read: card rows were
  /// deleted and reinserted, so anything holding the old ones is showing cards
  /// that no longer exist.
  void _invalidateCardViews() {
    ref.invalidate(releaseSectionsProvider);
    ref.invalidate(releaseProvider);
    ref.invalidate(releaseCardsProvider);
    ref.invalidate(cardPrintingsProvider);
    ref.invalidate(cardProvider);
    ref.invalidate(cardSearchProvider);
  }
}

final previewRefreshProvider =
    NotifierProvider<PreviewRefreshNotifier, PreviewRefreshState>(
      PreviewRefreshNotifier.new,
    );

/// Whether the primary API publishes a newer card dump than the one stored,
/// and the user has not already turned it down.
///
/// Settles itself: once a sync stores that dump the two ids match again, so
/// nothing has to remember to clear it.
final cardUpdateAvailableProvider = Provider<bool>((ref) {
  final refresh = ref.watch(previewRefreshProvider);
  final stored = ref.watch(syncStateProvider).valueOrNull?.bulkId;
  final latest = refresh.latestBulkId;
  return latest != null &&
      stored != null &&
      latest != stored &&
      latest != refresh.dismissedBulkId;
});
