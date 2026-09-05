import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/db/daos/release_dao.dart';
import '../../domain/models/card_filter.dart';
import '../../domain/models/card_release.dart';
import '../../domain/models/digimon_card.dart';

/// Expansions grouped into the library's sections.
final releaseSectionsProvider = FutureProvider<List<ReleaseSection>>(
  (ref) => ref.watch(releaseDaoProvider).sections(),
);

final releaseProvider = FutureProvider.family<CardRelease?, String>(
  (ref, id) => ref.watch(releaseDaoProvider).releaseById(id),
);

/// Cards printed in one expansion.
final releaseCardsProvider = FutureProvider.autoDispose
    .family<List<DigimonCard>, ReleaseCardsRequest>(
      (ref, request) => ref
          .watch(cardDaoProvider)
          .cardsInRelease(
            request.releaseId,
            includeAlternateArts: request.includeAlternateArts,
          ),
    );

class ReleaseCardsRequest {
  const ReleaseCardsRequest(
    this.releaseId, {
    this.includeAlternateArts = false,
  });

  final String releaseId;
  final bool includeAlternateArts;

  @override
  bool operator ==(Object other) =>
      other is ReleaseCardsRequest &&
      other.releaseId == releaseId &&
      other.includeAlternateArts == includeAlternateArts;

  @override
  int get hashCode => Object.hash(releaseId, includeAlternateArts);
}

/// Every printing of one card number, base art first.
final cardPrintingsProvider = FutureProvider.autoDispose
    .family<List<DigimonCard>, String>(
      (ref, number) => ref.watch(cardDaoProvider).printingsOfNumber(number),
    );

final cardProvider = FutureProvider.autoDispose.family<DigimonCard?, String>(
  (ref, id) => ref.watch(cardDaoProvider).cardById(id),
);

/// Values that actually occur in the card data, used to populate the filter
/// sheet rather than hard-coding lists that drift out of date with new sets.
final traitOptionsProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(cardDaoProvider).distinctTraits(),
);

final keywordOptionsProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(cardDaoProvider).distinctKeywords(),
);

final rarityOptionsProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(cardDaoProvider).distinctRarities(),
);

final formOptionsProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(cardDaoProvider).distinctForms(),
);

final attributeOptionsProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(cardDaoProvider).distinctAttributes(),
);

/// The search screen's current filter.
class CardFilterNotifier extends Notifier<CardFilter> {
  @override
  CardFilter build() => const CardFilter();

  void update(CardFilter filter) => state = filter;

  void setQuery(String query) => state = state.copyWith(query: query);

  void clearFacets() => state = state.clearedFacets();

  void reset() => state = const CardFilter();
}

final cardFilterProvider = NotifierProvider<CardFilterNotifier, CardFilter>(
  CardFilterNotifier.new,
);

/// A page of search results plus the total the filter matches.
class CardSearchState {
  const CardSearchState({
    required this.cards,
    required this.total,
    this.isLoadingMore = false,
  });

  final List<DigimonCard> cards;
  final int total;
  final bool isLoadingMore;

  bool get hasMore => cards.length < total;

  CardSearchState copyWith({
    List<DigimonCard>? cards,
    int? total,
    bool? isLoadingMore,
  }) => CardSearchState(
    cards: cards ?? this.cards,
    total: total ?? this.total,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
  );
}

/// Runs the current filter against the local database, one page at a time.
class CardSearchNotifier extends AsyncNotifier<CardSearchState> {
  static const pageSize = 60;

  @override
  Future<CardSearchState> build() async {
    final filter = ref.watch(cardFilterProvider);
    final dao = ref.watch(cardDaoProvider);
    final total = await dao.count(filter);
    final cards = await dao.search(filter, limit: pageSize);
    return CardSearchState(cards: cards, total: total);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final filter = ref.read(cardFilterProvider);
    final next = await ref
        .read(cardDaoProvider)
        .search(filter, limit: pageSize, offset: current.cards.length);

    // The filter may have changed while the page was loading; if it did, the
    // rebuild already replaced the state and this page no longer applies.
    final latest = state.valueOrNull;
    if (latest == null || latest.cards.length != current.cards.length) return;
    state = AsyncData(
      latest.copyWith(cards: [...latest.cards, ...next], isLoadingMore: false),
    );
  }
}

final cardSearchProvider =
    AsyncNotifierProvider<CardSearchNotifier, CardSearchState>(
      CardSearchNotifier.new,
    );
