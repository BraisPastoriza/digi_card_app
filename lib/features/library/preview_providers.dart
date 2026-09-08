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
/// behind, at a cost of one request to a set-listing endpoint.
const previewFreshness = Duration(hours: 6);

class PreviewRefreshState {
  const PreviewRefreshState({this.lastRefreshedAt, this.isRefreshing = false});

  /// When every preview set was last checked, or null if never — which is the
  /// case right after the first sync, and after an app update.
  final DateTime? lastRefreshedAt;

  final bool isRefreshing;

  bool get isStale =>
      lastRefreshedAt == null ||
      DateTime.now().difference(lastRefreshedAt!) > previewFreshness;

  PreviewRefreshState copyWith({
    DateTime? lastRefreshedAt,
    bool? isRefreshing,
  }) => PreviewRefreshState(
    lastRefreshedAt: lastRefreshedAt ?? this.lastRefreshedAt,
    isRefreshing: isRefreshing ?? this.isRefreshing,
  );
}

/// Keeps the not-yet-published sets up to date between full syncs.
///
/// A full sync is skipped whenever the primary card dump is unchanged, and
/// that dump is republished every few months — so before this existed, a
/// preview set was frozen at whatever the secondary source happened to have on
/// the day the user first synced. EX-13 in particular is revealed in batches,
/// and the app kept showing the first batch.
class PreviewRefreshNotifier extends Notifier<PreviewRefreshState> {
  static const _storageKey = 'previews_refreshed_at';

  @override
  PreviewRefreshState build() {
    unawaited(_restoreTimestamp());
    return const PreviewRefreshState();
  }

  Future<void> _restoreTimestamp() async {
    final stored = (await SharedPreferences.getInstance()).getInt(_storageKey);
    if (stored == null) return;
    state = state.copyWith(
      lastRefreshedAt: DateTime.fromMillisecondsSinceEpoch(stored),
    );
  }

  /// Re-reads the preview sets and returns the ids of the ones that changed.
  ///
  /// [releaseId] narrows it to one set, which is what pulling down inside a
  /// set does. Only a refresh of all of them resets the staleness clock: a
  /// pull on EX-13 says nothing about whether BT-26 has moved.
  Future<List<String>> refresh({String? releaseId}) async {
    if (state.isRefreshing) return const [];
    state = state.copyWith(isRefreshing: true);
    try {
      final changed = await ref
          .read(cardSyncServiceProvider)
          .refreshPreviews(onlyReleaseId: releaseId);

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
      state = PreviewRefreshState(lastRefreshedAt: state.lastRefreshedAt);
    }
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
