import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/router/navigation.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/models/staple_list.dart';
import '../../../l10n/l10n.dart';
import '../../../shared/widgets/card_thumbnail.dart';
import '../../../shared/widgets/common.dart';
import '../staple_providers.dart';
import 'deck_name_dialog.dart';

/// The user's staple lists: the cards they keep at hand while building.
class StaplesTab extends ConsumerWidget {
  const StaplesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(stapleListsProvider);

    return lists.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.error_outline,
        title: context.l10n.staplesLoadError,
        message: '$error',
      ),
      data: (lists) => lists.isEmpty
          ? EmptyState(
              icon: Icons.bookmarks_outlined,
              title: context.l10n.staplesEmptyTitle,
              message:
                  context.l10n.staplesEmptyMessage,
              action: FilledButton.icon(
                onPressed: () => createStapleList(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: Text(context.l10n.staplesCreate),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              itemCount: lists.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _StapleTile(list: lists[index]),
            ),
    );
  }
}

/// Creates a list and opens it, so the next thing on screen is the card
/// picker rather than an empty row in a list.
Future<void> createStapleList(BuildContext context, WidgetRef ref) async {
  final name = await showDeckNameDialog(
    context,
    title: context.l10n.stapleNewTitle,
    label: context.l10n.stapleNameLabel,
    initialValue: '',
  );
  if (name == null) return;
  final listId = await ref.read(stapleDaoProvider).createList(name: name);
  if (context.mounted) context.pushOnce('/decks/staples/$listId');
}

/// Rename and delete, from a long press on a list or the list's own menu.
Future<void> showStapleActionsSheet(
  BuildContext context,
  WidgetRef ref,
  StapleList list,
) {
  final scheme = Theme.of(context).colorScheme;
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(
              list.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(context.l10n.cardCount(list.count)),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline),
            title: Text(context.l10n.actionRename),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final name = await showDeckNameDialog(
                context,
                title: context.l10n.stapleMenuRename,
                label: context.l10n.stapleNameLabel,
                initialValue: list.name,
              );
              if (name != null) {
                await ref.read(stapleDaoProvider).renameList(list.id, name);
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: scheme.error),
            title: Text(
              context.l10n.actionDelete,
              style: TextStyle(color: scheme.error),
            ),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              if (await showDeleteStapleListDialog(context, list)) {
                await ref.read(stapleDaoProvider).deleteList(list.id);
              }
            },
          ),
        ],
      ),
    ),
  );
}

Future<bool> showDeleteStapleListDialog(
  BuildContext context,
  StapleList list,
) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.stapleDeleteTitle(list.name)),
      content: Text(
        context.l10n.stapleDeleteBody(list.count),
      ),
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

class _StapleTile extends ConsumerWidget {
  const _StapleTile({required this.list});

  final StapleList list;

  /// Enough art to recognise the list without turning the row into a gallery.
  static const _previewCards = 6;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final preview = list.cards.take(_previewCards).toList();

    return Material(
      color: AppSurfaces.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.pushOnce('/decks/staples/${list.id}'),
        onLongPress: () => showStapleActionsSheet(context, ref, list),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppSurfaces.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      list.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    context.l10n.cardCount(list.count),
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (preview.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    context.l10n.stapleNothingYet,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                )
              else ...[
                const SizedBox(height: 12),
                Row(
                  spacing: 6,
                  children: [
                    for (final card in preview)
                      Expanded(
                        child: AspectRatio(
                          aspectRatio: cardAspectRatio,
                          child: CardThumbnail(card: card, borderRadius: 6),
                        ),
                      ),
                    // Keeps the row's cards the size they would be in a full
                    // row, rather than stretching three cards across it.
                    for (var i = preview.length; i < _previewCards; i++)
                      const Expanded(child: SizedBox.shrink()),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
