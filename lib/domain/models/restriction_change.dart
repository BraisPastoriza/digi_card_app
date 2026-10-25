/// One difference between the restriction list before a card sync and after.
sealed class RestrictionChange {
  const RestrictionChange({required this.cardNumber, required this.cardName});

  final String cardNumber;
  final String cardName;
}

/// A card now allowed more or fewer copies than before.
class LimitChange extends RestrictionChange {
  const LimitChange({
    required super.cardNumber,
    required super.cardName,
    required this.oldLimit,
    required this.newLimit,
  });

  final int oldLimit;
  final int newLimit;

  bool get isTighter => newLimit < oldLimit;
}

/// Two cards that may no longer share a deck, or may again.
class PairChange extends RestrictionChange {
  const PairChange({
    required super.cardNumber,
    required super.cardName,
    required this.partnerNumber,
    required this.partnerName,
    required this.banned,
  });

  final String partnerNumber;
  final String partnerName;

  /// True when the pairing was banned; false when it was lifted.
  final bool banned;
}

/// The restriction list as it stands at one moment: how many copies each card
/// may be run at, and which cards may not share a deck.
class RestrictionSnapshot {
  const RestrictionSnapshot({
    required this.limits,
    required this.pairs,
    required this.names,
  });

  /// Copies allowed, by card number, for every card in the library.
  final Map<String, int> limits;

  /// Banned pairings, each written smaller number first so the same pairing
  /// recorded from either side counts once.
  final Set<(String, String)> pairs;

  /// Printed names by card number.
  final Map<String, String> names;

  bool get isEmpty => limits.isEmpty;

  static (String, String) pair(String a, String b) =>
      a.compareTo(b) <= 0 ? (a, b) : (b, a);

  /// What changed between [this], the list before a sync, and [after].
  ///
  /// Only cards the library had both times are compared: a card that arrived
  /// with this sync was never playable at any other limit, so its restriction
  /// is not news, just the card.
  List<RestrictionChange> changesTo(RestrictionSnapshot after) {
    String name(String number) =>
        after.names[number] ?? names[number] ?? number;
    bool known(String number) =>
        limits.containsKey(number) && after.limits.containsKey(number);

    final changes = <RestrictionChange>[
      for (final MapEntry(key: number, value: newLimit) in after.limits.entries)
        if (limits[number] case final oldLimit? when oldLimit != newLimit)
          LimitChange(
            cardNumber: number,
            cardName: name(number),
            oldLimit: oldLimit,
            newLimit: newLimit,
          ),
    ];
    for (final (a, b) in after.pairs.difference(pairs)) {
      if (!known(a) || !known(b)) continue;
      changes.add(
        PairChange(
          cardNumber: a,
          cardName: name(a),
          partnerNumber: b,
          partnerName: name(b),
          banned: true,
        ),
      );
    }
    for (final (a, b) in pairs.difference(after.pairs)) {
      if (!known(a) || !known(b)) continue;
      changes.add(
        PairChange(
          cardNumber: a,
          cardName: name(a),
          partnerNumber: b,
          partnerName: name(b),
          banned: false,
        ),
      );
    }
    return changes;
  }
}

/// What one change means for one deck.
class DeckRestrictionImpact {
  const DeckRestrictionImpact({required this.change, required this.copies});

  final RestrictionChange change;

  /// Copies of the change's card the deck runs.
  final int copies;

  /// Whether the change leaves the deck illegal where it was not, rather than
  /// freeing up something it was held back by.
  bool get breaksDeck => switch (change) {
    LimitChange(:final isTighter) => isTighter,
    PairChange(:final banned) => banned,
  };
}

/// The changes that matter to a deck holding [quantities] — copies by card
/// number.
///
/// A tighter limit matters when the deck runs more copies than it now may; a
/// looser one when the deck was already at the old cap, so it could now run
/// more. A pairing matters when the deck runs both cards. Everything else on
/// the list is somebody else's deck.
List<DeckRestrictionImpact> impactOn(
  Map<String, int> quantities,
  List<RestrictionChange> changes,
) => [
  for (final change in changes)
    if (quantities[change.cardNumber] case final copies?)
      if (switch (change) {
        LimitChange(:final isTighter, :final newLimit, :final oldLimit) =>
          isTighter ? copies > newLimit : copies >= oldLimit,
        PairChange(:final partnerNumber) => quantities.containsKey(
          partnerNumber,
        ),
      })
        DeckRestrictionImpact(change: change, copies: copies),
];
