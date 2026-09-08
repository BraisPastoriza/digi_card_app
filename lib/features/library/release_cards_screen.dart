import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/navigation.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/card_enums.dart';
import '../../domain/models/card_release.dart';
import '../../shared/widgets/common.dart';
import 'library_providers.dart';
import 'preview_providers.dart';
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
  void initState() {
    super.initState();
    // Opening a preview set is the moment its data matters, so it is checked
    // then rather than only when the user thinks to pull down. Stale sets
    // only; this is a no-op the rest of the time.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(ref.read(previewRefreshProvider.notifier).refreshIfStale());
      }
    });
  }

  /// Re-reads this set from the secondary source and says what came of it.
  Future<void> _refreshPreview() async {
    final changed = await ref
        .read(previewRefreshProvider.notifier)
        .refresh(releaseId: widget.releaseId);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            changed.isEmpty
                ? 'No new cards — this set is as complete as $secondarySourceName has it.'
                : 'Updated from $secondarySourceName.',
          ),
        ),
      );
  }

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

    final isPreview = release?.isPreview ?? false;
    final body = CustomScrollView(
      // A preview set with few enough cards to fit the screen still has to be
      // draggable, or there is nothing to pull down on.
      physics: isPreview
          ? const AlwaysScrollableScrollPhysics()
          : const ScrollPhysics(),
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(
            release?.displayName ?? 'Expansion',
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (isPreview)
          SliverToBoxAdapter(
            child: _PreviewNotice(
              source: release!.dataSource!,
              refresh: ref.watch(previewRefreshProvider),
            ),
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
                      message: 'The card list may not have been published yet.',
                    ),
                  ),
                ]
              : [
                  SliverCardGrid(
                    cards: cards,
                    onCardTap: (card) =>
                        context.pushOnce('/card/${card.number}'),
                  ),
                ],
        ),
      ],
    );

    return Scaffold(
      // Pull-to-refresh only where there is something to pull for. Every other
      // release is a finished, published product: its card list cannot change
      // without a full card-database update, which lives in the library's
      // database sheet.
      body: isPreview
          ? RefreshIndicator(onRefresh: _refreshPreview, child: body)
          : body,
    );
  }
}

/// Says where a not-yet-published set's data came from, and that it is still
/// moving. Shown at the top of the set rather than tucked into a credits
/// screen, because it changes how much the reader should trust the page.
class _PreviewNotice extends StatelessWidget {
  const _PreviewNotice({required this.source, required this.refresh});

  final String source;
  final PreviewRefreshState refresh;

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
              'are not available. Pull down to check for newly revealed cards.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          if (refresh.isRefreshing) ...[
            const SizedBox(width: 10),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: scheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
