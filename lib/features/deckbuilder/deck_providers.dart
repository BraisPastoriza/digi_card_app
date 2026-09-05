import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/models/deck.dart';

/// All decks, most recently edited first.
final decksProvider = StreamProvider<List<Deck>>(
  (ref) => ref.watch(deckDaoProvider).watchDecks(),
);

final deckProvider = StreamProvider.autoDispose.family<Deck?, int>(
  (ref, deckId) => ref.watch(deckDaoProvider).watchDeck(deckId),
);

/// The cards in one revision, resolved against the library.
final revisionEntriesProvider = StreamProvider.autoDispose
    .family<List<DeckEntry>, int>(
      (ref, revisionId) =>
          ref.watch(deckDaoProvider).watchRevisionEntries(revisionId),
    );

/// A revision's cards split into main and egg decks, with its legality
/// checked. Rebuilt whenever the revision's cards change.
final compositionProvider = Provider.autoDispose
    .family<AsyncValue<DeckComposition>, int>(
      (ref, revisionId) => ref
          .watch(revisionEntriesProvider(revisionId))
          .whenData(DeckComposition.new),
    );

/// Copies of each card number in a revision, so the card picker can show what
/// is already in the deck without resolving every entry again.
final revisionQuantitiesProvider = Provider.autoDispose
    .family<Map<String, int>, int>((ref, revisionId) {
      final entries = ref
          .watch(revisionEntriesProvider(revisionId))
          .valueOrNull;
      if (entries == null) return const {};
      return {for (final entry in entries) entry.cardNumber: entry.quantity};
    });
