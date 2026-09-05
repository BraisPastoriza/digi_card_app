import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final release = ref.watch(releaseProvider(widget.releaseId)).valueOrNull;
    final cards = ref.watch(
      releaseCardsProvider(
        ReleaseCardsRequest(
          widget.releaseId,
          includeAlternateArts: _includeAlternateArts,
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
            actions: [
              IconButton(
                tooltip: _includeAlternateArts
                    ? 'Hide alternate arts'
                    : 'Show alternate arts',
                onPressed: () => setState(
                  () => _includeAlternateArts = !_includeAlternateArts,
                ),
                icon: Icon(
                  _includeAlternateArts
                      ? Icons.filter_none
                      : Icons.filter_none_outlined,
                  color: _includeAlternateArts ? scheme.primary : null,
                ),
              ),
            ],
          ),
          if (release != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    if (release.setCode != null) ...[
                      MetaBadge(release.setCode!, color: scheme.primary),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      [
                        cards.valueOrNull == null
                            ? '${release.cardCount} cards'
                            : '${cards.valueOrNull!.length} cards',
                        if (release.date != null) release.date!,
                      ].join(' · '),
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
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
                      onCardTap: (card) =>
                          context.push('/card/${card.number}'),
                    ),
                  ],
          ),
        ],
      ),
    );
  }
}
