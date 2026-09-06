import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../data/db/daos/release_dao.dart';
import '../../domain/models/card_enums.dart';
import '../../domain/models/card_filter.dart';
import '../../domain/models/card_release.dart';
import '../../domain/models/digimon_card.dart';

/// Expansions grouped into the library's sections.
final releaseSectionsProvider = FutureProvider<List<ReleaseSection>>(
  (ref) => ref.watch(releaseDaoProvider).sections(),
);

/// Stand-in artwork for the releases whose own product photo cannot represent
/// them, keyed by release id.
///
/// Deliberately its own provider rather than part of [releaseSectionsProvider]:
/// the expansion list paints as soon as the releases arrive, and the tiles
/// that need a card fill themselves in when this resolves a moment later.
/// Holding the whole list back for them would trade a visible list for a
/// spinner.
final releaseCardArtProvider = FutureProvider<Map<String, String>>((ref) async {
  final sections = await ref.watch(releaseSectionsProvider.future);
  final wanted = [
    for (final section in sections)
      for (final release in section.releases)
        if (needsCardArt(release)) release,
  ];
  return ref.watch(cardDaoProvider).representativeCardImages(
    {for (final release in wanted) release.id},
    prefersNewestPromo: (id) =>
        wanted.firstWhere((r) => r.id == id).group == ReleaseGroup.promo,
  );
});

final releaseProvider = FutureProvider.family<CardRelease?, String>(
  (ref, id) => ref.watch(releaseDaoProvider).releaseById(id),
);

/// Cards printed in one expansion.
final releaseCardsProvider = FutureProvider.autoDispose
    .family<List<DigimonCard>, ReleaseCardsRequest>((ref, request) async {
      final cards = await ref
          .watch(cardDaoProvider)
          .cardsInRelease(
            request.releaseId,
            includeAlternateArts: request.includeAlternateArts,
            promosOnly: request.promosOnly,
          );
      // The reprints a product bundles are sorted to the end, so opening a set
      // starts at its own first card rather than at somebody else's.
      return withOwnCardsFirst(
        cards,
        await ref.watch(releaseProvider(request.releaseId).future),
      );
    });

class ReleaseCardsRequest {
  const ReleaseCardsRequest(
    this.releaseId, {
    this.includeAlternateArts = false,
    this.promosOnly = false,
  });

  final String releaseId;
  final bool includeAlternateArts;

  /// Drops everything without a `P-` number, which is how a promo product is
  /// reduced to the promos it is looked up for.
  final bool promosOnly;

  @override
  bool operator ==(Object other) =>
      other is ReleaseCardsRequest &&
      other.releaseId == releaseId &&
      other.includeAlternateArts == includeAlternateArts &&
      other.promosOnly == promosOnly;

  @override
  int get hashCode => Object.hash(releaseId, includeAlternateArts, promosOnly);
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

/// What a search is being run for.
///
/// The filter itself is shared between the library and the deck builder on
/// purpose — a player who has just narrowed the library to "red Lv.4" expects
/// the same view when they go to add those cards — but the deck builder must
/// never offer a card that cannot go in a deck, so it runs the shared filter
/// with its own rules applied on top.
enum CardSearchScope {
  library,
  deckBuilder;

  /// [filter] as this scope has to run it.
  CardFilter apply(CardFilter filter) => switch (this) {
    CardSearchScope.library => filter,
    CardSearchScope.deckBuilder => filter.copyWith(tokens: TokenMode.exclude),
  };
}

/// The current filter for one search context.
///
/// The library and the deck builder keep separate filters. They used to share
/// one, on the theory that narrowing the library to "red Lv.4" and then going
/// to add those cards meant the same thing — but in practice a search is a
/// throwaway act, and finding a card and then opening a deck should not leave
/// the deck builder still filtered to it.
class CardFilterNotifier extends FamilyNotifier<CardFilter, CardSearchScope> {
  @override
  CardFilter build(CardSearchScope scope) => const CardFilter();

  void update(CardFilter filter) => state = filter;

  void setQuery(String query) => state = state.copyWith(query: query);

  void clearFacets() => state = state.clearedFacets();

  void reset() => state = const CardFilter();
}

final cardFilterProvider =
    NotifierProvider.family<CardFilterNotifier, CardFilter, CardSearchScope>(
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
class CardSearchNotifier
    extends FamilyAsyncNotifier<CardSearchState, CardSearchScope> {
  static const pageSize = 60;

  @override
  Future<CardSearchState> build(CardSearchScope scope) async {
    final filter = scope.apply(ref.watch(cardFilterProvider(scope)));
    final dao = ref.watch(cardDaoProvider);
    final total = await dao.count(filter);
    final cards = await dao.search(filter, limit: pageSize);
    return CardSearchState(cards: cards, total: total);
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || !current.hasMore || current.isLoadingMore) return;

    state = AsyncData(current.copyWith(isLoadingMore: true));
    final filter = arg.apply(ref.read(cardFilterProvider(arg)));
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
    AsyncNotifierProvider.family<
      CardSearchNotifier,
      CardSearchState,
      CardSearchScope
    >(CardSearchNotifier.new);
