import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/models/app_release.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/common.dart';
import 'app_update_providers.dart';

/// Offers the newer release of the app GitHub has, if there is one, and on
/// Android downloads and installs it from right here.
///
/// Elsewhere it only says where to get it: this app opens no browser, so the
/// address is there to copy.
class AppUpdateBanner extends ConsumerWidget {
  const AppUpdateBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final update = ref.watch(appUpdateProvider);
    final release = update.offered;
    if (release == null) return const SizedBox.shrink();

    final notifier = ref.read(appUpdateProvider.notifier);
    final l10n = context.l10n;
    final downloading = update.phase == AppUpdatePhase.downloading;
    final canInstall = defaultTargetPlatform == TargetPlatform.android;

    return NoticeBanner(
      icon: Icons.new_releases_outlined,
      title: l10n.appUpdateTitle(release.version),
      body: [
        NoticeBanner.text(context, release.title),
        if (!canInstall) ...[
          NoticeBanner.text(context, l10n.appUpdateWhereToGet),
          SelectableText(
            release.pageUrl,
            style: const TextStyle(fontSize: 12.5, height: 1.45),
          ),
        ] else if (downloading) ...[
          const SizedBox(height: 4),
          LinearProgressIndicator(value: update.progress),
          NoticeBanner.text(
            context,
            l10n.appUpdateDownloading(((update.progress ?? 0) * 100).round()),
          ),
        ] else if (update.phase == AppUpdatePhase.failed)
          NoticeBanner.text(context, _failureMessage(context, update.failure))
        else
          NoticeBanner.text(context, l10n.appUpdateInstallHint),
      ],
      actions: [
        if (release.notes.isNotEmpty)
          TextButton(
            onPressed: () => _showNotes(context, release),
            child: Text(l10n.appUpdateNotes),
          ),
        if (!downloading)
          TextButton(
            onPressed: notifier.dismiss,
            child: Text(l10n.appUpdateDismiss),
          ),
        if (canInstall)
          TextButton(
            onPressed: downloading ? null : notifier.downloadAndInstall,
            child: Text(
              update.phase == AppUpdatePhase.failed
                  ? l10n.appUpdateRetry
                  : l10n.appUpdateInstall,
            ),
          ),
      ],
    );
  }

  static String _failureMessage(
    BuildContext context,
    AppUpdateFailure? failure,
  ) => switch (failure) {
    AppUpdateFailure.corrupt => context.l10n.appUpdateFailedCorrupt,
    AppUpdateFailure.noApk => context.l10n.appUpdateFailedNoApk,
    AppUpdateFailure.installer => context.l10n.appUpdateFailedInstaller,
    AppUpdateFailure.download || null => context.l10n.appUpdateFailedDownload,
  };

  static void _showNotes(BuildContext context, AppRelease release) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(release.title),
        content: SingleChildScrollView(child: ReleaseNotes(release.notes)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).closeButtonLabel),
          ),
        ],
      ),
    );
  }
}

/// Release notes, written in GitHub's Markdown, drawn well enough to read.
///
/// Only what the notes actually use: headings, bullets, bold and inline
/// code, with links reduced to their text. A full Markdown renderer would be a
/// dependency for one dialog.
class ReleaseNotes extends StatelessWidget {
  const ReleaseNotes(this.markdown, {super.key});

  final String markdown;

  static final _heading = RegExp(r'^(#{1,6})\s+(.*)$');
  static final _bullet = RegExp(r'^\s*[-*]\s+(.*)$');

  /// `**bold**`, `` `code` `` and `[text](url)`, in the order they appear.
  static final _inline = RegExp(
    r'\*\*(.+?)\*\*|`([^`]+)`|\[([^\]]+)\]\([^)]*\)',
  );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    const body = TextStyle(fontSize: 13.5, height: 1.45);
    final blocks = <Widget>[];
    for (final line in markdown.split(RegExp(r'\r?\n'))) {
      if (line.trim().isEmpty) {
        if (blocks.isNotEmpty) blocks.add(const SizedBox(height: 8));
        continue;
      }
      final heading = _heading.firstMatch(line);
      final bullet = _bullet.firstMatch(line);
      if (heading != null) {
        blocks.add(
          Text.rich(
            _spans(heading.group(2)!),
            style: body.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface,
            ),
          ),
        );
      } else if (bullet != null) {
        blocks.add(
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('•  ', style: body.copyWith(color: scheme.primary)),
                Expanded(
                  child: Text.rich(_spans(bullet.group(1)!), style: body),
                ),
              ],
            ),
          ),
        );
      } else {
        blocks.add(Text.rich(_spans(line.trim()), style: body));
      }
    }
    return SelectionArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: blocks,
      ),
    );
  }

  static TextSpan _spans(String text) {
    final spans = <InlineSpan>[];
    var at = 0;
    for (final match in _inline.allMatches(text)) {
      if (match.start > at) {
        spans.add(TextSpan(text: text.substring(at, match.start)));
      }
      final bold = match.group(1);
      if (bold != null) {
        spans.add(
          TextSpan(
            // Bold often wraps code, as in **`app-release.apk`**.
            text: bold.replaceAll('`', ''),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        );
      } else if (match.group(2) != null) {
        spans.add(
          TextSpan(
            text: match.group(2),
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        );
      } else {
        spans.add(TextSpan(text: match.group(3)));
      }
      at = match.end;
    }
    if (at < text.length) spans.add(TextSpan(text: text.substring(at)));
    return TextSpan(children: spans);
  }
}
