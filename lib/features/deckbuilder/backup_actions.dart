import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/backup/backup_service.dart';
import '../../l10n/l10n.dart';

/// Saves every deck and staple list to a file the user picks the place of.
///
/// The system's own save dialog, so the file can go to Downloads, a cloud
/// drive or anywhere else the device offers, and the app needs no storage
/// permission to put it there.
Future<void> exportBackup(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  try {
    final bytes = await ref.read(backupServiceProvider).exportBytes();
    final saved = await FilePicker.saveFile(
      fileName: 'digicard-backup-${_today()}.json',
      bytes: bytes,
      mimeType: 'application/json',
    );
    if (saved == null) return;
    _show(messenger, l10n.backupExported);
  } on Object {
    _show(messenger, l10n.backupExportFailed);
  }
}

/// Reads a backup the user picks and, once they confirm, adds its decks and
/// staple lists to the ones already here.
Future<void> restoreBackup(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);

  final PlatformFile? file;
  final Map<String, dynamic> backup;
  try {
    // Any file rather than a JSON filter: Android's picker greys out a file
    // whose type some other app recorded differently, and the parse below
    // says plainly when the file is not a backup.
    file = await FilePicker.pickFile();
    if (file == null) return;
    backup = BackupService.parse(await file.readAsBytes());
  } on BackupFormatException catch (error) {
    _show(
      messenger,
      error.reason == BackupFormatProblem.tooNew
          ? l10n.backupTooNew
          : l10n.backupNotABackup,
    );
    return;
  } on Object {
    _show(messenger, l10n.backupReadFailed);
    return;
  }

  if (!context.mounted) return;
  final contents = BackupService.contentsOf(backup);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.backupRestoreTitle),
      content: Text(
        context.l10n.backupRestoreBody(contents.decks, contents.stapleLists),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(context.l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(context.l10n.backupRestoreAction),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  try {
    final result = await ref.read(backupServiceProvider).restore(backup);
    _show(
      messenger,
      l10n.backupRestored(
        result.decksAdded,
        result.decksSkipped,
        result.listsAdded + result.listsMerged,
      ),
    );
  } on Object {
    _show(messenger, l10n.backupRestoreFailed);
  }
}

void _show(ScaffoldMessengerState messenger, String message) => messenger
  ..hideCurrentSnackBar()
  ..showSnackBar(SnackBar(content: Text(message)));

String _today() {
  final now = DateTime.now();
  return '${now.year}-${now.month.toString().padLeft(2, '0')}-'
      '${now.day.toString().padLeft(2, '0')}';
}
