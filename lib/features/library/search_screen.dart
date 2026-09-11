import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/navigation.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import 'facets.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/card_filter.dart';
import '../../shared/widgets/common.dart';
import 'library_providers.dart';
import 'widgets/card_grid.dart';
import 'widgets/filter_sheet.dart';

/// Full-text and faceted search across the whole card database.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller.text = ref
        .read(cardFilterProvider(CardSearchScope.library))
        .query;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Cancelled first, so a pending keystroke cannot write the query back
    // after it has been cleared.
    _debounce?.cancel();
    // A search is a throwaway act: leaving this screen clears it, so coming
    // back — or opening the other search — starts fresh rather than on top of
    // whatever was last looked up.
    ref.invalidate(cardFilterProvider(CardSearchScope.library));
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Waits for a pause in typing before querying, so a five-letter name is one
  /// search rather than five.
  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      ref
          .read(cardFilterProvider(CardSearchScope.library).notifier)
          .setQuery(value);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 600) {
      ref.read(cardSearchProvider(CardSearchScope.library).notifier).loadMore();
    }
  }

  Future<void> _openFilters() async {
    final filter = ref.read(cardFilterProvider(CardSearchScope.library));
    final updated = await showFilterSheet(context, filter);
    if (updated != null) {
      ref
          .read(cardFilterProvider(CardSearchScope.library).notifier)
          .update(updated);
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(cardFilterProvider(CardSearchScope.library));
    final results = ref.watch(cardSearchProvider(CardSearchScope.library));
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.goBack('/library'),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      autofocus: filter.isEmpty,
                      textInputAction: TextInputAction.search,
                      onChanged: _onQueryChanged,
                      decoration: InputDecoration(
                        hintText: context.l10n.searchHint,
                        prefixIcon: const Icon(Icons.search, size: 20),
                        suffixIcon: _controller.text.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: () {
                                  _controller.clear();
                                  _onQueryChanged('');
                                  setState(() {});
                                },
                              ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  _FilterButton(
                    count: filter.activeFacetCount,
                    onPressed: _openFilters,
                  ),
                ],
              ),
            ),
          ),
          _ResultsHeader(
            filter: filter,
            total: results.valueOrNull?.total,
            onRemoveFacet: (without) => ref
                .read(cardFilterProvider(CardSearchScope.library).notifier)
                .update(without),
            onClearFacets: () => ref
                .read(cardFilterProvider(CardSearchScope.library).notifier)
                .clearFacets(),
            onSortChanged: (sort) => ref
                .read(cardFilterProvider(CardSearchScope.library).notifier)
                .update(filter.copyWith(sort: sort)),
          ),
          Expanded(
            child: results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline,
                title: context.l10n.searchFailed,
                message: '$error',
              ),
              data: (state) => state.cards.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off,
                      title: context.l10n.searchNoCards,
                      message: filter.activeFacetCount > 0
                          ? context.l10n.searchNoCardsFiltered
                          : context.l10n.searchNoCardsPlain,
                      action: filter.activeFacetCount == 0
                          ? null
                          : OutlinedButton(
                              onPressed: () => ref
                                  .read(
                                    cardFilterProvider(
                                      CardSearchScope.library,
                                    ).notifier,
                                  )
                                  .clearFacets(),
                              child: Text(context.l10n.searchClearFilters),
                            ),
                    )
                  : CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        SliverCardGrid(
                          cards: state.cards,
                          onCardTap: (card) =>
                              context.pushOnce('/card/${card.number}'),
                        ),
                        if (state.hasMore)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                              child: Center(
                                child: Text(
                                  context.l10n.searchEndOfResults,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: scheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.count, required this.onPressed});

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final active = count > 0;
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: active ? scheme.primaryContainer : AppSurfaces.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? scheme.primary : AppSurfaces.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune,
              size: 19,
              color: active ? scheme.primary : scheme.onSurfaceVariant,
            ),
            if (active) ...[
              const SizedBox(width: 6),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: scheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Result count, active facets and the sort control.
class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({
    required this.filter,
    required this.total,
    required this.onRemoveFacet,
    required this.onClearFacets,
    required this.onSortChanged,
  });

  final CardFilter filter;
  final int? total;

  /// Takes one facet off, given the filter left without it.
  final void Function(CardFilter) onRemoveFacet;

  final VoidCallback onClearFacets;
  final void Function(CardSort) onSortChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final facets = activeFacets(filter, context.l10n);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 8, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  total == null
                      ? context.l10n.searchSearching
                      : context.l10n.searchResultCount(total!),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              PopupMenuButton<CardSort>(
                initialValue: filter.sort,
                onSelected: onSortChanged,
                tooltip: context.l10n.searchSortTooltip,
                itemBuilder: (context) => [
                  for (final sort in CardSort.values)
                    PopupMenuItem(
                      value: sort,
                      child: Text(sort.name(context.l10n)),
                    ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.swap_vert,
                        size: 17,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        filter.sort.name(context.l10n),
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (facets.isNotEmpty)
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              children: [
                // Tapping a chip — anywhere on it, not only the cross —
                // takes that facet off, which is where the hand goes when a
                // search turns out too narrow.
                for (final facet in facets)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: InputChip(
                      label: Text(facet.label),
                      visualDensity: VisualDensity.compact,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        color: scheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                      backgroundColor: scheme.primaryContainer,
                      side: BorderSide(
                        color: scheme.primary.withValues(alpha: 0.4),
                      ),
                      onPressed: () => onRemoveFacet(facet.removed),
                      onDeleted: () => onRemoveFacet(facet.removed),
                      deleteIcon: Icon(
                        Icons.close,
                        size: 14,
                        color: scheme.primary,
                      ),
                      tooltip: context.l10n.searchRemoveFacet(facet.label),
                    ),
                  ),
                ActionChip(
                  label: Text(context.l10n.searchClearAll),
                  visualDensity: VisualDensity.compact,
                  labelStyle: const TextStyle(fontSize: 12),
                  avatar: const Icon(Icons.close, size: 14),
                  onPressed: onClearFacets,
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
      ],
    );
  }
}
