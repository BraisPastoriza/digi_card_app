import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router/navigation.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/digimon_card.dart';
import '../../shared/widgets/card_thumbnail.dart';
import '../../shared/widgets/common.dart';
import '../library/library_providers.dart';
import '../../l10n/l10n.dart';
import '../library/widgets/filter_sheet.dart';
import 'staple_providers.dart';

/// Card search wired to a staple list: tapping a card puts it in the list or
/// takes it out, and what is already in stays marked while you browse.
class StapleCardPickerScreen extends ConsumerStatefulWidget {
  const StapleCardPickerScreen({super.key, required this.listId});

  final int listId;

  @override
  ConsumerState<StapleCardPickerScreen> createState() =>
      _StapleCardPickerScreenState();
}

class _StapleCardPickerScreenState
    extends ConsumerState<StapleCardPickerScreen> {
  static const _scope = CardSearchScope.staples;

  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    // A search is a throwaway act: coming back starts fresh rather than on
    // top of whatever was last looked up.
    ref.invalidate(cardFilterProvider(_scope));
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      ref.read(cardFilterProvider(_scope).notifier).setQuery(value);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 600) {
      ref.read(cardSearchProvider(_scope).notifier).loadMore();
    }
  }

  Future<void> _toggle(DigimonCard card) async {
    final added = await ref
        .read(stapleDaoProvider)
        .toggleCard(widget.listId, card.number);
    if (!mounted) return;
    // The tick on the tile says what happened for the card just tapped; the
    // message is there for the one taken out by accident.
    if (!added) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.l10n.stapleRemoved(card.name)),
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(cardFilterProvider(_scope));
    final results = ref.watch(cardSearchProvider(_scope));
    final list = ref.watch(stapleListProvider(widget.listId));
    final inList = list?.cardNumbers.toSet() ?? const <String>{};
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
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.search,
                      onChanged: _onQueryChanged,
                      decoration: InputDecoration(
                        hintText: context.l10n.staplePickerHint,
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
                        ref
                            .read(cardFilterProvider(_scope).notifier)
                            .update(updated);
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
            color: AppSurfaces.surface,
            child: Row(
              children: [
                Text(
                  list == null
                      ? ''
                      : context.l10n.staplePickerSummary(
                          list.name,
                          list.count,
                        ),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  context.l10n.staplePickerTapHint,
                  style: TextStyle(
                    fontSize: 11,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
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
                      message: context.l10n.pickerNoCardsFiltered,
                    )
                  : CustomScrollView(
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
                              return _PickableCard(
                                card: card,
                                inList: inList.contains(card.number),
                                onTap: () => _toggle(card),
                                onInfo: () =>
                                    context.pushOnce('/card/${card.number}'),
                              );
                            }, childCount: state.cards.length),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A search result, marked when the list already holds it.
class _PickableCard extends StatelessWidget {
  const _PickableCard({
    required this.card,
    required this.inList,
    required this.onTap,
    required this.onInfo,
  });

  final DigimonCard card;
  final bool inList;
  final VoidCallback onTap;
  final VoidCallback onInfo;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onInfo,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              // Cards already in the list stay legible but stop competing for
              // attention with the ones still to pick.
              opacity: inList ? 0.55 : 1,
              child: CardThumbnail(card: card),
            ),
          ),
          if (inList)
            Positioned(
              top: 3,
              right: 3,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: scheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.check, size: 14, color: scheme.onPrimary),
              ),
            ),
        ],
      ),
    );
  }
}
