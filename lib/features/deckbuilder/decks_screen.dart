import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/router/navigation.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/digimon_colors.dart';
import '../../domain/models/card_enums.dart';
import '../../domain/models/deck.dart';
import '../../shared/widgets/card_thumbnail.dart';
import '../../shared/widgets/common.dart';
import 'deck_providers.dart';
import 'widgets/deck_name_dialog.dart';

/// The deck list — every deck the user has built.
class DecksScreen extends ConsumerStatefulWidget {
  const DecksScreen({super.key});

  @override
  ConsumerState<DecksScreen> createState() => _DecksScreenState();
}

class _DecksScreenState extends ConsumerState<DecksScreen> {
  final _controller = TextEditingController();
  String _query = '';

  /// A search box only earns its space once the shelf is long enough that a
  /// deck can be off screen.
  static const _searchFrom = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Decks whose own name or one of their revision names contains the query.
  ///
  /// Revisions count because that is where a deck's variants are named — a
  /// list called "Blue Flare" with a revision called "post-BT25" is what the
  /// user is looking for when they type either.
  List<Deck> _matching(List<Deck> decks) {
    final needle = _query.trim().toLowerCase();
    if (needle.isEmpty) return decks;
    return decks
        .where(
          (deck) =>
              deck.name.toLowerCase().contains(needle) ||
              deck.revisions.any((r) => r.name.toLowerCase().contains(needle)),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final decks = ref.watch(decksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decks'),
        actions: [
          IconButton(
            onPressed: () => context.pushOnce('/decks/import'),
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Import deck list',
          ),
        ],
      ),
      floatingActionButton: decks.valueOrNull?.isEmpty ?? true
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _createDeck(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('New deck'),
            ),
      body: decks.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load decks',
          message: '$error',
        ),
        data: (decks) {
          if (decks.isEmpty) {
            return EmptyState(
              icon: Icons.layers_outlined,
              title: 'No decks yet',
              message:
                  'Build a deck of 50 cards plus up to 5 Digi-Eggs. Every '
                  'deck keeps its own revisions, so you can try changes '
                  'without losing what worked.',
              action: FilledButton.icon(
                onPressed: () => _createDeck(context, ref),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create your first deck'),
              ),
            );
          }

          final visible = _matching(decks);
          return Column(
            children: [
              if (decks.length >= _searchFrom)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    controller: _controller,
                    onChanged: (value) => setState(() => _query = value),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'Search decks',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _controller.clear();
                                setState(() => _query = '');
                              },
                            ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: visible.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off,
                        title: 'No decks match',
                        message: 'Nothing here is called "${_query.trim()}".',
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) =>
                            _DeckCard(deck: visible[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Creates a deck and opens it straight away.
  ///
  /// It is not worth a dialog: a deck is far easier to name once you can see
  /// what went into it, and both the editor and a long press on the deck list
  /// rename it in place.
  Future<void> _createDeck(BuildContext context, WidgetRef ref) async {
    final deckId = await ref.read(deckDaoProvider).createDeck();
    if (context.mounted) context.pushOnce('/decks/$deckId');
  }
}

/// The actions a long press on a deck offers, so renaming or throwing away a
/// deck does not mean opening it first.
Future<void> showDeckActionsSheet(
  BuildContext context,
  WidgetRef ref,
  Deck deck,
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
              deck.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              deck.revisions.length == 1
                  ? '1 revision'
                  : '${deck.revisions.length} revisions',
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.drive_file_rename_outline),
            title: const Text('Rename'),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final name = await showDeckNameDialog(
                context,
                title: 'Rename deck',
                label: 'Deck name',
                initialValue: deck.name,
              );
              if (name != null) {
                await ref.read(deckDaoProvider).updateDeck(deck.id, name: name);
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: scheme.error),
            title: Text('Delete', style: TextStyle(color: scheme.error)),
            onTap: () async {
              Navigator.of(sheetContext).pop();
              final confirmed = await showDeleteDeckDialog(context, deck);
              if (confirmed) {
                await ref.read(deckDaoProvider).deleteDeck(deck.id);
              }
            },
          ),
        ],
      ),
    ),
  );
}

/// Confirms throwing a deck away, spelling out that its revisions go with it.
Future<bool> showDeleteDeckDialog(BuildContext context, Deck deck) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete ${deck.name}?'),
      content: Text(
        'The deck and all ${deck.revisions.length} of its revisions are '
        'removed. This cannot be undone.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
  return result ?? false;
}

class _DeckCard extends ConsumerWidget {
  const _DeckCard({required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final revision = deck.activeRevision;
    final composition = revision == null
        ? null
        : ref.watch(compositionProvider(revision.id)).valueOrNull;

    return Material(
      color: AppSurfaces.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.pushOnce('/decks/${deck.id}'),
        onLongPress: () => showDeckActionsSheet(context, ref, deck),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppSurfaces.outline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The card the user pinned, or the deck's biggest Digimon, so a
              // shelf of decks is told apart by its art rather than by
              // reading names.
              _DeckArt(
                entry: composition?.thumbnailFor(deck.thumbnailCardNumber),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            deck.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (composition != null)
                          _LegalityChip(composition: composition),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.history,
                          size: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            revision == null
                                ? 'No revisions'
                                : deck.revisions.length == 1
                                ? revision.name
                                : '${revision.name} · ${deck.revisions.length} revisions',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (composition != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _Count(
                            label: 'Main',
                            value: '${composition.mainDeckCount}',
                            total: DeckRules.mainDeckSize,
                            current: composition.mainDeckCount,
                          ),
                          const SizedBox(width: 14),
                          _Count(
                            label: 'Eggs',
                            value: '${composition.eggDeckCount}',
                            total: DeckRules.maxEggDeckSize,
                            current: composition.eggDeckCount,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _ColorBar(spread: composition.colorSpread),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Count extends StatelessWidget {
  const _Count({
    required this.label,
    required this.value,
    required this.total,
    required this.current,
  });

  final String label;
  final String value;
  final int total;
  final int current;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Main decks must hit their size exactly; egg decks only have a ceiling.
    final complete = label == 'Main' ? current == total : current <= total;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: complete ? scheme.onSurface : scheme.error,
          ),
        ),
        Text(
          '/$total',
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// The deck's signature card, or a placeholder while it has none.
class _DeckArt extends StatelessWidget {
  const _DeckArt({required this.entry});

  final DeckEntry? entry;

  static const _width = 62.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final entry = this.entry;
    return SizedBox(
      width: _width,
      height: _width / cardAspectRatio,
      child: entry == null
          ? DecoratedBox(
              decoration: BoxDecoration(
                color: AppSurfaces.surfaceHigh,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppSurfaces.outline),
              ),
              child: Icon(
                Icons.add_card,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            )
          : CardThumbnail(
              card: entry.card,
              borderRadius: 8,
              showColorEdge: false,
            ),
    );
  }
}

/// Proportional bar of the deck's colours, which is how players recognise a
/// deck at a glance.
class _ColorBar extends StatelessWidget {
  const _ColorBar({required this.spread});

  final Map<CardColor, int> spread;

  @override
  Widget build(BuildContext context) {
    if (spread.isEmpty) return const SizedBox.shrink();
    final ordered = CardColor.values
        .where((color) => (spread[color] ?? 0) > 0)
        .toList();

    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: SizedBox(
        width: double.infinity,
        height: 6,
        child: Row(
          // Stretch, not the default centre alignment: a childless ColoredBox
          // takes the smallest height a loose constraint allows, which is
          // zero, and the bar disappears.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final color in ordered)
              Expanded(
                flex: spread[color]!,
                child: ColoredBox(color: DigimonColors.of(color)),
              ),
          ],
        ),
      ),
    );
  }
}

class _LegalityChip extends StatelessWidget {
  const _LegalityChip({required this.composition});

  final DeckComposition composition;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final legal = composition.isLegal;
    final color = legal ? DigimonColors.green : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            legal ? Icons.check_circle : Icons.edit_outlined,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            legal ? 'Legal' : 'Draft',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
