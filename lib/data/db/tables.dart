import 'package:drift/drift.dart';

/// Delimiter used to store small string lists inline, e.g. `|red|blue|`.
/// Wrapping every value in delimiters lets `LIKE '%|red|%'` match whole values
/// without matching prefixes of other values.
const listDelimiter = '|';

String encodeList(Iterable<String> values) => values.isEmpty
    ? ''
    : '$listDelimiter${values.join(listDelimiter)}$listDelimiter';

List<String> decodeList(String? encoded) {
  if (encoded == null || encoded.isEmpty) return const [];
  return encoded.split(listDelimiter).where((v) => v.isNotEmpty).toList();
}

/// A product release. Mirrors `/releases/en` from the API.
@DataClassName('ReleaseRow')
class Releases extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get groupName => text()();
  TextColumn get genre => text().nullable()();
  TextColumn get releaseDate => text().nullable()();
  TextColumn get imageUrl => text().nullable()();
  TextColumn get thumbnailUrl => text().nullable()();
  TextColumn get productUri => text().nullable()();
  TextColumn get cardlistUri => text().nullable()();

  /// Distinct cards in the release, counting a card once however many
  /// alternate arts of it the release contains.
  IntColumn get cardCount => integer().withDefault(const Constant(0))();

  /// Every printing in the release, alternate arts included.
  IntColumn get printingCount => integer().withDefault(const Constant(0))();

  /// Position in the API's chronological release ordering.
  IntColumn get sortIndex => integer().withDefault(const Constant(0))();

  /// Name of the API the release's cards came from, when it was not the
  /// primary one. Null for everything the primary API publishes.
  TextColumn get dataSource => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One printing of a card. Alternate arts are separate rows sharing [number].
@DataClassName('CardRow')
class Cards extends Table {
  TextColumn get id => text()();
  TextColumn get number => text()();
  IntColumn get parallelId => integer().withDefault(const Constant(0))();
  TextColumn get name => text()();
  TextColumn get category => text()();

  /// Delimited colour list, e.g. `|red|blue|`.
  TextColumn get colors => text().withDefault(const Constant(''))();
  IntColumn get colorCount => integer().withDefault(const Constant(0))();

  TextColumn get rarity => text().nullable()();
  IntColumn get supplementalStars => integer().nullable()();
  IntColumn get level => integer().nullable()();
  IntColumn get playCost => integer().nullable()();
  IntColumn get useCost => integer().nullable()();

  /// Play cost, or use cost for Options. Denormalised so a single "cost"
  /// filter and sort works across every category.
  IntColumn get cost => integer().nullable()();

  IntColumn get dp => integer().nullable()();
  TextColumn get form => text().nullable()();
  TextColumn get attribute => text().nullable()();
  IntColumn get blockIcon => integer().nullable()();

  TextColumn get traits => text().withDefault(const Constant(''))();
  TextColumn get keywords => text().withDefault(const Constant(''))();

  TextColumn get effect => text().nullable()();
  TextColumn get inheritedEffect => text().nullable()();
  TextColumn get securityEffect => text().nullable()();

  /// Cheapest and priciest digivolution requirement, so a range filter on
  /// digivolve cost does not have to parse the JSON below.
  IntColumn get digivolveCostMin => integer().nullable()();
  IntColumn get digivolveCostMax => integer().nullable()();
  TextColumn get digivolutionRequirements =>
      text().withDefault(const Constant('[]'))();

  /// True for ACE cards, which carry the ACE marker and an Overflow cost.
  /// The API has no field for it; the name ends in "ACE".
  BoolColumn get isAce => boolean().withDefault(const Constant(false))();

  /// The other face of a dual card, which is both a Digimon and an Option.
  /// Stored as JSON; only a handful of cards have one.
  TextColumn get dualFace => text().nullable()();

  /// [dualFace]'s category, so a category filter matches either face.
  TextColumn get dualCategory => text().nullable()();

  TextColumn get notes => text().nullable()();
  TextColumn get faqs => text().withDefault(const Constant('[]'))();
  TextColumn get errata => text().nullable()();
  TextColumn get limitations => text().withDefault(const Constant('[]'))();

  /// Copies a deck may contain, precomputed for deck validation from the
  /// restriction list and the card's own rule text.
  IntColumn get copyLimit => integer().withDefault(const Constant(4))();

  /// Copies the card's own ⟨Rule⟩ text allows, when it raises the usual cap.
  IntColumn get ruleCopyLimit => integer().nullable()();

  TextColumn get imageUrl => text()();
  TextColumn get releaseIds => text().withDefault(const Constant(''))();

  /// True for the one printing per [number] that the library lists when
  /// alternate arts are collapsed. Usually the `parallelId == 0` printing, but
  /// computed as the lowest [parallelId] so cards that only exist as a
  /// parallel still show up.
  BoolColumn get isPrimary => boolean().withDefault(const Constant(true))();

  /// Collator key that sorts `BT25-002` after `BT25-001` rather than
  /// lexicographically.
  TextColumn get numberSort => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Normalised traits, so the filter sheet can list the ones actually in use
/// and match them exactly.
@DataClassName('CardTraitRow')
class CardTraits extends Table {
  TextColumn get cardId =>
      text().references(Cards, #id, onDelete: KeyAction.cascade)();
  TextColumn get trait => text()();

  @override
  Set<Column> get primaryKey => {cardId, trait};
}

/// Normalised keywords parsed from effect text at sync time.
@DataClassName('CardKeywordRow')
class CardKeywords extends Table {
  TextColumn get cardId =>
      text().references(Cards, #id, onDelete: KeyAction.cascade)();
  TextColumn get keyword => text()();

  @override
  Set<Column> get primaryKey => {cardId, keyword};
}

/// Which releases a printing appears in. A printing can span several.
@DataClassName('CardReleaseLinkRow')
class CardReleaseLinks extends Table {
  TextColumn get cardId =>
      text().references(Cards, #id, onDelete: KeyAction.cascade)();
  TextColumn get releaseId => text()();

  /// True for the printing that represents its card number *within this
  /// release*.
  ///
  /// This cannot be the card's global primary printing: promo and
  /// accessory products consist almost entirely of alternate arts whose base
  /// printing lives in some other set, so collapsing globally left those
  /// releases looking empty.
  BoolColumn get isPrimaryInRelease =>
      boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {cardId, releaseId};
}

/// A deck: a named folder holding revisions.
@DataClassName('DeckRow')
class Decks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  IntColumn get activeRevisionId => integer().nullable()();

  /// Card number the user pinned as the deck's picture in the deck list.
  /// Null lets the deck stand for itself with its biggest Digimon.
  TextColumn get thumbnailCardNumber => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// One named iteration of a deck.
@DataClassName('DeckRevisionRow')
class DeckRevisions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get deckId =>
      integer().references(Decks, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// A stack of one card inside a revision, keyed by card number because deck
/// legality counts copies per number rather than per printing.
@DataClassName('DeckEntryRow')
class DeckEntries extends Table {
  IntColumn get revisionId =>
      integer().references(DeckRevisions, #id, onDelete: KeyAction.cascade)();
  TextColumn get cardNumber => text()();
  IntColumn get quantity => integer()();

  /// Printing whose art the user picked, or null for the base printing.
  TextColumn get printingId => text().nullable()();

  @override
  Set<Column> get primaryKey => {revisionId, cardNumber};
}

/// A named list of cards the user keeps at hand while building decks — the
/// memory boosts, the floodgates, the tamers that are always worth a look.
///
/// A staple list is a catalogue, not a deck: it has no size, no legality and
/// no copies. It answers "which cards do this job", and the copies belong to
/// whatever deck is being built at the time.
@DataClassName('StapleListRow')
class StapleLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();

  /// Position in the user's own ordering of the lists.
  IntColumn get sortIndex => integer().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// One card in a staple list, keyed by printed number the way a deck entry is,
/// so a list survives the card table being rebuilt by a sync.
///
/// No quantity column: a card is either in the list or it is not.
@DataClassName('StapleEntryRow')
class StapleEntries extends Table {
  IntColumn get listId =>
      integer().references(StapleLists, #id, onDelete: KeyAction.cascade)();
  TextColumn get cardNumber => text()();
  DateTimeColumn get addedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {listId, cardNumber};
}

/// Bookkeeping for the card database sync: what was downloaded and when.
@DataClassName('SyncStateRow')
class SyncState extends Table {
  IntColumn get id => integer().withDefault(const Constant(1))();

  /// `updated-at` of the bulk file that produced the current data.
  TextColumn get bulkUpdatedAt => text().nullable()();

  /// Hash id of the bulk file, used to tell a re-publish from a new dataset.
  TextColumn get bulkId => text().nullable()();

  DateTimeColumn get syncedAt => dateTime().nullable()();
  IntColumn get cardCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}
