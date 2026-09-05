import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/deck.dart';
import '../../domain/models/digimon_card.dart';
import '../../shared/widgets/common.dart';
import '../library/library_providers.dart';
import '../../shared/widgets/card_thumbnail.dart';
import '../library/widgets/filter_sheet.dart';
import 'widgets/deck_card_tile.dart';
import 'deck_providers.dart';

/// Card search wired to a deck revision: tapping a card adds a copy and opens
/// its stepper, and the running deck counts stay visible while browsing.
///
/// It shares the library's filter state deliberately — a player who has just
/// narrowed the library to "red Lv.4" expects the same view when they come to
/// add those cards to a deck.
class DeckCardPickerScreen extends ConsumerStatefulWidget {
  const DeckCardPickerScreen({
    super.key,
    required this.deckId,
    required this.revisionId,
  });

  final int deckId;
  final int revisionId;

  @override
  ConsumerState<DeckCardPickerScreen> createState() =>
      _DeckCardPickerScreenState();
}

class _DeckCardPickerScreenState extends ConsumerState<DeckCardPickerScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  /// Card number whose stepper is open, if any.
  String? _openCard;

  @override
  void initState() {
    super.initState();
    _controller.text = ref.read(cardFilterProvider).query;
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(cardFilterProvider.notifier).setQuery(value);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 600) {
      ref.read(cardSearchProvider.notifier).loadMore();
    }
  }

  /// A card with no copies yet is added by the tap that opens its stepper —
  /// the common case is "add one", and making that two taps would be tedious
  /// across fifty cards.
  void _onCardTap(DigimonCard card) {
    final quantity =
        ref.read(revisionQuantitiesProvider(widget.revisionId))[card.number] ??
        0;
    if (_openCard == card.number) {
      setState(() => _openCard = null);
      return;
    }
    setState(() => _openCard = card.number);
    if (quantity == 0) _adjust(card, 1);
  }

  Future<void> _adjust(DigimonCard card, int delta) async {
    final quantity = await ref
        .read(deckDaoProvider)
        .adjustQuantity(
          revisionId: widget.revisionId,
          card: card,
          delta: delta,
        );
    if (!mounted) return;
    if (delta > 0 && quantity == 0) return;
    if (delta > 0 && quantity >= card.copyLimit) {
      // Silently capping would look like a dropped tap, so say why.
      final limitedBy = card.activeLimitation;
      if (limitedBy != null) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                '${card.name} is ${limitedBy.type.label.toLowerCase()} to '
                '${card.copyLimit} '
                '${card.copyLimit == 1 ? 'copy' : 'copies'}.',
              ),
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(cardFilterProvider);
    final results = ref.watch(cardSearchProvider);
    final quantities = ref.watch(revisionQuantitiesProvider(widget.revisionId));
    final composition = ref
        .watch(compositionProvider(widget.revisionId))
        .valueOrNull;

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
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onChanged: _onQueryChanged,
                      decoration: const InputDecoration(
                        hintText: 'Add cards…',
                        prefixIcon: Icon(Icons.search, size: 20),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton.filledTonal(
                    onPressed: () async {
                      final updated = await showFilterSheet(context, filter);
                      if (updated != null) {
                        ref.read(cardFilterProvider.notifier).update(updated);
                      }
                    },
                    icon: Badge(
                      isLabelVisible: filter.activeFacetCount > 0,
                      label: Text('${filter.activeFacetCount}'),
                      child: const Icon(Icons.tune, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (composition != null) _DeckCounter(composition: composition),
          Expanded(
            child: results.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => EmptyState(
                icon: Icons.error_outline,
                title: 'Search failed',
                message: '$error',
              ),
              data: (state) => state.cards.isEmpty
                  ? EmptyState(
                      icon: Icons.search_off,
                      title: 'No cards found',
                      message: 'Try a different search or clear the filters.',
                      action: filter.activeFacetCount == 0
                          ? null
                          : OutlinedButton(
                              onPressed: () => ref
                                  .read(cardFilterProvider.notifier)
                                  .clearFacets(),
                              child: const Text('Clear filters'),
                            ),
                    )
                  : GestureDetector(
                      // Tapping the background closes an open stepper.
                      onTap: () => setState(() => _openCard = null),
                      behavior: HitTestBehavior.translucent,
                      child: CustomScrollView(
                        controller: _scrollController,
                        slivers: [
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(14, 6, 14, 12),
                            sliver: SliverGrid(
                              gridDelegate:
                                  const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 150,
                                    mainAxisSpacing: 14,
                                    crossAxisSpacing: 12,
                                    childAspectRatio: cardAspectRatio,
                                  ),
                              delegate: SliverChildBuilderDelegate((
                                context,
                                index,
                              ) {
                                final card = state.cards[index];
                                return DeckCardTile(
                                  card: card,
                                  quantity: quantities[card.number] ?? 0,
                                  expanded: _openCard == card.number,
                                  onTap: () => _onCardTap(card),
                                  onAdjust: (delta) => _adjust(card, delta),
                                  onInfo: () =>
                                      context.push('/card/${card.number}'),
                                );
                              }, childCount: state.cards.length),
                            ),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                        ],
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Running totals so the user knows when to stop adding without leaving the
/// picker.
class _DeckCounter extends StatelessWidget {
  const _DeckCounter({required this.composition});

  final DeckComposition composition;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final main = composition.mainDeckCount;
    final eggs = composition.eggDeckCount;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      color: AppSurfaces.surface,
      child: Row(
        children: [
          _Counter(
            label: 'Main deck',
            current: main,
            total: DeckRules.mainDeckSize,
            complete: main == DeckRules.mainDeckSize,
          ),
          const SizedBox(width: 20),
          _Counter(
            label: 'Egg deck',
            current: eggs,
            total: DeckRules.maxEggDeckSize,
            complete: eggs <= DeckRules.maxEggDeckSize,
          ),
          const Spacer(),
          Text(
            'Tap a card to set copies',
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({
    required this.label,
    required this.current,
    required this.total,
    required this.complete,
  });

  final String label;
  final int current;
  final int total;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          '$current',
          style: TextStyle(
            fontSize: 16,
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
