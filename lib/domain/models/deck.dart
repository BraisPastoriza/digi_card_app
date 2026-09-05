import 'package:collection/collection.dart';

import 'card_enums.dart';
import 'digimon_card.dart';

/// A deck the user is building. The card list itself lives on its revisions;
/// a deck is the folder that holds them plus the pointer to the one currently
/// being edited.
class Deck {
  const Deck({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.activeRevisionId,
    this.revisions = const [],
  });

  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// The revision the editor opens and writes to.
  final int? activeRevisionId;

  final List<DeckRevision> revisions;

  DeckRevision? get activeRevision =>
      revisions.firstWhereOrNull((r) => r.id == activeRevisionId) ??
      revisions.firstOrNull;
}

/// One named iteration of a deck. Users branch a new revision from the active
/// one to try a change without losing what worked.
class DeckRevision {
  const DeckRevision({
    required this.id,
    required this.deckId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.entries = const [],
  });

  final int id;
  final int deckId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<DeckEntry> entries;
}

/// A stack of identical cards inside a revision.
///
/// Decks reference cards by [DigimonCard.number] because deck legality is
/// counted per number, but they remember which art the user picked so the
/// editor can show it.
class DeckEntry {
  const DeckEntry({
    required this.cardNumber,
    required this.quantity,
    required this.card,
    this.printingId,
  });

  final String cardNumber;
  final int quantity;

  /// The printing whose art is shown. Null means the base printing.
  final String? printingId;

  /// The resolved card, joined from the library at read time.
  final DigimonCard card;

  DeckEntry copyWith({int? quantity, String? printingId, DigimonCard? card}) =>
      DeckEntry(
        cardNumber: cardNumber,
        quantity: quantity ?? this.quantity,
        printingId: printingId ?? this.printingId,
        card: card ?? this.card,
      );
}

/// Deck size limits from the official rules.
abstract final class DeckRules {
  static const mainDeckSize = 50;
  static const maxEggDeckSize = 5;
  static const defaultCopyLimit = 4;
}

/// How severe a rule violation is. Warnings do not stop the user from saving;
/// the deck is simply flagged as not tournament legal.
enum DeckIssueSeverity { error, warning }

class DeckIssue {
  const DeckIssue(this.severity, this.message);

  final DeckIssueSeverity severity;
  final String message;
}

/// A revision's cards split into the two decks, with its legality checked
/// against the official rules and the current restriction list.
class DeckComposition {
  DeckComposition(List<DeckEntry> entries)
    : mainDeck = entries.where((e) => !e.card.category.isEggDeck).toList(),
      eggDeck = entries.where((e) => e.card.category.isEggDeck).toList();

  final List<DeckEntry> mainDeck;
  final List<DeckEntry> eggDeck;

  int get mainDeckCount => mainDeck.fold(0, (sum, e) => sum + e.quantity);
  int get eggDeckCount => eggDeck.fold(0, (sum, e) => sum + e.quantity);

  List<DeckEntry> get allEntries => [...mainDeck, ...eggDeck];

  /// Cards in the main deck of the given category, in display order.
  List<DeckEntry> entriesOfCategory(CardCategory category) =>
      allEntries.where((e) => e.card.category == category).toList()..sort(
        (a, b) => switch ((a.card.cost ?? 99).compareTo(b.card.cost ?? 99)) {
          0 => a.card.number.compareTo(b.card.number),
          final other => other,
        },
      );

  int countOfCategory(CardCategory category) => allEntries
      .where((e) => e.card.category == category)
      .fold(0, (sum, e) => sum + e.quantity);

  /// Copies per colour. A multi-colour card counts once for each of its
  /// colours, which is how players read a colour spread.
  Map<CardColor, int> get colorSpread {
    final spread = <CardColor, int>{};
    for (final entry in allEntries) {
      for (final color in entry.card.colors) {
        spread[color] = (spread[color] ?? 0) + entry.quantity;
      }
    }
    return spread;
  }

  /// Copies per play/use cost across the main deck, for the cost curve.
  Map<int, int> get costCurve {
    final curve = <int, int>{};
    for (final entry in mainDeck) {
      final cost = entry.card.cost;
      if (cost == null) continue;
      curve[cost] = (curve[cost] ?? 0) + entry.quantity;
    }
    return curve;
  }

  /// Copies per level across the main deck.
  Map<int, int> get levelSpread {
    final spread = <int, int>{};
    for (final entry in mainDeck) {
      final level = entry.card.level;
      if (level == null) continue;
      spread[level] = (spread[level] ?? 0) + entry.quantity;
    }
    return spread;
  }

  List<DeckIssue> get issues {
    final issues = <DeckIssue>[];

    if (mainDeckCount != DeckRules.mainDeckSize) {
      final diff = DeckRules.mainDeckSize - mainDeckCount;
      issues.add(
        DeckIssue(
          DeckIssueSeverity.error,
          diff > 0
              ? 'Main deck needs $diff more ${_cardWord(diff)} (${DeckRules.mainDeckSize} required).'
              : 'Main deck is over by ${-diff} ${_cardWord(-diff)} (${DeckRules.mainDeckSize} allowed).',
        ),
      );
    }

    if (eggDeckCount > DeckRules.maxEggDeckSize) {
      issues.add(
        DeckIssue(
          DeckIssueSeverity.error,
          'Egg deck is over by ${eggDeckCount - DeckRules.maxEggDeckSize} '
          '(${DeckRules.maxEggDeckSize} allowed).',
        ),
      );
    }

    for (final entry in allEntries) {
      final limit = entry.card.copyLimit;
      if (entry.quantity > limit) {
        final reason = entry.card.activeLimitation;
        issues.add(
          DeckIssue(
            DeckIssueSeverity.error,
            reason == null
                ? '${entry.card.name} (${entry.cardNumber}): ${entry.quantity} copies, max $limit.'
                : '${entry.card.name} (${entry.cardNumber}) is ${reason.type.label.toLowerCase()} '
                      'to $limit ${_copyWord(limit)}; deck has ${entry.quantity}.',
          ),
        );
      }
    }

    if (eggDeckCount == 0 && mainDeckCount > 0) {
      issues.add(
        const DeckIssue(
          DeckIssueSeverity.warning,
          'Egg deck is empty. Most decks run 4-5 Digi-Eggs.',
        ),
      );
    }

    return issues;
  }

  bool get isLegal =>
      !issues.any((i) => i.severity == DeckIssueSeverity.error);

  static String _cardWord(int count) => count == 1 ? 'card' : 'cards';

  static String _copyWord(int count) => count == 1 ? 'copy' : 'copies';
}
