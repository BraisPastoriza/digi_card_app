import 'digimon_card.dart';

/// One card a deck may not run alongside another, as the restriction list has
/// it, seen from one of the two sides.
class PairRestriction {
  const PairRestriction({
    required this.partnerNumber,
    this.partnerName,
    this.date,
    this.note,
  });

  /// The card that may not share the deck.
  final String partnerNumber;

  /// Its printed name, when the library has the card. A ruling can name a
  /// card the device has not downloaded yet, and the number alone still says
  /// which one it is.
  final String? partnerName;

  final String? date;

  /// Bandai's explanation, written about the pairing rather than about either
  /// card, so both sides show the same text.
  final String? note;

  String get partnerLabel =>
      partnerName == null ? partnerNumber : '$partnerName ($partnerNumber)';
}

/// Answers "what can this card not be played with?" from either side of a
/// pairing.
///
/// The restriction list records a banned pair once, on the card the ruling is
/// written about, naming the cards banned alongside it. Read straight off a
/// card that only works in one direction: EX2-007 Mother D-Reaper knows about
/// EX7-064 Shoto Kazama, and Shoto knows nothing at all. This turns the
/// handful of entries in the library into a lookup that works both ways.
class PairRestrictions {
  const PairRestrictions(this._byNumber);

  const PairRestrictions.empty() : _byNumber = const {};

  /// Builds the lookup from the cards carrying banned-pair entries.
  ///
  /// [namesByNumber] supplies the printed names, including for the partner
  /// cards, which carry no entry of their own.
  factory PairRestrictions.from(
    Iterable<DigimonCard> cards, {
    Map<String, String> namesByNumber = const {},
  }) {
    final byNumber = <String, List<PairRestriction>>{};

    void add(String number, PairRestriction restriction) {
      final existing = byNumber.putIfAbsent(number, () => []);
      if (existing.any((r) => r.partnerNumber == restriction.partnerNumber)) {
        return;
      }
      existing.add(restriction);
    }

    for (final card in cards) {
      for (final ban in card.pairBans) {
        for (final partner in ban.pairedCardNumbers) {
          if (partner == card.number) continue;
          add(
            card.number,
            PairRestriction(
              partnerNumber: partner,
              partnerName: namesByNumber[partner],
              date: ban.date,
              note: ban.note,
            ),
          );
          add(
            partner,
            PairRestriction(
              partnerNumber: card.number,
              partnerName: namesByNumber[card.number] ?? card.name,
              date: ban.date,
              note: ban.note,
            ),
          );
        }
      }
    }

    return PairRestrictions(byNumber);
  }

  final Map<String, List<PairRestriction>> _byNumber;

  /// What [number] may not share a deck with, empty when it is free to pair
  /// with anything.
  List<PairRestriction> forNumber(String number) =>
      _byNumber[number] ?? const [];

  bool get isEmpty => _byNumber.isEmpty;
}
