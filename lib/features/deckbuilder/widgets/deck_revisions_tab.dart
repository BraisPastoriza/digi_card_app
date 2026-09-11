import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/deck.dart';
import '../../../l10n/l10n.dart';
import '../deck_providers.dart';
import 'deck_name_dialog.dart';

/// The deck's revision history.
///
/// One revision is always active — the one the editor writes to. Branching a
/// new revision copies the active one, which is how a player tries a change
/// without losing the list that was working.
class DeckRevisionsTab extends ConsumerWidget {
  const DeckRevisionsTab({super.key, required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
      children: [
        Text(
          context.l10n.revisionsExplainer,
          style: TextStyle(
            fontSize: 13,
            height: 1.45,
            color: scheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        for (final revision in deck.revisions)
          _RevisionCard(
            deck: deck,
            revision: revision,
            active: revision.id == deck.activeRevision?.id,
          ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _branch(context, ref),
                icon: const Icon(Icons.call_split, size: 18),
                label: Text(context.l10n.revisionsBranch),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _createEmpty(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: Text(context.l10n.revisionsEmpty),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Suggests the next `vN` name, continuing the numbering the user already
  /// has rather than restarting it.
  String _suggestedName() {
    final numbers = deck.revisions
        .map((r) => RegExp(r'^v(\d+)$').firstMatch(r.name)?.group(1))
        .whereType<String>()
        .map(int.parse);
    final next = numbers.isEmpty
        ? deck.revisions.length + 1
        : numbers.reduce((a, b) => a > b ? a : b) + 1;
    return 'v$next';
  }

  Future<void> _branch(BuildContext context, WidgetRef ref) async {
    final source = deck.activeRevision;
    if (source == null) return;
    final name = await showDeckNameDialog(
      context,
      title: context.l10n.revisionBranchTitle(source.name),
      label: context.l10n.revisionNameLabel,
      initialValue: _suggestedName(),
      confirmLabel: context.l10n.actionCreate,
      helperText: context.l10n.revisionBranchHelper(source.name),
    );
    if (name == null) return;
    await ref
        .read(deckDaoProvider)
        .createRevisionFrom(
          deckId: deck.id,
          sourceRevisionId: source.id,
          name: name,
        );
  }

  Future<void> _createEmpty(BuildContext context, WidgetRef ref) async {
    final name = await showDeckNameDialog(
      context,
      title: context.l10n.revisionNewEmptyTitle,
      label: context.l10n.revisionNameLabel,
      initialValue: _suggestedName(),
      confirmLabel: context.l10n.actionCreate,
    );
    if (name == null) return;
    await ref
        .read(deckDaoProvider)
        .createEmptyRevision(deckId: deck.id, name: name);
  }
}

class _RevisionCard extends ConsumerWidget {
  const _RevisionCard({
    required this.deck,
    required this.revision,
    required this.active,
  });

  final Deck deck;
  final DeckRevision revision;
  final bool active;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final composition = ref.watch(compositionProvider(revision.id)).valueOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppSurfaces.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active ? scheme.primary : AppSurfaces.outline,
          width: active ? 1.5 : 1,
        ),
      ),
      child: ListTile(
        onTap: active
            ? null
            : () => ref
                  .read(deckDaoProvider)
                  .setActiveRevision(deck.id, revision.id),
        contentPadding: const EdgeInsets.fromLTRB(14, 4, 6, 4),
        leading: Icon(
          active ? Icons.radio_button_checked : Icons.radio_button_unchecked,
          color: active ? scheme.primary : scheme.onSurfaceVariant,
          size: 20,
        ),
        title: Text(revision.name),
        subtitle: Text(
          composition == null
              ? _formatDate(revision.updatedAt)
              : context.l10n.revisionSummary(
                  composition.mainDeckCount,
                  composition.eggDeckCount,
                  _formatDate(revision.updatedAt),
                ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (action) => _handle(context, ref, action),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'rename',
              child: Text(context.l10n.actionRename),
            ),
            PopupMenuItem(
              value: 'duplicate',
              child: Text(context.l10n.actionDuplicate),
            ),
            if (deck.revisions.length > 1)
              PopupMenuItem(
                value: 'delete',
                child: Text(
                  context.l10n.actionDelete,
                  style: TextStyle(color: scheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    String action,
  ) async {
    final dao = ref.read(deckDaoProvider);
    switch (action) {
      case 'rename':
        final name = await showDeckNameDialog(
          context,
          title: context.l10n.revisionRenameTitle,
          label: context.l10n.revisionNameLabel,
          initialValue: revision.name,
        );
        if (name != null) await dao.renameRevision(revision.id, name);
      case 'duplicate':
        if (!context.mounted) return;
        final name = await showDeckNameDialog(
          context,
          title: context.l10n.revisionDuplicateTitle(revision.name),
          label: context.l10n.revisionNameLabel,
          initialValue: context.l10n.revisionCopyName(revision.name),
          confirmLabel: context.l10n.actionCreate,
        );
        if (name != null) {
          await dao.createRevisionFrom(
            deckId: deck.id,
            sourceRevisionId: revision.id,
            name: name,
          );
        }
      case 'delete':
        if (!context.mounted) return;
        final confirmed = await _confirmDelete(context);
        if (confirmed) await dao.deleteRevision(deck.id, revision.id);
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.revisionDeleteTitle(revision.name)),
        content: Text(context.l10n.revisionDeleteBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(context.l10n.actionDelete),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
