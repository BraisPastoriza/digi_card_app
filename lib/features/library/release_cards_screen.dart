import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models/card_enums.dart';
import '../../shared/widgets/common.dart';
import 'library_providers.dart';
import 'widgets/card_grid.dart';

/// Every card printed in one expansion.
class ReleaseCardsScreen extends ConsumerStatefulWidget {
  const ReleaseCardsScreen({super.key, required this.releaseId});

  final String releaseId;

  @override
  ConsumerState<ReleaseCardsScreen> createState() => _ReleaseCardsScreenState();
}

class _ReleaseCardsScreenState extends ConsumerState<ReleaseCardsScreen> {
  bool _includeAlternateArts = false;

  /// Promo products bundle alternate arts of ordinary set cards alongside the
  /// promos themselves — Large-Scale Tournaments is 667 cards of which 56 are
  /// promos — so a promo release can be cut down to what it is looked up for.
  bool _promosOnly = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final release = ref.watch(releaseProvider(widget.releaseId)).valueOrNull;
    final cards = ref.watch(
      releaseCardsProvider(
        ReleaseCardsRequest(
          widget.releaseId,
          includeAlternateArts: _includeAlternateArts,
          promosOnly: _promosOnly,
        ),
      ),
    );

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Text(
              release?.displayName ?? 'Expansion',
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (release?.isPreview ?? false)
            SliverToBoxAdapter(
              child: _PreviewNotice(source: release!.dataSource!),
            ),
          if (release != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 12, 8),
                child: Row(
                  children: [
                    if (release.setCode != null) ...[
                      MetaBadge(release.setCode!, color: scheme.primary),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Text(
                        [
                          '${cards.valueOrNull?.length ?? release.cardCount} cards',
                          if (release.date != null) release.date!,
                        ].join(' · '),
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (release.group == ReleaseGroup.promo) ...[
                      FilterChip(
                        label: const Text('Promos only'),
                        labelStyle: const TextStyle(fontSize: 12),
                        visualDensity: VisualDensity.compact,
                        selected: _promosOnly,
                        onSelected: (value) =>
                            setState(() => _promosOnly = value),
                      ),
                      const SizedBox(width: 8),
                    ],
                    // Some products are made almost entirely of alternate
                    // arts, so say how many are hidden rather than tucking the
                    // toggle behind an icon.
                    if (release.printingCount > release.cardCount)
                      FilterChip(
                        label: Text(
                          'Alt arts +${release.printingCount - release.cardCount}',
                        ),
                        labelStyle: const TextStyle(fontSize: 12),
                        visualDensity: VisualDensity.compact,
                        selected: _includeAlternateArts,
                        onSelected: (value) =>
                            setState(() => _includeAlternateArts = value),
                      ),
                  ],
                ),
              ),
            ),
          ...cards.when(
            loading: () => const [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (error, _) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: 'Could not load cards',
                  message: '$error',
                ),
              ),
            ],
            data: (cards) => cards.isEmpty
                ? const [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.style_outlined,
                        title: 'No cards in this expansion',
                        message:
                            'The card list may not have been published yet.',
                      ),
                    ),
                  ]
                : [
                    SliverCardGrid(
                      cards: cards,
                      onCardTap: (card) => context.push('/card/${card.number}'),
                    ),
                  ],
          ),
        ],
      ),
    );
  }
}

/// Says where a not-yet-published set's data came from, and that it is still
/// moving. Shown at the top of the set rather than tucked into a credits
/// screen, because it changes how much the reader should trust the page.
class _PreviewNotice extends StatelessWidget {
  const _PreviewNotice({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppSurfaces.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.science_outlined, size: 16, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Preview set. This expansion is not in the main card database '
              'yet, so its cards come from $source and are still being '
              'corrected. Some may be missing, and rulings and alternate arts '
              'are not available.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
