import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/digimon_colors.dart';
import '../../../domain/models/card_enums.dart';
import '../../../l10n/l10n.dart';
import '../deck_text.dart';
import '../../../l10n/labels.dart';
import '../../../domain/models/deck.dart';
import '../../../shared/widgets/common.dart';
import '../deck_providers.dart';

/// Deck analysis: legality, curve and colour balance.
class DeckStatsTab extends ConsumerWidget {
  const DeckStatsTab({super.key, required this.revisionId});

  final int revisionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final composition = ref.watch(compositionProvider(revisionId));

    return composition.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => EmptyState(
        icon: Icons.error_outline,
        title: context.l10n.statsLoadError,
        message: '$error',
      ),
      data: (deck) => deck.allEntries.isEmpty
          ? EmptyState(
              icon: Icons.insights_outlined,
              title: context.l10n.statsEmptyTitle,
              message: context.l10n.statsEmptyMessage,
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                _LegalityCard(deck: deck),
                const SizedBox(height: 16),
                _CategoryCounts(deck: deck),
                const SizedBox(height: 16),
                _ChartCard(
                  title: context.l10n.statsCurveTitle,
                  subtitle: context.l10n.statsCurveSubtitle,
                  child: _BinChart(bins: _costBins(deck.costCurve)),
                ),
                const SizedBox(height: 16),
                _ChartCard(
                  title: context.l10n.statsLevelTitle,
                  subtitle: context.l10n.statsLevelSubtitle,
                  child: _BinChart(
                    bins: [
                      for (var level = 2; level <= 7; level++)
                        (label: '$level', value: deck.levelSpread[level] ?? 0),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _ChartCard(
                  title: context.l10n.statsColorTitle,
                  subtitle: context.l10n.statsColorSubtitle,
                  child: _ColorBreakdown(spread: deck.colorSpread),
                ),
              ],
            ),
    );
  }

  /// Bins for the cost chart, spanning only the range the deck actually uses
  /// so a 0-20 axis does not squash a curve that lives between 2 and 7.
  static List<({String label, int value})> _costBins(Map<int, int> curve) {
    if (curve.isEmpty) return const [];
    final costs = curve.keys.toList()..sort();
    final max = costs.last;
    return [
      for (var cost = 0; cost <= max; cost++)
        (label: '$cost', value: curve[cost] ?? 0),
    ];
  }
}

class _LegalityCard extends StatelessWidget {
  const _LegalityCard({required this.deck});

  final DeckComposition deck;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final issues = deck.issues;
    final legal = deck.isLegal;
    final accent = legal ? DigimonColors.green : scheme.error;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppSurfaces.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: legal
              ? DigimonColors.green.withValues(alpha: 0.4)
              : AppSurfaces.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                legal ? Icons.verified_rounded : Icons.rule_rounded,
                size: 18,
                color: accent,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  legal ? context.l10n.statsLegal : context.l10n.statsNotLegal,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                context.l10n.statsDeckCounts(
                  deck.mainDeckCount,
                  DeckRules.mainDeckSize,
                  deck.eggDeckCount,
                  DeckRules.maxEggDeckSize,
                ),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          if (issues.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final issue in issues)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      issue.severity == DeckIssueSeverity.error
                          ? Icons.error_outline
                          : Icons.info_outline,
                      size: 14,
                      color: issue.severity == DeckIssueSeverity.error
                          ? scheme.error
                          : scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        describeIssue(issue, context.l10n),
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _CategoryCounts extends StatelessWidget {
  const _CategoryCounts({required this.deck});

  final DeckComposition deck;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (final category in CardCategory.values)
          Expanded(
            child: Container(
              margin: EdgeInsets.only(
                right: category == CardCategory.values.last ? 0 : 8,
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: AppSurfaces.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppSurfaces.outline),
              ),
              child: Column(
                children: [
                  Text(
                    '${deck.countOfCategory(category)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category.name(context.l10n),
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: AppSurfaces.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppSurfaces.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

/// A single-series column chart over ordered bins.
///
/// One hue rather than a colour per bar: the bars measure magnitude, and in
/// this app a colour already means a card colour, so colouring bars by bin
/// would read as a claim the data does not make.
class _BinChart extends StatelessWidget {
  const _BinChart({required this.bins});

  final List<({String label, int value})> bins;

  static const _barHeight = 96.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    if (bins.isEmpty) {
      return Text(
        context.l10n.statsNoCosts,
        style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
      );
    }

    final max = bins.map((b) => b.value).reduce((a, b) => a > b ? a : b);
    return Column(
      children: [
        SizedBox(
          height: _barHeight + 18,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final bin in bins)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Only non-empty bars are labelled; a row of zeroes
                        // adds noise without adding information.
                        Text(
                          bin.value == 0 ? '' : '${bin.value}',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          height: max == 0
                              ? 2
                              : (bin.value / max * _barHeight).clamp(
                                  bin.value == 0 ? 2 : 6,
                                  _barHeight,
                                ),
                          decoration: BoxDecoration(
                            color: bin.value == 0
                                ? AppSurfaces.outline
                                : scheme.primary,
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        // Baseline, drawn as a recessive rule rather than a full grid.
        const Divider(height: 1),
        const SizedBox(height: 5),
        Row(
          children: [
            for (final bin in bins)
              Expanded(
                child: Text(
                  bin.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Colour counts as labelled rows.
///
/// The seven colours are the game's own and carry meaning, so they are used
/// directly — but every row is named in text as well, so the reading never
/// depends on telling two hues apart.
class _ColorBreakdown extends StatelessWidget {
  const _ColorBreakdown({required this.spread});

  final Map<CardColor, int> spread;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final present = CardColor.values
        .where((color) => (spread[color] ?? 0) > 0)
        .toList();
    if (present.isEmpty) {
      return Text(
        context.l10n.statsNoColors,
        style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
      );
    }
    final max = present
        .map((color) => spread[color]!)
        .reduce((a, b) => a > b ? a : b);

    return Column(
      children: [
        for (final color in present)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: DigimonColors.of(color),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                SizedBox(
                  width: 52,
                  child: Text(
                    color.name(context.l10n),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: spread[color]! / max,
                      minHeight: 8,
                      backgroundColor: AppSurfaces.surfaceHigh,
                      valueColor: AlwaysStoppedAnimation(
                        DigimonColors.of(color),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 24,
                  child: Text(
                    '${spread[color]}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
