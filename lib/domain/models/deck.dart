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
    this.thumbnailCardNumber,
    this.revisions = const [],
  });

  final int id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Card number the user pinned as the deck's picture. Null lets the deck
  /// pick its own; see [DeckComposition.thumbnailFor].
  final String? thumbnailCardNumber;

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

/// One block of a deck list, e.g. the Lv.4 Digimon.
class DeckSection {
  const DeckSection({
    required this.title,
    required this.entries,
    this.subtitle,
    this.limit,
  });

  final String title;

  /// Qualifier shown next to [title], e.g. `Lv.4`.
  final String? subtitle;

  final List<DeckEntry> entries;

  /// Copies the rules allow in this block, where there is a ceiling.
  final int? limit;

  String get label => subtitle == null ? title : '$title · $subtitle';

  int get count => entries.fold(0, (sum, e) => sum + e.quantity);
}

/// A revision's cards split into the two decks, with its legality checked
/// against the official rules and the current restriction list.
class DeckComposition {
  DeckComposition(List<DeckEntry> entries)
    : mainDeck = entries.where((e) => !e.card.deckCategory.isEggDeck).toList(),
      eggDeck = entries.where((e) => e.card.deckCategory.isEggDeck).toList();

  final List<DeckEntry> mainDeck;
  final List<DeckEntry> eggDeck;

  int get mainDeckCount => mainDeck.fold(0, (sum, e) => sum + e.quantity);
  int get eggDeckCount => eggDeck.fold(0, (sum, e) => sum + e.quantity);

  DeckEntry? entryOf(String? cardNumber) => cardNumber == null
      ? null
      : allEntries.firstWhereOrNull((e) => e.cardNumber == cardNumber);

  /// The card that stands for the deck in a list: the one the user pinned, or
  /// [signatureCard] when they have not picked one — or when the card they
  /// picked is no longer in the revision being shown.
  DeckEntry? thumbnailFor(String? pinnedCardNumber) =>
      entryOf(pinnedCardNumber) ?? signatureCard;

  /// The card that stands for the deck when the user has not chosen one.
  ///
  /// The deck's biggest Digimon is the one a player names it after, so this
  /// picks the highest level, breaking ties on DP and then cost.
  DeckEntry? get signatureCard {
    if (mainDeck.isEmpty) return eggDeck.firstOrNull;
    return mainDeck.reduce((best, entry) {
      final byLevel = (entry.card.level ?? 0).compareTo(best.card.level ?? 0);
      if (byLevel != 0) return byLevel > 0 ? entry : best;
      final byDp = (entry.card.dp ?? 0).compareTo(best.card.dp ?? 0);
      if (byDp != 0) return byDp > 0 ? entry : best;
      final byCost = (entry.card.cost ?? 0).compareTo(best.card.cost ?? 0);
      return byCost > 0 ? entry : best;
    });
  }

  List<DeckEntry> get allEntries => [...mainDeck, ...eggDeck];

  /// Cards of the given category, in display order. Dual cards are filed
  /// under their Digimon face; see [DigimonCard.deckCategory].
  List<DeckEntry> entriesOfCategory(CardCategory category) =>
      allEntries.where((e) => e.card.deckCategory == category).toList()
        ..sort(_byCostThenNumber);

  int countOfCategory(CardCategory category) => allEntries
      .where((e) => e.card.deckCategory == category)
      .fold(0, (sum, e) => sum + e.quantity);

  /// The revision split into the blocks a deck list is written in: Digi-Eggs
  /// first, then Digimon a level at a time, then Tamers and Options.
  ///
  /// This is the order a player reads and counts a list in — the egg deck is
  /// its own deck, and the Digimon are checked level by level because that is
  /// what the digivolution curve is made of. Empty blocks are left out.
  List<DeckSection> get sections {
    final digimonByLevel = <int, List<DeckEntry>>{};
    final levellessDigimon = <DeckEntry>[];
    for (final entry in entriesOfCategory(CardCategory.digimon)) {
      final level = entry.card.level;
      if (level == null) {
        levellessDigimon.add(entry);
      } else {
        digimonByLevel.putIfAbsent(level, () => []).add(entry);
      }
    }

    return [
      DeckSection(
        title: 'Digi-Eggs',
        subtitle: 'Lv.2',
        entries: eggDeck.sorted(_byCostThenNumber),
        limit: DeckRules.maxEggDeckSize,
      ),
      for (final level in digimonByLevel.keys.sorted((a, b) => a.compareTo(b)))
        DeckSection(
          title: 'Digimon',
          subtitle: 'Lv.$level',
          entries: digimonByLevel[level]!,
        ),
      DeckSection(title: 'Digimon', entries: levellessDigimon),
      DeckSection(
        title: 'Tamers',
        entries: entriesOfCategory(CardCategory.tamer),
      ),
      DeckSection(
        title: 'Options',
        entries: entriesOfCategory(CardCategory.option),
      ),
    ].where((section) => section.entries.isNotEmpty).toList();
  }

  /// Cheapest first, then by card number, which is how a printed list runs.
  static int _byCostThenNumber(DeckEntry a, DeckEntry b) =>
      switch ((a.card.cost ?? 99).compareTo(b.card.cost ?? 99)) {
        0 => a.card.number.compareTo(b.card.number),
        final other => other,
      };

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

    issues.addAll(_pairBanIssues);

    // Decks built before tokens were blocked can still hold one.
    for (final entry in allEntries.where((e) => e.card.isToken)) {
      issues.add(
        DeckIssue(
          DeckIssueSeverity.error,
          '${entry.card.name} (${entry.cardNumber}) is a token. Tokens are '
          'created during play and cannot be part of a deck.',
        ),
      );
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

  /// The cards already in the deck that [card] may not share it with.
  ///
  /// Checked both ways round, because the ruling is recorded on one of the two
  /// cards and either of them can be the one being added.
  List<DeckEntry> pairConflictsWith(DigimonCard card) {
    final banned = card.bannedWith;
    return [
      for (final entry in allEntries)
        if (entry.cardNumber != card.number &&
            (banned.contains(entry.cardNumber) ||
                entry.card.bannedWith.contains(card.number)))
          entry,
    ];
  }

  /// Errors for the cards the restriction list forbids sharing a deck.
  ///
  /// The ruling is published on one of the two cards and names the other, so
  /// walking the deck once from the card that carries the entry is enough to
  /// find every clash — the other side has nothing to say.
  List<DeckIssue> get _pairBanIssues {
    final byNumber = {for (final entry in allEntries) entry.cardNumber: entry};
    final issues = <DeckIssue>[];
    final reported = <String>{};

    for (final entry in allEntries) {
      for (final ban in entry.card.pairBans) {
        for (final number in ban.pairedCardNumbers) {
          final partner = byNumber[number];
          if (partner == null) continue;
          // Should the list ever write the ruling on both cards, the pair is
          // still one problem and belongs in the list once.
          final pair = ([entry.cardNumber, number]..sort()).join('|');
          if (!reported.add(pair)) continue;
          issues.add(
            DeckIssue(
              DeckIssueSeverity.error,
              '${entry.card.name} (${entry.cardNumber}) and '
              '${partner.card.name} ($number) are a banned pair; a deck may '
              'run either one, not both.',
            ),
          );
        }
      }
    }
    return issues;
  }

  bool get isLegal => !issues.any((i) => i.severity == DeckIssueSeverity.error);

  static String _cardWord(int count) => count == 1 ? 'card' : 'cards';

  static String _copyWord(int count) => count == 1 ? 'copy' : 'copies';
}
