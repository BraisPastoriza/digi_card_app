// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'DigiCard App';

  @override
  String get navLibrary => 'Library';

  @override
  String get navDecks => 'Decks';

  @override
  String get viewerZoomHint => 'Pinch or double-tap to zoom';

  @override
  String viewerPageOf(int index, int total) {
    return '$index / $total';
  }

  @override
  String get actionClear => 'Clear';

  @override
  String get actionDone => 'Done';

  @override
  String multiSelectSearchHint(String facet) {
    return 'Search $facet';
  }

  @override
  String multiSelectCount(int count) {
    return '$count selected';
  }

  @override
  String multiSelectNoMatch(String query) {
    return 'Nothing matches \"$query\"';
  }

  @override
  String get releasePreviewBadge => 'PREVIEW';

  @override
  String get syncSettingUp => 'Setting up your card library';

  @override
  String get syncRederiving => 'Updating your cards to the new card rules';

  @override
  String get syncFailedTitle => 'Could not download the card database';

  @override
  String get syncRederivingDetail =>
      'Reading the cards you already have. Nothing is being downloaded.';

  @override
  String get syncOfflineNote =>
      'The full card list is stored on your device, so the library and deck builder work offline.';

  @override
  String get actionTryAgain => 'Try again';

  @override
  String get syncErrorGeneric => 'Something went wrong.';

  @override
  String get syncErrorOffline =>
      'No internet connection. Connect and try again — the card database only needs to download once.';

  @override
  String get syncStageChecking => 'Checking for card updates';

  @override
  String get syncStageReleases => 'Fetching expansions';

  @override
  String get syncStageDownloading => 'Downloading card data';

  @override
  String get syncStageParsing => 'Reading cards';

  @override
  String get syncStageStoring => 'Saving cards';

  @override
  String get syncStageIndexing => 'Building search index';

  @override
  String get syncStageComplete => 'Up to date';

  @override
  String get syncStageFailed => 'Sync failed';

  @override
  String syncDetailExpansions(int completed, int total) {
    return '$completed of $total expansions';
  }

  @override
  String syncDetailMegabytes(String received, String total) {
    return '$received of $total MB';
  }

  @override
  String syncDetailCards(int count) {
    return '$count cards';
  }

  @override
  String syncDetailPreview(String pack) {
    return 'Preview: $pack';
  }

  @override
  String get libraryTitle => 'Library';

  @override
  String get libraryDatabaseTooltip => 'Card database';

  @override
  String get libraryReleasesError => 'Could not load expansions';

  @override
  String get librarySearchHint => 'Search cards, effects, traits';

  @override
  String librarySectionSubtitle(int sets, int cards) {
    return '$sets sets · $cards cards';
  }

  @override
  String get databaseTitle => 'Card database';

  @override
  String get databaseCardsStored => 'Cards stored';

  @override
  String get databasePublished => 'Data published';

  @override
  String get databaseLastDownloaded => 'Last downloaded';

  @override
  String get databaseUnknown => 'unknown';

  @override
  String get databaseNever => 'never';

  @override
  String databaseSources(String source) {
    return 'Card data comes from the Heroicc API, plus $source for sets Heroicc has not published yet. Refreshing re-downloads the full card list, which is how new sets show up.';
  }

  @override
  String get databaseCredits => 'Data sources & credits';

  @override
  String get databaseCheckUpdates => 'Check for updates';

  @override
  String get searchHint => 'Name, effect, trait…';

  @override
  String get searchFailed => 'Search failed';

  @override
  String get searchNoCards => 'No cards found';

  @override
  String get searchNoCardsFiltered => 'Try removing a filter or two.';

  @override
  String get searchNoCardsPlain => 'Nothing matches that search.';

  @override
  String get searchClearFilters => 'Clear filters';

  @override
  String get searchEndOfResults => 'End of results';

  @override
  String get searchSearching => 'Searching…';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '$count card',
    );
    return '$_temp0';
  }

  @override
  String get searchSortTooltip => 'Sort';

  @override
  String searchRemoveFacet(String facet) {
    return 'Remove $facet';
  }

  @override
  String get searchClearAll => 'Clear all';

  @override
  String get releaseFallbackTitle => 'Expansion';

  @override
  String releaseCardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '$count card',
    );
    return '$_temp0';
  }

  @override
  String get releasePromosOnly => 'Promos only';

  @override
  String releaseAltArts(int count) {
    return 'Alt arts +$count';
  }

  @override
  String get releaseCardsError => 'Could not load cards';

  @override
  String get releaseEmptyTitle => 'No cards in this expansion';

  @override
  String get releaseEmptyMessage =>
      'The card list may not have been published yet.';

  @override
  String releasePreviewNotice(String source) {
    return 'Preview set. This expansion is not in the main card database yet, so its cards come from $source and are still being corrected. Some may be missing, and rulings and alternate arts are not available. Pull down to check for newly revealed cards.';
  }

  @override
  String releaseRefreshedNothing(String source) {
    return 'No new cards — this set is as complete as $source has it.';
  }

  @override
  String releaseRefreshedUpdated(String source) {
    return 'Updated from $source.';
  }

  @override
  String get colorRed => 'Red';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorBlack => 'Black';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorWhite => 'White';

  @override
  String get categoryDigimon => 'Digimon';

  @override
  String get categoryTamer => 'Tamer';

  @override
  String get categoryOption => 'Option';

  @override
  String get categoryDigiEgg => 'Digi-Egg';

  @override
  String get releaseGroupBooster => 'Booster Packs';

  @override
  String get releaseGroupEx => 'EX Boosters';

  @override
  String get releaseGroupStarter => 'Starter Decks';

  @override
  String get releaseGroupAdvanceDeck => 'Advanced Boosters';

  @override
  String get releaseGroupLimited => 'Limited Card Packs';

  @override
  String get releaseGroupResurgence => 'Resurgence Boosters';

  @override
  String get releaseGroupPromo => 'Promotional Cards';

  @override
  String get releaseGroupOther => 'Other Products';

  @override
  String get sortCardNumber => 'Card number';

  @override
  String get sortNameAsc => 'Name A-Z';

  @override
  String get sortCostAsc => 'Cost, low to high';

  @override
  String get sortCostDesc => 'Cost, high to low';

  @override
  String get sortDpDesc => 'DP, high to low';

  @override
  String get sortLevelAsc => 'Level, low to high';

  @override
  String get matchAnyOf => 'Any of';

  @override
  String get matchAllOf => 'All of';

  @override
  String get matchExactly => 'Exactly';

  @override
  String get limitationRestricted => 'Restricted';

  @override
  String get limitationBanned => 'Banned';

  @override
  String get limitationBannedPair => 'Banned Pair';

  @override
  String get limitationUnrestricted => 'Unrestricted';

  @override
  String get filtersTitle => 'Filters';

  @override
  String get filtersReset => 'Reset';

  @override
  String get filterColor => 'Color';

  @override
  String get filterCardType => 'Card type';

  @override
  String get filterLevel => 'Level';

  @override
  String filterLevelValue(int level) {
    return 'Lv.$level';
  }

  @override
  String get filterPlayCost => 'Play / use cost';

  @override
  String get filterDigivolveCost => 'Digivolution cost';

  @override
  String get filterDp => 'DP';

  @override
  String get filterKeyword => 'Keyword';

  @override
  String get filterRarity => 'Rarity';

  @override
  String get filterAttribute => 'Attribute';

  @override
  String get filterForm => 'Form';

  @override
  String get filterTrait => 'Trait';

  @override
  String get filterTraits => 'Traits';

  @override
  String get filterExpansion => 'Expansion';

  @override
  String get filterExpansions => 'Expansions';

  @override
  String get filterNarrowNote =>
      'ACE, dual and token cards narrow whichever types are selected.';

  @override
  String get filterAltArts => 'Show alternate arts';

  @override
  String get filterAltArtsSubtitle =>
      'List every printing instead of one card per number';

  @override
  String get filterRestrictedOnly => 'Restricted cards only';

  @override
  String get filterRestrictedOnlySubtitle =>
      'Cards limited or banned by the official list';

  @override
  String get filterAny => 'Any';

  @override
  String get filterShowResults => 'Show results';

  @override
  String filterShowCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Show $count cards',
      one: 'Show 1 card',
    );
    return '$_temp0';
  }

  @override
  String facetLevels(String levels) {
    return 'Lv. $levels';
  }

  @override
  String get facetCost => 'Cost';

  @override
  String get facetDigivolve => 'Digivolve';

  @override
  String get facetDp => 'DP';

  @override
  String get facetDualCard => 'Dual Card';

  @override
  String get facetToken => 'Token';

  @override
  String get facetAlternateArts => 'Alternate arts';

  @override
  String facetRangeExact(String label, int value) {
    return '$label $value';
  }

  @override
  String facetRangeBetween(String label, int min, int max) {
    return '$label $min-$max';
  }

  @override
  String facetRangeFrom(String label, int min) {
    return '$label $min+';
  }

  @override
  String facetRangeUpTo(String label, int max) {
    return '$label ≤$max';
  }

  @override
  String get cardLoadError => 'Could not load card';

  @override
  String get cardNotFound => 'Card not found';

  @override
  String get cardNotFoundMessage =>
      'It may have been removed in the last card update.';

  @override
  String get cardAddToDeck => 'Add to deck';

  @override
  String get cardEffect => 'Effect';

  @override
  String get cardSecurityEffect => 'Security effect';

  @override
  String get cardInheritedEffect => 'Inherited effect';

  @override
  String get cardInheritedEffects => 'Inherited effects';

  @override
  String get cardOriginalArt => 'Original art';

  @override
  String cardAlternateArt(int number) {
    return 'Alternate art $number';
  }

  @override
  String cardBlock(int block) {
    return 'Block $block';
  }

  @override
  String get cardDualBadge => 'Dual card';

  @override
  String get cardLevel => 'Level';

  @override
  String get cardPlayCost => 'Play cost';

  @override
  String get cardUseCost => 'Use cost';

  @override
  String get cardDp => 'DP';

  @override
  String get cardForm => 'Form';

  @override
  String get cardAttribute => 'Attribute';

  @override
  String cardNotTournamentLegal(String limitation) {
    return '$limitation — not tournament legal';
  }

  @override
  String cardLimitedTo(String limitation, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count copies',
      one: '$count copy',
    );
    return '$limitation to $_temp0';
  }

  @override
  String get cardPairBanTitle => 'Banned pair — playable, but not together';

  @override
  String cardPairBanOne(String partner) {
    return 'A deck with this card cannot also run $partner.';
  }

  @override
  String cardPairBanMany(String partners) {
    return 'A deck with this card cannot also run any of $partners.';
  }

  @override
  String cardRaisedCopyLimit(int limit) {
    return 'A deck may run up to $limit copies of this card.';
  }

  @override
  String get cardDigivolveTitle => 'Digivolution requirements';

  @override
  String cardDigivolveFromText(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The last $count conditions are printed in the card’s effect box, not in its cost box.',
      one:
          'The last condition is printed in the card’s effect box, not in its cost box.',
    );
    return '$_temp0';
  }

  @override
  String get cardLevelUnpublished => 'Level not published yet';

  @override
  String get cardConditionUnpublished => 'Condition not published yet';

  @override
  String cardCostValue(int cost) {
    return 'Cost $cost';
  }

  @override
  String cardOtherFace(String category) {
    return 'Other face — $category';
  }

  @override
  String get cardErrata => 'Errata';

  @override
  String cardErrataDated(String date) {
    return 'Errata · $date';
  }

  @override
  String get cardErrataPrinted => 'Printed';

  @override
  String get cardErrataShouldRead => 'Should read';

  @override
  String get cardFoundIn => 'Found in';

  @override
  String cardRulings(int count) {
    return 'Rulings ($count)';
  }

  @override
  String get cardPreviewNotice =>
      'Preview card from a set that is not in the main card database yet. Its text is community-sourced and may change, and it has no rulings or alternate arts here.';

  @override
  String digivolveLevel(int level) {
    return 'Lv.$level';
  }

  @override
  String digivolveAppmonGrade(String grade) {
    return '$grade Appmon';
  }

  @override
  String get digivolveAnyColor => 'any colour';

  @override
  String get creditsTitle => 'Data & credits';

  @override
  String get creditsArtworkTitle => 'Card artwork and card text';

  @override
  String get creditsArtworkBody =>
      'All card images, card text and related imagery are the intellectual property of © Akiyoshi Hongo, Toei Animation and © BANDAI. Their copyrights, trademarks and related rights apply.\n\nDigiCard App is a fan-made tool. It is not affiliated with, endorsed by, or connected to Bandai Namco Entertainment or Toei Animation.';

  @override
  String get creditsHeroiTitle => 'Card data — Heroicc';

  @override
  String get creditsHeroiBody =>
      'The card database, expansion list and rulings come from the Heroicc API.\n\nDigiCard App is not affiliated with, endorsed by, or connected to Heroicc. Original content provided by Heroicc — that is, the parts not owned by Akiyoshi Hongo, Toei Animation or BANDAI — is used under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International licence (CC BY-NC-SA 4.0).';

  @override
  String creditsPreviewTitle(String source) {
    return 'Preview sets — $source';
  }

  @override
  String get creditsPreviewBody =>
      'A set the Heroicc API has not published yet is filled in from the digimoncard.io public API so its cards can be searched and built with early. Those sets are marked PREVIEW wherever they appear.\n\nDigiCard App is not affiliated with, endorsed by, or connected to digimoncard.io. Preview data is community-maintained and still changing: expect gaps and corrections, and check anything that matters against the printed card.';

  @override
  String get creditsImagesTitle => 'How this app treats card images';

  @override
  String get creditsImagesBody =>
      'Card images are shown and exported whole. The app does not crop or cover the copyright line or the artist name, and adds no watermark, stamp or logo of its own to a card image.';

  @override
  String get creditsCachingTitle => 'Caching';

  @override
  String get creditsCachingBody =>
      'The full card list is downloaded once and kept on your device, so browsing and deck building make no further requests. Both APIs ask callers to cache rather than re-fetch, and to identify themselves; this app sends its own User-Agent on every request.';

  @override
  String creditsFooter(String source) {
    return 'Card images and text © Akiyoshi Hongo, Toei Animation, © BANDAI. Card data from Heroicc and $source. DigiCard App is a fan project, not affiliated with any of them.';
  }

  @override
  String issueMainDeckShort(int missing, int size) {
    String _temp0 = intl.Intl.pluralLogic(
      missing,
      locale: localeName,
      other: 'Main deck needs $missing more cards ($size required).',
      one: 'Main deck needs 1 more card ($size required).',
    );
    return '$_temp0';
  }

  @override
  String issueMainDeckOver(int excess, int size) {
    String _temp0 = intl.Intl.pluralLogic(
      excess,
      locale: localeName,
      other: 'Main deck is over by $excess cards ($size allowed).',
      one: 'Main deck is over by 1 card ($size allowed).',
    );
    return '$_temp0';
  }

  @override
  String issueEggDeckOver(int excess, int size) {
    return 'Egg deck is over by $excess ($size allowed).';
  }

  @override
  String issueTooManyCopies(
    String name,
    String number,
    int quantity,
    int limit,
  ) {
    return '$name ($number): $quantity copies, max $limit.';
  }

  @override
  String issueTooManyCopiesLimited(
    String name,
    String number,
    String limitation,
    int limit,
    int quantity,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: '$limit copies',
      one: '1 copy',
    );
    return '$name ($number) is $limitation to $_temp0; deck has $quantity.';
  }

  @override
  String issueBannedPair(
    String name,
    String number,
    String partnerName,
    String partnerNumber,
  ) {
    return '$name ($number) and $partnerName ($partnerNumber) are a banned pair; a deck may run either one, not both.';
  }

  @override
  String issueToken(String name, String number) {
    return '$name ($number) is a token. Tokens are created during play and cannot be part of a deck.';
  }

  @override
  String get issueEmptyEggDeck =>
      'Egg deck is empty. Most decks run 4-5 Digi-Eggs.';

  @override
  String get sectionDigiEggs => 'Digi-Eggs';

  @override
  String get sectionDigimon => 'Digimon';

  @override
  String get sectionTamers => 'Tamers';

  @override
  String get sectionOptions => 'Options';

  @override
  String sectionWithLevel(String section, int level) {
    return '$section · Lv.$level';
  }

  @override
  String get decksTitle => 'Decks';

  @override
  String get decksTabStaples => 'Staples';

  @override
  String get decksImportDeck => 'Import deck list';

  @override
  String get decksImportStaples => 'Import staple list';

  @override
  String get decksNewDeck => 'New deck';

  @override
  String get decksNewList => 'New list';

  @override
  String get decksLoadError => 'Could not load decks';

  @override
  String get decksEmptyTitle => 'No decks yet';

  @override
  String get decksEmptyMessage =>
      'Build a deck of 50 cards plus up to 5 Digi-Eggs. Every deck keeps its own revisions, so you can try changes without losing what worked.';

  @override
  String get decksCreateFirst => 'Create your first deck';

  @override
  String get decksSearchHint => 'Search decks';

  @override
  String get decksNoMatchTitle => 'No decks match';

  @override
  String decksNoMatchMessage(String query) {
    return 'Nothing here is called \"$query\".';
  }

  @override
  String deckRevisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count revisions',
      one: '1 revision',
    );
    return '$_temp0';
  }

  @override
  String deckRevisionWithCount(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count revisions',
      one: '1 revision',
    );
    return '$name · $_temp0';
  }

  @override
  String get deckNoRevisions => 'No revisions';

  @override
  String get actionRename => 'Rename';

  @override
  String get actionDelete => 'Delete';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionSave => 'Save';

  @override
  String get deckRenameTitle => 'Rename deck';

  @override
  String get deckNameLabel => 'Deck name';

  @override
  String get dialogNameLabel => 'Name';

  @override
  String deckDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String deckDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The deck and all $count of its revisions are removed. This cannot be undone.',
      one: 'The deck and its 1 revision are removed. This cannot be undone.',
    );
    return '$_temp0';
  }

  @override
  String get deckCountMain => 'Main';

  @override
  String get deckCountEggs => 'Eggs';

  @override
  String get deckLegal => 'Legal';

  @override
  String get deckDraft => 'Draft';

  @override
  String get thumbnailTitle => 'Deck thumbnail';

  @override
  String get thumbnailSubtitle =>
      'The card that stands for this deck in the deck list.';

  @override
  String get thumbnailEmptyTitle => 'Nothing to pick yet';

  @override
  String get thumbnailEmptyMessage => 'Add cards to this revision first.';

  @override
  String get thumbnailAutomatic => 'Choose automatically';

  @override
  String thumbnailAutomaticNamed(String name) {
    return 'Choose automatically ($name)';
  }

  @override
  String get stapleSourceTitle => 'Build from a staple list';

  @override
  String get stapleSourceEmpty =>
      'You have no lists yet. Build one under Decks · Staples.';

  @override
  String get stapleSourceHint =>
      'Opens the card picker showing just that list.';

  @override
  String cardCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get deckLoadError => 'Could not load deck';

  @override
  String get deckNotFound => 'Deck not found';

  @override
  String get deckNotFoundMessage => 'It may have been deleted.';

  @override
  String deckEditing(String revision) {
    return 'Editing $revision';
  }

  @override
  String get deckMenuRename => 'Rename deck';

  @override
  String get deckMenuThumbnail => 'Deck thumbnail';

  @override
  String get deckMenuTestHand => 'Test hand';

  @override
  String get deckMenuExport => 'Export';

  @override
  String deckMenuClear(String revision) {
    return 'Clear $revision';
  }

  @override
  String get deckMenuDelete => 'Delete deck';

  @override
  String get deckTabCards => 'Cards';

  @override
  String deckTabRevisions(int count) {
    return 'Revisions ($count)';
  }

  @override
  String get deckTabStats => 'Stats';

  @override
  String get deckAddCards => 'Add cards';

  @override
  String get deckNoRevisionsTitle => 'This deck has no revisions';

  @override
  String get deckNoRevisionsMessage => 'Create one to start adding cards.';

  @override
  String deckClearTitle(String revision) {
    return 'Clear $revision?';
  }

  @override
  String get deckClearMessage =>
      'Removes every card from this revision. Other revisions keep their cards.';

  @override
  String get actionClearConfirm => 'Clear';

  @override
  String get revisionLoadError => 'Could not load this revision';

  @override
  String get revisionEmptyTitle => 'This revision is empty';

  @override
  String get revisionEmptyMessage =>
      'Add 50 cards to the main deck and up to 5 Digi-Eggs to the egg deck. A deck with nothing in it is not kept, so leaving now is the same as never having made it.';

  @override
  String get deckCardTileBadge => 'Card';

  @override
  String get statsLoadError => 'Could not analyse this revision';

  @override
  String get statsEmptyTitle => 'Nothing to analyse yet';

  @override
  String get statsEmptyMessage =>
      'Add cards to see the curve and colour balance.';

  @override
  String get statsCurveTitle => 'Cost curve';

  @override
  String get statsCurveSubtitle => 'Play cost of main deck cards';

  @override
  String get statsLevelTitle => 'Level spread';

  @override
  String get statsLevelSubtitle => 'Levels in the main deck';

  @override
  String get statsColorTitle => 'Colour balance';

  @override
  String get statsColorSubtitle => 'Cards of each colour, counting duals twice';

  @override
  String get statsLegal => 'Tournament legal';

  @override
  String get statsNotLegal => 'Not legal yet';

  @override
  String statsDeckCounts(int main, int mainSize, int eggs, int eggSize) {
    return '$main/$mainSize · $eggs/$eggSize';
  }

  @override
  String get statsNoCosts => 'No cards with a cost yet';

  @override
  String get statsNoColors => 'No colours yet';

  @override
  String get revisionsExplainer =>
      'The active revision is the one you edit. Branch a new revision to experiment while keeping the current list intact.';

  @override
  String get revisionsBranch => 'Branch active';

  @override
  String get revisionsEmpty => 'Empty';

  @override
  String revisionBranchTitle(String name) {
    return 'Branch from $name';
  }

  @override
  String revisionBranchHelper(String name) {
    return 'Copies the cards in $name';
  }

  @override
  String get revisionNameLabel => 'Revision name';

  @override
  String get actionCreate => 'Create';

  @override
  String get revisionNewEmptyTitle => 'New empty revision';

  @override
  String revisionSummary(int main, int eggs, String date) {
    return '$main main · $eggs eggs · $date';
  }

  @override
  String get actionDuplicate => 'Duplicate';

  @override
  String get revisionRenameTitle => 'Rename revision';

  @override
  String revisionDuplicateTitle(String name) {
    return 'Duplicate $name';
  }

  @override
  String revisionCopyName(String name) {
    return '$name copy';
  }

  @override
  String revisionDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get revisionDeleteBody =>
      'The cards in this revision are removed. Other revisions of the deck are not affected.';

  @override
  String pickerCopyCapped(String name, String limitation, int limit) {
    String _temp0 = intl.Intl.pluralLogic(
      limit,
      locale: localeName,
      other: '$limit copies',
      one: '1 copy',
    );
    return '$name is $limitation to $_temp0.';
  }

  @override
  String pickerBannedPairWarning(String name, String partners) {
    return '$name is a banned pair with $partners. A deck may run either, not both.';
  }

  @override
  String get pickerSearchHint => 'Add cards…';

  @override
  String get pickerNoCardsFiltered =>
      'Try a different search or clear the filters.';

  @override
  String get pickerNoCardsInList =>
      'Nothing in this list matches. Try another source, search or filter.';

  @override
  String get pickerAllCards => 'All cards';

  @override
  String pickerListChip(String name, int count) {
    return '$name · $count';
  }

  @override
  String get pickerMainDeck => 'Main deck';

  @override
  String get pickerEggDeck => 'Egg deck';

  @override
  String get pickerTapHint => 'Tap a card to set copies';

  @override
  String get addToDeckTokenBlocked =>
      'Tokens are created during play and cannot go in a deck.';

  @override
  String get addToDeckTitle => 'Add to deck';

  @override
  String addToDeckCardLine(String name, String number) {
    return '$name · $number';
  }

  @override
  String get addToDeckEmptyMessage =>
      'Create a deck to start adding cards to it.';

  @override
  String get addToDeckNewSubtitle => 'Start a deck with this card';

  @override
  String addToDeckAdded(String name, String deck) {
    return 'Added $name to $deck';
  }

  @override
  String addToDeckAddedWithPair(String name, String deck, String partners) {
    return 'Added $name to $deck — banned pair with $partners';
  }

  @override
  String get handTitle => 'Test hand';

  @override
  String get handNotFullTitle => 'Not a full deck yet';

  @override
  String handNotFullMessage(int count, int size) {
    return 'A test hand is dealt off the $size cards of the main deck, which the Digi-Eggs are not part of. This revision has $count of $size.';
  }

  @override
  String get handOpeningTitle => 'Opening hand';

  @override
  String get handOpeningSubtitle => 'The 5 cards you draw';

  @override
  String get handSecurityTitle => 'Security';

  @override
  String get handSecuritySubtitle => 'Top of the stack first';

  @override
  String get handTestAgain => 'Test again';

  @override
  String get exportTitle => 'Export';

  @override
  String get exportTabImage => 'Image';

  @override
  String get exportTabText => 'Text';

  @override
  String get exportNothingTitle => 'Nothing to export';

  @override
  String get exportNothingMessage => 'This revision has no cards in it yet.';

  @override
  String get exportFallbackDeckName => 'Deck';

  @override
  String get exportRenderFailed => 'Could not render the deck image.';

  @override
  String get exportNeedsPermission =>
      'DigiCard needs permission to save to your gallery.';

  @override
  String get exportSaved => 'Saved to your gallery.';

  @override
  String get exportLoadingArt => 'Loading card art…';

  @override
  String exportLayoutHint(String description) {
    return '$description. Pinch to look closer — the saved image is full size.';
  }

  @override
  String get exportSaving => 'Saving…';

  @override
  String get exportSaveToGallery => 'Save to gallery';

  @override
  String exportListCopied(String format) {
    return '$format list copied.';
  }

  @override
  String get exportCopyToClipboard => 'Copy to clipboard';

  @override
  String get layoutDetailed => 'Detailed';

  @override
  String get layoutDetailedDescription => 'Split into sections, 8 per row';

  @override
  String get layoutCompact => 'Compact';

  @override
  String get layoutCompactDescription => 'One grid, 7 per row';

  @override
  String get listFormatStandard => 'Default';

  @override
  String get listFormatUntap => 'Untap';

  @override
  String get importClipboardEmpty => 'The clipboard has no text in it.';

  @override
  String get importDefaultDeckName => 'Imported deck';

  @override
  String get importDefaultShortName => 'Imported';

  @override
  String get importTitle => 'Import deck list';

  @override
  String get importExplainer =>
      'Paste a deck list in either format — \"4 Agumon BT1-010\" or \"4 Agumon (BT1-010)\". Headings and comments between the lines are ignored.';

  @override
  String get importPaste => 'Paste';

  @override
  String get importReading => 'Reading…';

  @override
  String get importReadList => 'Read list';

  @override
  String get importNewDeck => 'New deck';

  @override
  String get importNewRevision => 'New revision';

  @override
  String get importNoDecks => 'You have no decks to add a revision to yet.';

  @override
  String get importDeckField => 'Deck';

  @override
  String get importNothingRecognised => 'No cards recognised in that list.';

  @override
  String importSummary(int cards, int copies) {
    return '$cards cards · $copies copies';
  }

  @override
  String importUnmatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines could not be matched and will be left out:',
      one: '1 line could not be matched and will be left out:',
    );
    return '$_temp0';
  }

  @override
  String importAndMore(int count) {
    return '…and $count more';
  }

  @override
  String get stapleNotFound => 'List not found';

  @override
  String get stapleMenuRename => 'Rename list';

  @override
  String get stapleMenuExport => 'Export list';

  @override
  String get stapleMenuDelete => 'Delete list';

  @override
  String get stapleAddCards => 'Add cards';

  @override
  String get stapleEmptyTitle => 'This list is empty';

  @override
  String get stapleEmptyMessage =>
      'Add the cards you want at hand. They show up as a source in the deck builder, so you can drop them into a deck without going looking for them.';

  @override
  String stapleMissingCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count more cards are in this list but not in your library yet.',
      one: '1 more card is in this list but not in your library yet.',
    );
    return '$_temp0';
  }

  @override
  String stapleRemoved(String name) {
    return 'Removed $name';
  }

  @override
  String get actionUndo => 'Undo';

  @override
  String get stapleNameLabel => 'List name';

  @override
  String get staplesLoadError => 'Could not load your lists';

  @override
  String get staplesEmptyTitle => 'No staple lists';

  @override
  String get staplesEmptyMessage =>
      'A staple list is a set of cards you keep coming back to — the memory boosts, the floodgates, the tamers. Build one and it shows up as a source while you add cards to a deck.';

  @override
  String get staplesCreate => 'Create a list';

  @override
  String get stapleNewTitle => 'New staple list';

  @override
  String stapleDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String stapleDeleteBody(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          'The list and the $count cards in it are removed. Your decks keep every card they already hold.',
      one:
          'The list and the 1 card in it are removed. Your decks keep every card they already hold.',
    );
    return '$_temp0';
  }

  @override
  String get stapleNothingYet => 'Nothing in this list yet.';

  @override
  String stapleExportCopied(String name) {
    return '$name copied.';
  }

  @override
  String stapleExportTitle(String name) {
    return 'Export $name';
  }

  @override
  String get stapleExportExplainer =>
      'One line per card, the same shape a deck list takes, so the result reads in this app and in the tools that take deck lists.';

  @override
  String get stapleExportEmpty => 'This list has no cards in it yet.';

  @override
  String stapleExportMissing(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count cards are in this list but not in your library yet, so they are not written out.',
      one:
          '1 card is in this list but not in your library yet, so it is not written out.',
    );
    return '$_temp0';
  }

  @override
  String get staplePickerHint => 'Add cards to the list…';

  @override
  String staplePickerSummary(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$name · $_temp0';
  }

  @override
  String get staplePickerTapHint => 'Tap to add or remove';

  @override
  String get stapleImportTitle => 'Import a staple list';

  @override
  String get stapleImportExplainer =>
      'Paste a list of cards — the export from this app, or any deck list. Copies are ignored: a staple list holds each card once.';

  @override
  String get stapleImportDestination => 'Where it goes';

  @override
  String get stapleImportNewList => 'New list';

  @override
  String get stapleImportAddToList => 'Add to a list';

  @override
  String get stapleImportNameHint => 'Blue tech';

  @override
  String get stapleImportNoLists => 'You have no lists to add to yet.';

  @override
  String get stapleImportListField => 'List';

  @override
  String stapleImportListOption(String name, int count) {
    return '$name · $count';
  }

  @override
  String stapleImportButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Import $count cards',
      one: 'Import 1 card',
    );
    return '$_temp0';
  }

  @override
  String stapleImportFound(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards found',
      one: '1 card found',
    );
    return '$_temp0';
  }

  @override
  String stapleImportUnmatched(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines matched no card and are left out:',
      one: '1 line matched no card and is left out:',
    );
    return '$_temp0';
  }

  @override
  String stapleImportAndMore(int count) {
    return 'and $count more';
  }

  @override
  String get defaultDeckName => 'New Deck';

  @override
  String get importImporting => 'Importing…';

  @override
  String get importAction => 'Import';

  @override
  String get languageTitle => 'Language';

  @override
  String get languageSubtitle =>
      'Card names and card text stay in English, which is the language the cards are printed in.';

  @override
  String get languageSystem => 'Match my device';

  @override
  String languageSystemDetail(String language) {
    return 'Now: $language';
  }

  @override
  String get cardAddToList => 'Add to a staple list';

  @override
  String get addToListTitle => 'Add to list';

  @override
  String get addToListEmptyMessage =>
      'A staple list keeps the cards you come back to within reach of the deck builder.';

  @override
  String get addToListNewSubtitle => 'Start a list with this card';

  @override
  String addToListAdded(String name, String list) {
    return '$name added to $list';
  }

  @override
  String addToListRemoved(String name, String list) {
    return '$name removed from $list';
  }

  @override
  String get addToListHolds => 'In this list';
}
