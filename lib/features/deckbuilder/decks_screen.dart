import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/digimon_colors.dart';
import '../../domain/models/card_enums.dart';
import '../../domain/models/deck.dart';
import '../../shared/widgets/common.dart';
import 'deck_providers.dart';
import 'widgets/deck_name_dialog.dart';

/// The deck list — every deck the user has built.
class DecksScreen extends ConsumerWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final decks = ref.watch(decksProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Decks')),
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
        data: (decks) => decks.isEmpty
            ? EmptyState(
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
              )
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                itemCount: decks.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) =>
                    _DeckCard(deck: decks[index]),
              ),
      ),
    );
  }

  Future<void> _createDeck(BuildContext context, WidgetRef ref) async {
    final name = await showDeckNameDialog(
      context,
      title: 'New deck',
      label: 'Deck name',
      confirmLabel: 'Create',
    );
    if (name == null || !context.mounted) return;
    final deckId = await ref.read(deckDaoProvider).createDeck(name: name);
    if (context.mounted) context.go('/decks/$deckId');
  }
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
        onTap: () => context.go('/decks/${deck.id}'),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(16),
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
                      deck.name,
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
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    revision == null
                        ? 'No revisions'
                        : deck.revisions.length == 1
                        ? revision.name
                        : '${revision.name} · ${deck.revisions.length} revisions',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: scheme.onSurfaceVariant,
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
                    const SizedBox(width: 16),
                    _Count(
                      label: 'Eggs',
                      value: '${composition.eggDeckCount}',
                      total: DeckRules.maxEggDeckSize,
                      current: composition.eggDeckCount,
                    ),
                    const Spacer(),
                    _ColorBar(spread: composition.colorSpread),
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
        width: 84,
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
