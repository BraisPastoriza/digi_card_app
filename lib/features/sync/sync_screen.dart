import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/sync/card_sync_service.dart';
import '../../shared/widgets/app_logo.dart';

/// First-run screen that fills the local card database.
///
/// On later launches it finds cards already stored and hands over to the
/// library immediately, so this is only visible while there is real work to
/// do — or when the user asks for a refresh.
class SyncScreen extends ConsumerStatefulWidget {
  const SyncScreen({super.key, this.force = false});

  /// Re-downloads even when the local data is already current.
  final bool force;

  @override
  ConsumerState<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends ConsumerState<SyncScreen> {
  StreamSubscription<SyncProgress>? _subscription;
  SyncProgress _progress = const SyncProgress(SyncStage.checking);

  /// True while the cards already on the device are being read again under
  /// new parsers. It is a local pass, not a download, and usually over in a
  /// second or two — but it must finish before anything reads the cards.
  bool _rederiving = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _start() async {
    final service = ref.read(cardSyncServiceProvider);
    final resyncRequested = ref.read(resyncRequestedProvider);
    ref.read(resyncRequestedProvider.notifier).state = false;

    if (!widget.force && !resyncRequested && await service.hasCards()) {
      // An update that changed how card text is read is settled here, out of
      // the cards already stored — the alternative used to be throwing them
      // away and downloading 25 MB again.
      if (await service.needsRederive()) {
        if (!mounted) return;
        setState(() => _rederiving = true);
        await service.rederive();
        if (!mounted) return;
        setState(() => _rederiving = false);
      }
      // Cards from a previous run are enough to open the app; the update check
      // waits until the user asks for it rather than blocking every launch.
      if (mounted) ref.read(libraryReadyProvider.notifier).markReady();
      return;
    }

    setState(() => _progress = const SyncProgress(SyncStage.checking));
    await _subscription?.cancel();
    _subscription = service.sync(force: widget.force).listen((progress) {
      if (!mounted) return;
      setState(() => _progress = progress);
      if (progress.stage == SyncStage.complete) {
        ref.read(libraryReadyProvider.notifier).markReady();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final failed = _progress.stage == SyncStage.failed;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AppLogo(),
              const SizedBox(height: 28),
              const Text(
                'DigiCard App',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                failed
                    ? 'Could not download the card database'
                    : _rederiving
                    ? 'Updating your cards to the new card rules'
                    : 'Setting up your card library',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 40),
              if (failed)
                _SyncError(error: _progress.error, onRetry: _start)
              else if (_rederiving)
                // No download to report on, so no stage list: this is a pass
                // over cards the device already has.
                const Column(
                  children: [
                    LinearProgressIndicator(),
                    SizedBox(height: 14),
                    Text(
                      'Reading the cards you already have. Nothing is being '
                      'downloaded.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                )
              else
                _SyncProgressView(progress: _progress),
            ],
          ),
        ),
      ),
    );
  }
}

class _SyncProgressView extends StatelessWidget {
  const _SyncProgressView({required this.progress});

  final SyncProgress progress;

  /// The stages the user actually waits on, in order.
  static const _stages = [
    SyncStage.checking,
    SyncStage.releases,
    SyncStage.downloading,
    SyncStage.parsing,
    SyncStage.storing,
    SyncStage.indexing,
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stage = progress.stage;
    final index = stage == SyncStage.complete
        ? _stages.length
        : _stages.indexOf(stage);

    // Blend the step we are on with how far through it we are, so the bar
    // moves continuously rather than jumping between stages.
    final stepFraction = progress.fraction ?? 0;
    final overall = index < 0
        ? 0.0
        : ((index + stepFraction) / _stages.length).clamp(0.0, 1.0);

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: overall == 0 ? null : overall,
            minHeight: 6,
            backgroundColor: AppSurfaces.surfaceHigh,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          stage.label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        SizedBox(
          height: 20,
          child: Text(
            progress.detail ?? '',
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'The full card list is stored on your device, so the '
          'library and deck builder work offline.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.5,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SyncError extends StatelessWidget {
  const _SyncError({required this.error, required this.onRetry});

  final Object? error;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppSurfaces.surfaceHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppSurfaces.outline),
          ),
          child: Text(
            _describe(error),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton.icon(
          onPressed: () => onRetry(),
          icon: const Icon(Icons.refresh, size: 18),
          label: const Text('Try again'),
        ),
      ],
    );
  }

  static String _describe(Object? error) {
    if (error == null) return 'Something went wrong.';
    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('Failed host lookup') ||
        text.contains('connection error')) {
      return 'No internet connection. Connect and try again — the card '
          'database only needs to download once.';
    }
    return text;
  }
}
