import 'digimon_card.dart';

/// A named list of cards the user keeps at hand while building decks.
///
/// Unlike a deck, a list holds each card once and carries no rules: it is
/// read, not played. The deck builder shows one as a source of cards to add,
/// and the copies land in the deck rather than in the list.
class StapleList {
  const StapleList({
    required this.id,
    required this.name,
    required this.sortIndex,
    this.cardNumbers = const [],
    this.cards = const [],
  });

  final int id;
  final String name;
  final int sortIndex;

  /// Every card number stored in the list, including any the library does not
  /// have — a card from a set that has not been synced still belongs to the
  /// list, it just cannot be shown yet.
  final List<String> cardNumbers;

  /// The cards [cardNumbers] resolves to, in printed-number order.
  final List<DigimonCard> cards;

  /// Cards stored, whether or not the library can resolve them. This is what
  /// the list says about itself, so it does not drop while a sync is pending.
  int get count => cardNumbers.length;

  bool get isEmpty => cardNumbers.isEmpty;

  bool contains(String cardNumber) => cardNumbers.contains(cardNumber);
}
