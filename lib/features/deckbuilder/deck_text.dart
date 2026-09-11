import '../../domain/models/deck.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';

/// Puts what the rules found wrong with a deck into the reader's language.
///
/// The check itself is in [DeckComposition.issues], which deals in cards and
/// counts; this is the only place that turns one into a sentence.
String describeIssue(DeckIssue issue, AppLocalizations l10n) => switch (issue) {
  MainDeckSizeIssue(:final difference) when difference > 0 =>
    l10n.issueMainDeckShort(difference, DeckRules.mainDeckSize),
  MainDeckSizeIssue(:final difference) => l10n.issueMainDeckOver(
    -difference,
    DeckRules.mainDeckSize,
  ),
  EggDeckSizeIssue(:final excess) => l10n.issueEggDeckOver(
    excess,
    DeckRules.maxEggDeckSize,
  ),
  CopyLimitIssue(:final entry, :final limit, limitation: null) =>
    l10n.issueTooManyCopies(
      entry.card.name,
      entry.cardNumber,
      entry.quantity,
      limit,
    ),
  CopyLimitIssue(:final entry, :final limit, :final limitation?) =>
    l10n.issueTooManyCopiesLimited(
      entry.card.name,
      entry.cardNumber,
      limitation.type.name(l10n).toLowerCase(),
      limit,
      entry.quantity,
    ),
  BannedPairIssue(:final entry, :final partner) => l10n.issueBannedPair(
    entry.card.name,
    entry.cardNumber,
    partner.card.name,
    partner.cardNumber,
  ),
  TokenInDeckIssue(:final entry) => l10n.issueToken(
    entry.card.name,
    entry.cardNumber,
  ),
  EmptyEggDeckIssue() => l10n.issueEmptyEggDeck,
};

/// The heading of one block of a deck list, e.g. "Digimon · Lv.4".
String sectionLabel(DeckSection section, AppLocalizations l10n) {
  final name = switch (section.kind) {
    DeckSectionKind.digiEggs => l10n.sectionDigiEggs,
    DeckSectionKind.digimon => l10n.sectionDigimon,
    DeckSectionKind.tamers => l10n.sectionTamers,
    DeckSectionKind.options => l10n.sectionOptions,
  };
  final level = section.level;
  return level == null ? name : l10n.sectionWithLevel(name, level);
}
