import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
  ];

  /// The application name, shown in the task switcher.
  ///
  /// In en, this message translates to:
  /// **'DigiCard App'**
  String get appTitle;

  /// Bottom navigation tab holding the card database.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get navLibrary;

  /// Bottom navigation tab holding the user's decks.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get navDecks;

  /// No description provided for @viewerZoomHint.
  ///
  /// In en, this message translates to:
  /// **'Pinch or double-tap to zoom'**
  String get viewerZoomHint;

  /// Position within the card's alternate arts.
  ///
  /// In en, this message translates to:
  /// **'{index} / {total}'**
  String viewerPageOf(int index, int total);

  /// Empties the current selection.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClear;

  /// Confirms a selection and closes the page.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get actionDone;

  /// Hint in the search field of a value picker; facet is the lowercased page title, e.g. traits.
  ///
  /// In en, this message translates to:
  /// **'Search {facet}'**
  String multiSelectSearchHint(String facet);

  /// No description provided for @multiSelectCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String multiSelectCount(int count);

  /// No description provided for @multiSelectNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches \"{query}\"'**
  String multiSelectNoMatch(String query);

  /// Marks an expansion whose cards are not released yet. Uppercase.
  ///
  /// In en, this message translates to:
  /// **'PREVIEW'**
  String get releasePreviewBadge;

  /// No description provided for @syncSettingUp.
  ///
  /// In en, this message translates to:
  /// **'Setting up your card library'**
  String get syncSettingUp;

  /// No description provided for @syncRederiving.
  ///
  /// In en, this message translates to:
  /// **'Updating your cards to the new card rules'**
  String get syncRederiving;

  /// No description provided for @syncFailedTitle.
  ///
  /// In en, this message translates to:
  /// **'Could not download the card database'**
  String get syncFailedTitle;

  /// No description provided for @syncRederivingDetail.
  ///
  /// In en, this message translates to:
  /// **'Reading the cards you already have. Nothing is being downloaded.'**
  String get syncRederivingDetail;

  /// No description provided for @syncOfflineNote.
  ///
  /// In en, this message translates to:
  /// **'The full card list is stored on your device, so the library and deck builder work offline.'**
  String get syncOfflineNote;

  /// No description provided for @actionTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get actionTryAgain;

  /// No description provided for @syncErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get syncErrorGeneric;

  /// No description provided for @syncErrorOffline.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Connect and try again — the card database only needs to download once.'**
  String get syncErrorOffline;

  /// No description provided for @syncStageChecking.
  ///
  /// In en, this message translates to:
  /// **'Checking for card updates'**
  String get syncStageChecking;

  /// No description provided for @syncStageReleases.
  ///
  /// In en, this message translates to:
  /// **'Fetching expansions'**
  String get syncStageReleases;

  /// No description provided for @syncStageDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading card data'**
  String get syncStageDownloading;

  /// No description provided for @syncStageParsing.
  ///
  /// In en, this message translates to:
  /// **'Reading cards'**
  String get syncStageParsing;

  /// No description provided for @syncStageStoring.
  ///
  /// In en, this message translates to:
  /// **'Saving cards'**
  String get syncStageStoring;

  /// No description provided for @syncStageIndexing.
  ///
  /// In en, this message translates to:
  /// **'Building search index'**
  String get syncStageIndexing;

  /// No description provided for @syncStageComplete.
  ///
  /// In en, this message translates to:
  /// **'Up to date'**
  String get syncStageComplete;

  /// No description provided for @syncStageFailed.
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncStageFailed;

  /// No description provided for @syncDetailExpansions.
  ///
  /// In en, this message translates to:
  /// **'{completed} of {total} expansions'**
  String syncDetailExpansions(int completed, int total);

  /// No description provided for @syncDetailMegabytes.
  ///
  /// In en, this message translates to:
  /// **'{received} of {total} MB'**
  String syncDetailMegabytes(String received, String total);

  /// No description provided for @syncDetailCards.
  ///
  /// In en, this message translates to:
  /// **'{count} cards'**
  String syncDetailCards(int count);

  /// No description provided for @syncDetailPreview.
  ///
  /// In en, this message translates to:
  /// **'Preview: {pack}'**
  String syncDetailPreview(String pack);

  /// Title of the expansions screen.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @libraryDatabaseTooltip.
  ///
  /// In en, this message translates to:
  /// **'Card database'**
  String get libraryDatabaseTooltip;

  /// No description provided for @libraryReleasesError.
  ///
  /// In en, this message translates to:
  /// **'Could not load expansions'**
  String get libraryReleasesError;

  /// No description provided for @librarySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search cards, effects, traits'**
  String get librarySearchHint;

  /// No description provided for @librarySectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{sets} sets · {cards} cards'**
  String librarySectionSubtitle(int sets, int cards);

  /// No description provided for @databaseTitle.
  ///
  /// In en, this message translates to:
  /// **'Card database'**
  String get databaseTitle;

  /// No description provided for @databaseCardsStored.
  ///
  /// In en, this message translates to:
  /// **'Cards stored'**
  String get databaseCardsStored;

  /// No description provided for @databasePublished.
  ///
  /// In en, this message translates to:
  /// **'Data published'**
  String get databasePublished;

  /// No description provided for @databaseLastDownloaded.
  ///
  /// In en, this message translates to:
  /// **'Last downloaded'**
  String get databaseLastDownloaded;

  /// Stands in for a date the database does not have.
  ///
  /// In en, this message translates to:
  /// **'unknown'**
  String get databaseUnknown;

  /// Stands in for a download that has not happened.
  ///
  /// In en, this message translates to:
  /// **'never'**
  String get databaseNever;

  /// No description provided for @databaseSources.
  ///
  /// In en, this message translates to:
  /// **'Card data comes from the Heroicc API, plus {source} for sets Heroicc has not published yet. Refreshing re-downloads the full card list, which is how new sets show up.'**
  String databaseSources(String source);

  /// No description provided for @databaseCredits.
  ///
  /// In en, this message translates to:
  /// **'Data sources & credits'**
  String get databaseCredits;

  /// No description provided for @databaseCheckUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get databaseCheckUpdates;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Name, effect, trait…'**
  String get searchHint;

  /// No description provided for @searchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed'**
  String get searchFailed;

  /// No description provided for @searchNoCards.
  ///
  /// In en, this message translates to:
  /// **'No cards found'**
  String get searchNoCards;

  /// No description provided for @searchNoCardsFiltered.
  ///
  /// In en, this message translates to:
  /// **'Try removing a filter or two.'**
  String get searchNoCardsFiltered;

  /// No description provided for @searchNoCardsPlain.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches that search.'**
  String get searchNoCardsPlain;

  /// No description provided for @searchClearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get searchClearFilters;

  /// No description provided for @searchEndOfResults.
  ///
  /// In en, this message translates to:
  /// **'End of results'**
  String get searchEndOfResults;

  /// No description provided for @searchSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching…'**
  String get searchSearching;

  /// No description provided for @searchResultCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} card} other{{count} cards}}'**
  String searchResultCount(int count);

  /// No description provided for @searchSortTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get searchSortTooltip;

  /// No description provided for @searchRemoveFacet.
  ///
  /// In en, this message translates to:
  /// **'Remove {facet}'**
  String searchRemoveFacet(String facet);

  /// No description provided for @searchClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get searchClearAll;

  /// No description provided for @releaseFallbackTitle.
  ///
  /// In en, this message translates to:
  /// **'Expansion'**
  String get releaseFallbackTitle;

  /// No description provided for @releaseCardCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{{count} card} other{{count} cards}}'**
  String releaseCardCount(int count);

  /// No description provided for @releasePromosOnly.
  ///
  /// In en, this message translates to:
  /// **'Promos only'**
  String get releasePromosOnly;

  /// No description provided for @releaseAltArts.
  ///
  /// In en, this message translates to:
  /// **'Alt arts +{count}'**
  String releaseAltArts(int count);

  /// No description provided for @releaseCardsError.
  ///
  /// In en, this message translates to:
  /// **'Could not load cards'**
  String get releaseCardsError;

  /// No description provided for @releaseEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No cards in this expansion'**
  String get releaseEmptyTitle;

  /// No description provided for @releaseEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'The card list may not have been published yet.'**
  String get releaseEmptyMessage;

  /// No description provided for @releasePreviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Preview set. This expansion is not in the main card database yet, so its cards come from {source} and are still being corrected. Some may be missing, and rulings and alternate arts are not available. Pull down to check for newly revealed cards.'**
  String releasePreviewNotice(String source);

  /// No description provided for @releaseRefreshedNothing.
  ///
  /// In en, this message translates to:
  /// **'No new cards — this set is as complete as {source} has it.'**
  String releaseRefreshedNothing(String source);

  /// No description provided for @releaseRefreshedUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated from {source}.'**
  String releaseRefreshedUpdated(String source);

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorBlack.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get colorBlack;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorWhite;

  /// Card type. Left in English in every language: it is the word printed on the card.
  ///
  /// In en, this message translates to:
  /// **'Digimon'**
  String get categoryDigimon;

  /// Card type, printed on the card and left in English.
  ///
  /// In en, this message translates to:
  /// **'Tamer'**
  String get categoryTamer;

  /// Card type, printed on the card and left in English.
  ///
  /// In en, this message translates to:
  /// **'Option'**
  String get categoryOption;

  /// Card type, printed on the card and left in English.
  ///
  /// In en, this message translates to:
  /// **'Digi-Egg'**
  String get categoryDigiEgg;

  /// No description provided for @releaseGroupBooster.
  ///
  /// In en, this message translates to:
  /// **'Booster Packs'**
  String get releaseGroupBooster;

  /// No description provided for @releaseGroupEx.
  ///
  /// In en, this message translates to:
  /// **'EX Boosters'**
  String get releaseGroupEx;

  /// No description provided for @releaseGroupStarter.
  ///
  /// In en, this message translates to:
  /// **'Starter Decks'**
  String get releaseGroupStarter;

  /// No description provided for @releaseGroupAdvanceDeck.
  ///
  /// In en, this message translates to:
  /// **'Advanced Boosters'**
  String get releaseGroupAdvanceDeck;

  /// No description provided for @releaseGroupLimited.
  ///
  /// In en, this message translates to:
  /// **'Limited Card Packs'**
  String get releaseGroupLimited;

  /// No description provided for @releaseGroupResurgence.
  ///
  /// In en, this message translates to:
  /// **'Resurgence Boosters'**
  String get releaseGroupResurgence;

  /// No description provided for @releaseGroupPromo.
  ///
  /// In en, this message translates to:
  /// **'Promotional Cards'**
  String get releaseGroupPromo;

  /// No description provided for @releaseGroupOther.
  ///
  /// In en, this message translates to:
  /// **'Other Products'**
  String get releaseGroupOther;

  /// No description provided for @sortCardNumber.
  ///
  /// In en, this message translates to:
  /// **'Card number'**
  String get sortCardNumber;

  /// No description provided for @sortNameAsc.
  ///
  /// In en, this message translates to:
  /// **'Name A-Z'**
  String get sortNameAsc;

  /// No description provided for @sortCostAsc.
  ///
  /// In en, this message translates to:
  /// **'Cost, low to high'**
  String get sortCostAsc;

  /// No description provided for @sortCostDesc.
  ///
  /// In en, this message translates to:
  /// **'Cost, high to low'**
  String get sortCostDesc;

  /// No description provided for @sortDpDesc.
  ///
  /// In en, this message translates to:
  /// **'DP, high to low'**
  String get sortDpDesc;

  /// No description provided for @sortLevelAsc.
  ///
  /// In en, this message translates to:
  /// **'Level, low to high'**
  String get sortLevelAsc;

  /// Filter mode: a card needs only one of the selected values.
  ///
  /// In en, this message translates to:
  /// **'Any of'**
  String get matchAnyOf;

  /// Filter mode: a card needs every selected value.
  ///
  /// In en, this message translates to:
  /// **'All of'**
  String get matchAllOf;

  /// Colour filter mode: the card's colours are exactly those selected.
  ///
  /// In en, this message translates to:
  /// **'Exactly'**
  String get matchExactly;

  /// No description provided for @limitationRestricted.
  ///
  /// In en, this message translates to:
  /// **'Restricted'**
  String get limitationRestricted;

  /// No description provided for @limitationBanned.
  ///
  /// In en, this message translates to:
  /// **'Banned'**
  String get limitationBanned;

  /// No description provided for @limitationBannedPair.
  ///
  /// In en, this message translates to:
  /// **'Banned Pair'**
  String get limitationBannedPair;

  /// No description provided for @limitationUnrestricted.
  ///
  /// In en, this message translates to:
  /// **'Unrestricted'**
  String get limitationUnrestricted;

  /// No description provided for @filtersTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTitle;

  /// No description provided for @filtersReset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get filtersReset;

  /// No description provided for @filterColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get filterColor;

  /// No description provided for @filterCardType.
  ///
  /// In en, this message translates to:
  /// **'Card type'**
  String get filterCardType;

  /// No description provided for @filterLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get filterLevel;

  /// A Digimon level as a filter chip.
  ///
  /// In en, this message translates to:
  /// **'Lv.{level}'**
  String filterLevelValue(int level);

  /// No description provided for @filterPlayCost.
  ///
  /// In en, this message translates to:
  /// **'Play / use cost'**
  String get filterPlayCost;

  /// No description provided for @filterDigivolveCost.
  ///
  /// In en, this message translates to:
  /// **'Digivolution cost'**
  String get filterDigivolveCost;

  /// Digimon power, printed on the card as DP in every language.
  ///
  /// In en, this message translates to:
  /// **'DP'**
  String get filterDp;

  /// No description provided for @filterKeyword.
  ///
  /// In en, this message translates to:
  /// **'Keyword'**
  String get filterKeyword;

  /// No description provided for @filterRarity.
  ///
  /// In en, this message translates to:
  /// **'Rarity'**
  String get filterRarity;

  /// No description provided for @filterAttribute.
  ///
  /// In en, this message translates to:
  /// **'Attribute'**
  String get filterAttribute;

  /// No description provided for @filterForm.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get filterForm;

  /// No description provided for @filterTrait.
  ///
  /// In en, this message translates to:
  /// **'Trait'**
  String get filterTrait;

  /// Title of the full-screen trait picker.
  ///
  /// In en, this message translates to:
  /// **'Traits'**
  String get filterTraits;

  /// No description provided for @filterExpansion.
  ///
  /// In en, this message translates to:
  /// **'Expansion'**
  String get filterExpansion;

  /// Title of the full-screen expansion picker.
  ///
  /// In en, this message translates to:
  /// **'Expansions'**
  String get filterExpansions;

  /// No description provided for @filterNarrowNote.
  ///
  /// In en, this message translates to:
  /// **'ACE, dual and token cards narrow whichever types are selected.'**
  String get filterNarrowNote;

  /// No description provided for @filterAltArts.
  ///
  /// In en, this message translates to:
  /// **'Show alternate arts'**
  String get filterAltArts;

  /// No description provided for @filterAltArtsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'List every printing instead of one card per number'**
  String get filterAltArtsSubtitle;

  /// No description provided for @filterRestrictedOnly.
  ///
  /// In en, this message translates to:
  /// **'Restricted cards only'**
  String get filterRestrictedOnly;

  /// No description provided for @filterRestrictedOnlySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cards limited or banned by the official list'**
  String get filterRestrictedOnlySubtitle;

  /// Shown where a filter is not narrowing anything.
  ///
  /// In en, this message translates to:
  /// **'Any'**
  String get filterAny;

  /// No description provided for @filterShowResults.
  ///
  /// In en, this message translates to:
  /// **'Show results'**
  String get filterShowResults;

  /// No description provided for @filterShowCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Show 1 card} other{Show {count} cards}}'**
  String filterShowCount(int count);

  /// Chip listing the levels being filtered on, e.g. Lv. 3, 4.
  ///
  /// In en, this message translates to:
  /// **'Lv. {levels}'**
  String facetLevels(String levels);

  /// No description provided for @facetCost.
  ///
  /// In en, this message translates to:
  /// **'Cost'**
  String get facetCost;

  /// No description provided for @facetDigivolve.
  ///
  /// In en, this message translates to:
  /// **'Digivolve'**
  String get facetDigivolve;

  /// No description provided for @facetDp.
  ///
  /// In en, this message translates to:
  /// **'DP'**
  String get facetDp;

  /// No description provided for @facetDualCard.
  ///
  /// In en, this message translates to:
  /// **'Dual Card'**
  String get facetDualCard;

  /// Card type printed on the card; left in English.
  ///
  /// In en, this message translates to:
  /// **'Token'**
  String get facetToken;

  /// No description provided for @facetAlternateArts.
  ///
  /// In en, this message translates to:
  /// **'Alternate arts'**
  String get facetAlternateArts;

  /// No description provided for @facetRangeExact.
  ///
  /// In en, this message translates to:
  /// **'{label} {value}'**
  String facetRangeExact(String label, int value);

  /// No description provided for @facetRangeBetween.
  ///
  /// In en, this message translates to:
  /// **'{label} {min}-{max}'**
  String facetRangeBetween(String label, int min, int max);

  /// No description provided for @facetRangeFrom.
  ///
  /// In en, this message translates to:
  /// **'{label} {min}+'**
  String facetRangeFrom(String label, int min);

  /// No description provided for @facetRangeUpTo.
  ///
  /// In en, this message translates to:
  /// **'{label} ≤{max}'**
  String facetRangeUpTo(String label, int max);

  /// No description provided for @cardLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load card'**
  String get cardLoadError;

  /// No description provided for @cardNotFound.
  ///
  /// In en, this message translates to:
  /// **'Card not found'**
  String get cardNotFound;

  /// No description provided for @cardNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'It may have been removed in the last card update.'**
  String get cardNotFoundMessage;

  /// No description provided for @cardAddToDeck.
  ///
  /// In en, this message translates to:
  /// **'Add to deck'**
  String get cardAddToDeck;

  /// No description provided for @cardEffect.
  ///
  /// In en, this message translates to:
  /// **'Effect'**
  String get cardEffect;

  /// No description provided for @cardSecurityEffect.
  ///
  /// In en, this message translates to:
  /// **'Security effect'**
  String get cardSecurityEffect;

  /// No description provided for @cardInheritedEffect.
  ///
  /// In en, this message translates to:
  /// **'Inherited effect'**
  String get cardInheritedEffect;

  /// No description provided for @cardInheritedEffects.
  ///
  /// In en, this message translates to:
  /// **'Inherited effects'**
  String get cardInheritedEffects;

  /// No description provided for @cardOriginalArt.
  ///
  /// In en, this message translates to:
  /// **'Original art'**
  String get cardOriginalArt;

  /// No description provided for @cardAlternateArt.
  ///
  /// In en, this message translates to:
  /// **'Alternate art {number}'**
  String cardAlternateArt(int number);

  /// No description provided for @cardBlock.
  ///
  /// In en, this message translates to:
  /// **'Block {block}'**
  String cardBlock(int block);

  /// No description provided for @cardDualBadge.
  ///
  /// In en, this message translates to:
  /// **'Dual card'**
  String get cardDualBadge;

  /// No description provided for @cardLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get cardLevel;

  /// No description provided for @cardPlayCost.
  ///
  /// In en, this message translates to:
  /// **'Play cost'**
  String get cardPlayCost;

  /// No description provided for @cardUseCost.
  ///
  /// In en, this message translates to:
  /// **'Use cost'**
  String get cardUseCost;

  /// No description provided for @cardDp.
  ///
  /// In en, this message translates to:
  /// **'DP'**
  String get cardDp;

  /// No description provided for @cardForm.
  ///
  /// In en, this message translates to:
  /// **'Form'**
  String get cardForm;

  /// No description provided for @cardAttribute.
  ///
  /// In en, this message translates to:
  /// **'Attribute'**
  String get cardAttribute;

  /// No description provided for @cardNotTournamentLegal.
  ///
  /// In en, this message translates to:
  /// **'{limitation} — not tournament legal'**
  String cardNotTournamentLegal(String limitation);

  /// No description provided for @cardLimitedTo.
  ///
  /// In en, this message translates to:
  /// **'{limitation} to {count, plural, =1{{count} copy} other{{count} copies}}'**
  String cardLimitedTo(String limitation, int count);

  /// No description provided for @cardPairBanTitle.
  ///
  /// In en, this message translates to:
  /// **'Banned pair — playable, but not together'**
  String get cardPairBanTitle;

  /// No description provided for @cardPairBanOne.
  ///
  /// In en, this message translates to:
  /// **'A deck with this card cannot also run {partner}.'**
  String cardPairBanOne(String partner);

  /// No description provided for @cardPairBanMany.
  ///
  /// In en, this message translates to:
  /// **'A deck with this card cannot also run any of {partners}.'**
  String cardPairBanMany(String partners);

  /// No description provided for @cardRaisedCopyLimit.
  ///
  /// In en, this message translates to:
  /// **'A deck may run up to {limit} copies of this card.'**
  String cardRaisedCopyLimit(int limit);

  /// No description provided for @cardDigivolveTitle.
  ///
  /// In en, this message translates to:
  /// **'Digivolution requirements'**
  String get cardDigivolveTitle;

  /// No description provided for @cardDigivolveFromText.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The last condition is printed in the card’s effect box, not in its cost box.} other{The last {count} conditions are printed in the card’s effect box, not in its cost box.}}'**
  String cardDigivolveFromText(int count);

  /// No description provided for @cardLevelUnpublished.
  ///
  /// In en, this message translates to:
  /// **'Level not published yet'**
  String get cardLevelUnpublished;

  /// No description provided for @cardConditionUnpublished.
  ///
  /// In en, this message translates to:
  /// **'Condition not published yet'**
  String get cardConditionUnpublished;

  /// No description provided for @cardCostValue.
  ///
  /// In en, this message translates to:
  /// **'Cost {cost}'**
  String cardCostValue(int cost);

  /// No description provided for @cardOtherFace.
  ///
  /// In en, this message translates to:
  /// **'Other face — {category}'**
  String cardOtherFace(String category);

  /// No description provided for @cardErrata.
  ///
  /// In en, this message translates to:
  /// **'Errata'**
  String get cardErrata;

  /// No description provided for @cardErrataDated.
  ///
  /// In en, this message translates to:
  /// **'Errata · {date}'**
  String cardErrataDated(String date);

  /// No description provided for @cardErrataPrinted.
  ///
  /// In en, this message translates to:
  /// **'Printed'**
  String get cardErrataPrinted;

  /// No description provided for @cardErrataShouldRead.
  ///
  /// In en, this message translates to:
  /// **'Should read'**
  String get cardErrataShouldRead;

  /// No description provided for @cardFoundIn.
  ///
  /// In en, this message translates to:
  /// **'Found in'**
  String get cardFoundIn;

  /// Section heading for official Q&A about the card. Rulings is used untranslated by Spanish-speaking players.
  ///
  /// In en, this message translates to:
  /// **'Rulings ({count})'**
  String cardRulings(int count);

  /// No description provided for @cardPreviewNotice.
  ///
  /// In en, this message translates to:
  /// **'Preview card from a set that is not in the main card database yet. Its text is community-sourced and may change, and it has no rulings or alternate arts here.'**
  String get cardPreviewNotice;

  /// No description provided for @digivolveLevel.
  ///
  /// In en, this message translates to:
  /// **'Lv.{level}'**
  String digivolveLevel(int level);

  /// An Appmon grade, e.g. Standard Appmon. The grade itself is card text.
  ///
  /// In en, this message translates to:
  /// **'{grade} Appmon'**
  String digivolveAppmonGrade(String grade);

  /// No description provided for @digivolveAnyColor.
  ///
  /// In en, this message translates to:
  /// **'any colour'**
  String get digivolveAnyColor;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Data & credits'**
  String get creditsTitle;

  /// No description provided for @creditsArtworkTitle.
  ///
  /// In en, this message translates to:
  /// **'Card artwork and card text'**
  String get creditsArtworkTitle;

  /// No description provided for @creditsArtworkBody.
  ///
  /// In en, this message translates to:
  /// **'All card images, card text and related imagery are the intellectual property of © Akiyoshi Hongo, Toei Animation and © BANDAI. Their copyrights, trademarks and related rights apply.\n\nDigiCard App is a fan-made tool. It is not affiliated with, endorsed by, or connected to Bandai Namco Entertainment or Toei Animation.'**
  String get creditsArtworkBody;

  /// No description provided for @creditsHeroiTitle.
  ///
  /// In en, this message translates to:
  /// **'Card data — Heroicc'**
  String get creditsHeroiTitle;

  /// No description provided for @creditsHeroiBody.
  ///
  /// In en, this message translates to:
  /// **'The card database, expansion list and rulings come from the Heroicc API.\n\nDigiCard App is not affiliated with, endorsed by, or connected to Heroicc. Original content provided by Heroicc — that is, the parts not owned by Akiyoshi Hongo, Toei Animation or BANDAI — is used under the Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International licence (CC BY-NC-SA 4.0).'**
  String get creditsHeroiBody;

  /// No description provided for @creditsPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Preview sets — {source}'**
  String creditsPreviewTitle(String source);

  /// No description provided for @creditsPreviewBody.
  ///
  /// In en, this message translates to:
  /// **'A set the Heroicc API has not published yet is filled in from the digimoncard.io public API so its cards can be searched and built with early. Those sets are marked PREVIEW wherever they appear.\n\nDigiCard App is not affiliated with, endorsed by, or connected to digimoncard.io. Preview data is community-maintained and still changing: expect gaps and corrections, and check anything that matters against the printed card.'**
  String get creditsPreviewBody;

  /// No description provided for @creditsImagesTitle.
  ///
  /// In en, this message translates to:
  /// **'How this app treats card images'**
  String get creditsImagesTitle;

  /// No description provided for @creditsImagesBody.
  ///
  /// In en, this message translates to:
  /// **'Card images are shown and exported whole. The app does not crop or cover the copyright line or the artist name, and adds no watermark, stamp or logo of its own to a card image.'**
  String get creditsImagesBody;

  /// No description provided for @creditsCachingTitle.
  ///
  /// In en, this message translates to:
  /// **'Caching'**
  String get creditsCachingTitle;

  /// No description provided for @creditsCachingBody.
  ///
  /// In en, this message translates to:
  /// **'The full card list is downloaded once and kept on your device, so browsing and deck building make no further requests. Both APIs ask callers to cache rather than re-fetch, and to identify themselves; this app sends its own User-Agent on every request.'**
  String get creditsCachingBody;

  /// No description provided for @creditsFooter.
  ///
  /// In en, this message translates to:
  /// **'Card images and text © Akiyoshi Hongo, Toei Animation, © BANDAI. Card data from Heroicc and {source}. DigiCard App is a fan project, not affiliated with any of them.'**
  String creditsFooter(String source);

  /// No description provided for @issueMainDeckShort.
  ///
  /// In en, this message translates to:
  /// **'{missing, plural, =1{Main deck needs 1 more card ({size} required).} other{Main deck needs {missing} more cards ({size} required).}}'**
  String issueMainDeckShort(int missing, int size);

  /// No description provided for @issueMainDeckOver.
  ///
  /// In en, this message translates to:
  /// **'{excess, plural, =1{Main deck is over by 1 card ({size} allowed).} other{Main deck is over by {excess} cards ({size} allowed).}}'**
  String issueMainDeckOver(int excess, int size);

  /// No description provided for @issueEggDeckOver.
  ///
  /// In en, this message translates to:
  /// **'Egg deck is over by {excess} ({size} allowed).'**
  String issueEggDeckOver(int excess, int size);

  /// No description provided for @issueTooManyCopies.
  ///
  /// In en, this message translates to:
  /// **'{name} ({number}): {quantity} copies, max {limit}.'**
  String issueTooManyCopies(
    String name,
    String number,
    int quantity,
    int limit,
  );

  /// limitation is the lowercased restriction type, e.g. restricted.
  ///
  /// In en, this message translates to:
  /// **'{name} ({number}) is {limitation} to {limit, plural, =1{1 copy} other{{limit} copies}}; deck has {quantity}.'**
  String issueTooManyCopiesLimited(
    String name,
    String number,
    String limitation,
    int limit,
    int quantity,
  );

  /// No description provided for @issueBannedPair.
  ///
  /// In en, this message translates to:
  /// **'{name} ({number}) and {partnerName} ({partnerNumber}) are a banned pair; a deck may run either one, not both.'**
  String issueBannedPair(
    String name,
    String number,
    String partnerName,
    String partnerNumber,
  );

  /// No description provided for @issueToken.
  ///
  /// In en, this message translates to:
  /// **'{name} ({number}) is a token. Tokens are created during play and cannot be part of a deck.'**
  String issueToken(String name, String number);

  /// No description provided for @issueEmptyEggDeck.
  ///
  /// In en, this message translates to:
  /// **'Egg deck is empty. Most decks run 4-5 Digi-Eggs.'**
  String get issueEmptyEggDeck;

  /// Deck section heading; the card type as printed, left in English.
  ///
  /// In en, this message translates to:
  /// **'Digi-Eggs'**
  String get sectionDigiEggs;

  /// Deck section heading; the card type as printed, left in English.
  ///
  /// In en, this message translates to:
  /// **'Digimon'**
  String get sectionDigimon;

  /// Deck section heading; the card type as printed, left in English.
  ///
  /// In en, this message translates to:
  /// **'Tamers'**
  String get sectionTamers;

  /// Deck section heading; the card type as printed, left in English.
  ///
  /// In en, this message translates to:
  /// **'Options'**
  String get sectionOptions;

  /// No description provided for @sectionWithLevel.
  ///
  /// In en, this message translates to:
  /// **'{section} · Lv.{level}'**
  String sectionWithLevel(String section, int level);

  /// No description provided for @decksTitle.
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get decksTitle;

  /// Tab holding the user's reusable card lists.
  ///
  /// In en, this message translates to:
  /// **'Staples'**
  String get decksTabStaples;

  /// No description provided for @decksImportDeck.
  ///
  /// In en, this message translates to:
  /// **'Import deck list'**
  String get decksImportDeck;

  /// No description provided for @decksImportStaples.
  ///
  /// In en, this message translates to:
  /// **'Import staple list'**
  String get decksImportStaples;

  /// No description provided for @decksNewDeck.
  ///
  /// In en, this message translates to:
  /// **'New deck'**
  String get decksNewDeck;

  /// No description provided for @decksNewList.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get decksNewList;

  /// No description provided for @decksLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load decks'**
  String get decksLoadError;

  /// No description provided for @decksEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No decks yet'**
  String get decksEmptyTitle;

  /// No description provided for @decksEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Build a deck of 50 cards plus up to 5 Digi-Eggs. Every deck keeps its own revisions, so you can try changes without losing what worked.'**
  String get decksEmptyMessage;

  /// No description provided for @decksCreateFirst.
  ///
  /// In en, this message translates to:
  /// **'Create your first deck'**
  String get decksCreateFirst;

  /// No description provided for @decksSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search decks'**
  String get decksSearchHint;

  /// No description provided for @decksNoMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'No decks match'**
  String get decksNoMatchTitle;

  /// No description provided for @decksNoMatchMessage.
  ///
  /// In en, this message translates to:
  /// **'Nothing here is called \"{query}\".'**
  String decksNoMatchMessage(String query);

  /// No description provided for @deckRevisionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 revision} other{{count} revisions}}'**
  String deckRevisionCount(int count);

  /// No description provided for @deckRevisionWithCount.
  ///
  /// In en, this message translates to:
  /// **'{name} · {count, plural, =1{1 revision} other{{count} revisions}}'**
  String deckRevisionWithCount(String name, int count);

  /// No description provided for @deckNoRevisions.
  ///
  /// In en, this message translates to:
  /// **'No revisions'**
  String get deckNoRevisions;

  /// No description provided for @actionRename.
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get actionRename;

  /// No description provided for @actionDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// No description provided for @actionCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// No description provided for @actionSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// No description provided for @deckRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename deck'**
  String get deckRenameTitle;

  /// No description provided for @deckNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Deck name'**
  String get deckNameLabel;

  /// No description provided for @dialogNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get dialogNameLabel;

  /// No description provided for @deckDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String deckDeleteTitle(String name);

  /// No description provided for @deckDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The deck and its 1 revision are removed. This cannot be undone.} other{The deck and all {count} of its revisions are removed. This cannot be undone.}}'**
  String deckDeleteBody(int count);

  /// Label next to the main deck's card count.
  ///
  /// In en, this message translates to:
  /// **'Main'**
  String get deckCountMain;

  /// Label next to the egg deck's card count.
  ///
  /// In en, this message translates to:
  /// **'Eggs'**
  String get deckCountEggs;

  /// No description provided for @deckLegal.
  ///
  /// In en, this message translates to:
  /// **'Legal'**
  String get deckLegal;

  /// No description provided for @deckDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get deckDraft;

  /// No description provided for @thumbnailTitle.
  ///
  /// In en, this message translates to:
  /// **'Deck thumbnail'**
  String get thumbnailTitle;

  /// No description provided for @thumbnailSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The card that stands for this deck in the deck list.'**
  String get thumbnailSubtitle;

  /// No description provided for @thumbnailEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to pick yet'**
  String get thumbnailEmptyTitle;

  /// No description provided for @thumbnailEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add cards to this revision first.'**
  String get thumbnailEmptyMessage;

  /// No description provided for @thumbnailAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Choose automatically'**
  String get thumbnailAutomatic;

  /// No description provided for @thumbnailAutomaticNamed.
  ///
  /// In en, this message translates to:
  /// **'Choose automatically ({name})'**
  String thumbnailAutomaticNamed(String name);

  /// No description provided for @stapleSourceTitle.
  ///
  /// In en, this message translates to:
  /// **'Build from a staple list'**
  String get stapleSourceTitle;

  /// No description provided for @stapleSourceEmpty.
  ///
  /// In en, this message translates to:
  /// **'You have no lists yet. Build one under Decks · Staples.'**
  String get stapleSourceEmpty;

  /// No description provided for @stapleSourceHint.
  ///
  /// In en, this message translates to:
  /// **'Opens the card picker showing just that list.'**
  String get stapleSourceHint;

  /// No description provided for @cardCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}}'**
  String cardCount(int count);

  /// No description provided for @deckLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load deck'**
  String get deckLoadError;

  /// No description provided for @deckNotFound.
  ///
  /// In en, this message translates to:
  /// **'Deck not found'**
  String get deckNotFound;

  /// No description provided for @deckNotFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'It may have been deleted.'**
  String get deckNotFoundMessage;

  /// No description provided for @deckEditing.
  ///
  /// In en, this message translates to:
  /// **'Editing {revision}'**
  String deckEditing(String revision);

  /// No description provided for @deckMenuRename.
  ///
  /// In en, this message translates to:
  /// **'Rename deck'**
  String get deckMenuRename;

  /// No description provided for @deckMenuThumbnail.
  ///
  /// In en, this message translates to:
  /// **'Deck thumbnail'**
  String get deckMenuThumbnail;

  /// No description provided for @deckMenuTestHand.
  ///
  /// In en, this message translates to:
  /// **'Test hand'**
  String get deckMenuTestHand;

  /// No description provided for @deckMenuExport.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get deckMenuExport;

  /// No description provided for @deckMenuClear.
  ///
  /// In en, this message translates to:
  /// **'Clear {revision}'**
  String deckMenuClear(String revision);

  /// No description provided for @deckMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete deck'**
  String get deckMenuDelete;

  /// No description provided for @deckTabCards.
  ///
  /// In en, this message translates to:
  /// **'Cards'**
  String get deckTabCards;

  /// No description provided for @deckTabRevisions.
  ///
  /// In en, this message translates to:
  /// **'Revisions ({count})'**
  String deckTabRevisions(int count);

  /// No description provided for @deckTabStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get deckTabStats;

  /// No description provided for @deckAddCards.
  ///
  /// In en, this message translates to:
  /// **'Add cards'**
  String get deckAddCards;

  /// No description provided for @deckNoRevisionsTitle.
  ///
  /// In en, this message translates to:
  /// **'This deck has no revisions'**
  String get deckNoRevisionsTitle;

  /// No description provided for @deckNoRevisionsMessage.
  ///
  /// In en, this message translates to:
  /// **'Create one to start adding cards.'**
  String get deckNoRevisionsMessage;

  /// No description provided for @deckClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear {revision}?'**
  String deckClearTitle(String revision);

  /// No description provided for @deckClearMessage.
  ///
  /// In en, this message translates to:
  /// **'Removes every card from this revision. Other revisions keep their cards.'**
  String get deckClearMessage;

  /// No description provided for @actionClearConfirm.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get actionClearConfirm;

  /// No description provided for @revisionLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load this revision'**
  String get revisionLoadError;

  /// No description provided for @revisionEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'This revision is empty'**
  String get revisionEmptyTitle;

  /// No description provided for @revisionEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add 50 cards to the main deck and up to 5 Digi-Eggs to the egg deck. A deck with nothing in it is not kept, so leaving now is the same as never having made it.'**
  String get revisionEmptyMessage;

  /// Button that opens the card's own page from a deck tile.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get deckCardTileBadge;

  /// No description provided for @statsLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not analyse this revision'**
  String get statsLoadError;

  /// No description provided for @statsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to analyse yet'**
  String get statsEmptyTitle;

  /// No description provided for @statsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add cards to see the curve and colour balance.'**
  String get statsEmptyMessage;

  /// No description provided for @statsCurveTitle.
  ///
  /// In en, this message translates to:
  /// **'Cost curve'**
  String get statsCurveTitle;

  /// No description provided for @statsCurveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Play cost of main deck cards'**
  String get statsCurveSubtitle;

  /// No description provided for @statsLevelTitle.
  ///
  /// In en, this message translates to:
  /// **'Level spread'**
  String get statsLevelTitle;

  /// No description provided for @statsLevelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Levels in the main deck'**
  String get statsLevelSubtitle;

  /// No description provided for @statsColorTitle.
  ///
  /// In en, this message translates to:
  /// **'Colour balance'**
  String get statsColorTitle;

  /// No description provided for @statsColorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Cards of each colour, counting duals twice'**
  String get statsColorSubtitle;

  /// No description provided for @statsLegal.
  ///
  /// In en, this message translates to:
  /// **'Tournament legal'**
  String get statsLegal;

  /// No description provided for @statsNotLegal.
  ///
  /// In en, this message translates to:
  /// **'Not legal yet'**
  String get statsNotLegal;

  /// No description provided for @statsDeckCounts.
  ///
  /// In en, this message translates to:
  /// **'{main}/{mainSize} · {eggs}/{eggSize}'**
  String statsDeckCounts(int main, int mainSize, int eggs, int eggSize);

  /// No description provided for @statsNoCosts.
  ///
  /// In en, this message translates to:
  /// **'No cards with a cost yet'**
  String get statsNoCosts;

  /// No description provided for @statsNoColors.
  ///
  /// In en, this message translates to:
  /// **'No colours yet'**
  String get statsNoColors;

  /// No description provided for @revisionsExplainer.
  ///
  /// In en, this message translates to:
  /// **'The active revision is the one you edit. Branch a new revision to experiment while keeping the current list intact.'**
  String get revisionsExplainer;

  /// No description provided for @revisionsBranch.
  ///
  /// In en, this message translates to:
  /// **'Branch active'**
  String get revisionsBranch;

  /// No description provided for @revisionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Empty'**
  String get revisionsEmpty;

  /// No description provided for @revisionBranchTitle.
  ///
  /// In en, this message translates to:
  /// **'Branch from {name}'**
  String revisionBranchTitle(String name);

  /// No description provided for @revisionBranchHelper.
  ///
  /// In en, this message translates to:
  /// **'Copies the cards in {name}'**
  String revisionBranchHelper(String name);

  /// No description provided for @revisionNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Revision name'**
  String get revisionNameLabel;

  /// No description provided for @actionCreate.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get actionCreate;

  /// No description provided for @revisionNewEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'New empty revision'**
  String get revisionNewEmptyTitle;

  /// No description provided for @revisionSummary.
  ///
  /// In en, this message translates to:
  /// **'{main} main · {eggs} eggs · {date}'**
  String revisionSummary(int main, int eggs, String date);

  /// No description provided for @actionDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get actionDuplicate;

  /// No description provided for @revisionRenameTitle.
  ///
  /// In en, this message translates to:
  /// **'Rename revision'**
  String get revisionRenameTitle;

  /// No description provided for @revisionDuplicateTitle.
  ///
  /// In en, this message translates to:
  /// **'Duplicate {name}'**
  String revisionDuplicateTitle(String name);

  /// No description provided for @revisionCopyName.
  ///
  /// In en, this message translates to:
  /// **'{name} copy'**
  String revisionCopyName(String name);

  /// No description provided for @revisionDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String revisionDeleteTitle(String name);

  /// No description provided for @revisionDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'The cards in this revision are removed. Other revisions of the deck are not affected.'**
  String get revisionDeleteBody;

  /// No description provided for @pickerCopyCapped.
  ///
  /// In en, this message translates to:
  /// **'{name} is {limitation} to {limit, plural, =1{1 copy} other{{limit} copies}}.'**
  String pickerCopyCapped(String name, String limitation, int limit);

  /// No description provided for @pickerBannedPairWarning.
  ///
  /// In en, this message translates to:
  /// **'{name} is a banned pair with {partners}. A deck may run either, not both.'**
  String pickerBannedPairWarning(String name, String partners);

  /// No description provided for @pickerSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Add cards…'**
  String get pickerSearchHint;

  /// No description provided for @pickerNoCardsFiltered.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or clear the filters.'**
  String get pickerNoCardsFiltered;

  /// No description provided for @pickerNoCardsInList.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this list matches. Try another source, search or filter.'**
  String get pickerNoCardsInList;

  /// No description provided for @pickerAllCards.
  ///
  /// In en, this message translates to:
  /// **'All cards'**
  String get pickerAllCards;

  /// No description provided for @pickerListChip.
  ///
  /// In en, this message translates to:
  /// **'{name} · {count}'**
  String pickerListChip(String name, int count);

  /// No description provided for @pickerMainDeck.
  ///
  /// In en, this message translates to:
  /// **'Main deck'**
  String get pickerMainDeck;

  /// No description provided for @pickerEggDeck.
  ///
  /// In en, this message translates to:
  /// **'Egg deck'**
  String get pickerEggDeck;

  /// No description provided for @pickerTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap a card to set copies'**
  String get pickerTapHint;

  /// No description provided for @addToDeckTokenBlocked.
  ///
  /// In en, this message translates to:
  /// **'Tokens are created during play and cannot go in a deck.'**
  String get addToDeckTokenBlocked;

  /// No description provided for @addToDeckTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to deck'**
  String get addToDeckTitle;

  /// No description provided for @addToDeckCardLine.
  ///
  /// In en, this message translates to:
  /// **'{name} · {number}'**
  String addToDeckCardLine(String name, String number);

  /// No description provided for @addToDeckEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Create a deck to start adding cards to it.'**
  String get addToDeckEmptyMessage;

  /// No description provided for @addToDeckNewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a deck with this card'**
  String get addToDeckNewSubtitle;

  /// No description provided for @addToDeckAdded.
  ///
  /// In en, this message translates to:
  /// **'Added {name} to {deck}'**
  String addToDeckAdded(String name, String deck);

  /// No description provided for @addToDeckAddedWithPair.
  ///
  /// In en, this message translates to:
  /// **'Added {name} to {deck} — banned pair with {partners}'**
  String addToDeckAddedWithPair(String name, String deck, String partners);

  /// No description provided for @handTitle.
  ///
  /// In en, this message translates to:
  /// **'Test hand'**
  String get handTitle;

  /// No description provided for @handNotFullTitle.
  ///
  /// In en, this message translates to:
  /// **'Not a full deck yet'**
  String get handNotFullTitle;

  /// No description provided for @handNotFullMessage.
  ///
  /// In en, this message translates to:
  /// **'A test hand is dealt off the {size} cards of the main deck, which the Digi-Eggs are not part of. This revision has {count} of {size}.'**
  String handNotFullMessage(int count, int size);

  /// No description provided for @handOpeningTitle.
  ///
  /// In en, this message translates to:
  /// **'Opening hand'**
  String get handOpeningTitle;

  /// No description provided for @handOpeningSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The 5 cards you draw'**
  String get handOpeningSubtitle;

  /// No description provided for @handSecurityTitle.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get handSecurityTitle;

  /// No description provided for @handSecuritySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Top of the stack first'**
  String get handSecuritySubtitle;

  /// No description provided for @handTestAgain.
  ///
  /// In en, this message translates to:
  /// **'Test again'**
  String get handTestAgain;

  /// No description provided for @exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export'**
  String get exportTitle;

  /// No description provided for @exportTabImage.
  ///
  /// In en, this message translates to:
  /// **'Image'**
  String get exportTabImage;

  /// No description provided for @exportTabText.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get exportTabText;

  /// No description provided for @exportNothingTitle.
  ///
  /// In en, this message translates to:
  /// **'Nothing to export'**
  String get exportNothingTitle;

  /// No description provided for @exportNothingMessage.
  ///
  /// In en, this message translates to:
  /// **'This revision has no cards in it yet.'**
  String get exportNothingMessage;

  /// No description provided for @exportFallbackDeckName.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get exportFallbackDeckName;

  /// No description provided for @exportRenderFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not render the deck image.'**
  String get exportRenderFailed;

  /// No description provided for @exportNeedsPermission.
  ///
  /// In en, this message translates to:
  /// **'DigiCard needs permission to save to your gallery.'**
  String get exportNeedsPermission;

  /// No description provided for @exportSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved to your gallery.'**
  String get exportSaved;

  /// No description provided for @exportLoadingArt.
  ///
  /// In en, this message translates to:
  /// **'Loading card art…'**
  String get exportLoadingArt;

  /// No description provided for @exportLayoutHint.
  ///
  /// In en, this message translates to:
  /// **'{description}. Pinch to look closer — the saved image is full size.'**
  String exportLayoutHint(String description);

  /// No description provided for @exportSaving.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get exportSaving;

  /// No description provided for @exportSaveToGallery.
  ///
  /// In en, this message translates to:
  /// **'Save to gallery'**
  String get exportSaveToGallery;

  /// No description provided for @exportListCopied.
  ///
  /// In en, this message translates to:
  /// **'{format} list copied.'**
  String exportListCopied(String format);

  /// No description provided for @exportCopyToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copy to clipboard'**
  String get exportCopyToClipboard;

  /// No description provided for @layoutDetailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed'**
  String get layoutDetailed;

  /// No description provided for @layoutDetailedDescription.
  ///
  /// In en, this message translates to:
  /// **'Split into sections, 8 per row'**
  String get layoutDetailedDescription;

  /// No description provided for @layoutCompact.
  ///
  /// In en, this message translates to:
  /// **'Compact'**
  String get layoutCompact;

  /// No description provided for @layoutCompactDescription.
  ///
  /// In en, this message translates to:
  /// **'One grid, 7 per row'**
  String get layoutCompactDescription;

  /// No description provided for @listFormatStandard.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get listFormatStandard;

  /// Name of the Untap.in deck format; a product name, left as it is.
  ///
  /// In en, this message translates to:
  /// **'Untap'**
  String get listFormatUntap;

  /// No description provided for @importClipboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'The clipboard has no text in it.'**
  String get importClipboardEmpty;

  /// No description provided for @importDefaultDeckName.
  ///
  /// In en, this message translates to:
  /// **'Imported deck'**
  String get importDefaultDeckName;

  /// No description provided for @importDefaultShortName.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get importDefaultShortName;

  /// No description provided for @importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import deck list'**
  String get importTitle;

  /// No description provided for @importExplainer.
  ///
  /// In en, this message translates to:
  /// **'Paste a deck list in either format — \"4 Agumon BT1-010\" or \"4 Agumon (BT1-010)\". Headings and comments between the lines are ignored.'**
  String get importExplainer;

  /// No description provided for @importPaste.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get importPaste;

  /// No description provided for @importReading.
  ///
  /// In en, this message translates to:
  /// **'Reading…'**
  String get importReading;

  /// No description provided for @importReadList.
  ///
  /// In en, this message translates to:
  /// **'Read list'**
  String get importReadList;

  /// No description provided for @importNewDeck.
  ///
  /// In en, this message translates to:
  /// **'New deck'**
  String get importNewDeck;

  /// No description provided for @importNewRevision.
  ///
  /// In en, this message translates to:
  /// **'New revision'**
  String get importNewRevision;

  /// No description provided for @importNoDecks.
  ///
  /// In en, this message translates to:
  /// **'You have no decks to add a revision to yet.'**
  String get importNoDecks;

  /// No description provided for @importDeckField.
  ///
  /// In en, this message translates to:
  /// **'Deck'**
  String get importDeckField;

  /// No description provided for @importNothingRecognised.
  ///
  /// In en, this message translates to:
  /// **'No cards recognised in that list.'**
  String get importNothingRecognised;

  /// No description provided for @importSummary.
  ///
  /// In en, this message translates to:
  /// **'{cards} cards · {copies} copies'**
  String importSummary(int cards, int copies);

  /// No description provided for @importUnmatched.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 line could not be matched and will be left out:} other{{count} lines could not be matched and will be left out:}}'**
  String importUnmatched(int count);

  /// No description provided for @importAndMore.
  ///
  /// In en, this message translates to:
  /// **'…and {count} more'**
  String importAndMore(int count);

  /// No description provided for @stapleNotFound.
  ///
  /// In en, this message translates to:
  /// **'List not found'**
  String get stapleNotFound;

  /// No description provided for @stapleMenuRename.
  ///
  /// In en, this message translates to:
  /// **'Rename list'**
  String get stapleMenuRename;

  /// No description provided for @stapleMenuExport.
  ///
  /// In en, this message translates to:
  /// **'Export list'**
  String get stapleMenuExport;

  /// No description provided for @stapleMenuDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete list'**
  String get stapleMenuDelete;

  /// No description provided for @stapleAddCards.
  ///
  /// In en, this message translates to:
  /// **'Add cards'**
  String get stapleAddCards;

  /// No description provided for @stapleEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'This list is empty'**
  String get stapleEmptyTitle;

  /// No description provided for @stapleEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Add the cards you want at hand. They show up as a source in the deck builder, so you can drop them into a deck without going looking for them.'**
  String get stapleEmptyMessage;

  /// No description provided for @stapleMissingCards.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 more card is in this list but not in your library yet.} other{{count} more cards are in this list but not in your library yet.}}'**
  String stapleMissingCards(int count);

  /// No description provided for @stapleRemoved.
  ///
  /// In en, this message translates to:
  /// **'Removed {name}'**
  String stapleRemoved(String name);

  /// No description provided for @actionUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get actionUndo;

  /// No description provided for @stapleNameLabel.
  ///
  /// In en, this message translates to:
  /// **'List name'**
  String get stapleNameLabel;

  /// No description provided for @staplesLoadError.
  ///
  /// In en, this message translates to:
  /// **'Could not load your lists'**
  String get staplesLoadError;

  /// No description provided for @staplesEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No staple lists'**
  String get staplesEmptyTitle;

  /// No description provided for @staplesEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'A staple list is a set of cards you keep coming back to — the memory boosts, the floodgates, the tamers. Build one and it shows up as a source while you add cards to a deck.'**
  String get staplesEmptyMessage;

  /// No description provided for @staplesCreate.
  ///
  /// In en, this message translates to:
  /// **'Create a list'**
  String get staplesCreate;

  /// No description provided for @stapleNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New staple list'**
  String get stapleNewTitle;

  /// No description provided for @stapleDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}?'**
  String stapleDeleteTitle(String name);

  /// No description provided for @stapleDeleteBody.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{The list and the 1 card in it are removed. Your decks keep every card they already hold.} other{The list and the {count} cards in it are removed. Your decks keep every card they already hold.}}'**
  String stapleDeleteBody(int count);

  /// No description provided for @stapleNothingYet.
  ///
  /// In en, this message translates to:
  /// **'Nothing in this list yet.'**
  String get stapleNothingYet;

  /// No description provided for @stapleExportCopied.
  ///
  /// In en, this message translates to:
  /// **'{name} copied.'**
  String stapleExportCopied(String name);

  /// No description provided for @stapleExportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export {name}'**
  String stapleExportTitle(String name);

  /// No description provided for @stapleExportExplainer.
  ///
  /// In en, this message translates to:
  /// **'One line per card, the same shape a deck list takes, so the result reads in this app and in the tools that take deck lists.'**
  String get stapleExportExplainer;

  /// No description provided for @stapleExportEmpty.
  ///
  /// In en, this message translates to:
  /// **'This list has no cards in it yet.'**
  String get stapleExportEmpty;

  /// No description provided for @stapleExportMissing.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card is in this list but not in your library yet, so it is not written out.} other{{count} cards are in this list but not in your library yet, so they are not written out.}}'**
  String stapleExportMissing(int count);

  /// No description provided for @staplePickerHint.
  ///
  /// In en, this message translates to:
  /// **'Add cards to the list…'**
  String get staplePickerHint;

  /// No description provided for @staplePickerSummary.
  ///
  /// In en, this message translates to:
  /// **'{name} · {count, plural, =1{1 card} other{{count} cards}}'**
  String staplePickerSummary(String name, int count);

  /// No description provided for @staplePickerTapHint.
  ///
  /// In en, this message translates to:
  /// **'Tap to add or remove'**
  String get staplePickerTapHint;

  /// No description provided for @stapleImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import a staple list'**
  String get stapleImportTitle;

  /// No description provided for @stapleImportExplainer.
  ///
  /// In en, this message translates to:
  /// **'Paste a list of cards — the export from this app, or any deck list. Copies are ignored: a staple list holds each card once.'**
  String get stapleImportExplainer;

  /// No description provided for @stapleImportDestination.
  ///
  /// In en, this message translates to:
  /// **'Where it goes'**
  String get stapleImportDestination;

  /// No description provided for @stapleImportNewList.
  ///
  /// In en, this message translates to:
  /// **'New list'**
  String get stapleImportNewList;

  /// No description provided for @stapleImportAddToList.
  ///
  /// In en, this message translates to:
  /// **'Add to a list'**
  String get stapleImportAddToList;

  /// Example staple list name shown as a hint.
  ///
  /// In en, this message translates to:
  /// **'Blue tech'**
  String get stapleImportNameHint;

  /// No description provided for @stapleImportNoLists.
  ///
  /// In en, this message translates to:
  /// **'You have no lists to add to yet.'**
  String get stapleImportNoLists;

  /// No description provided for @stapleImportListField.
  ///
  /// In en, this message translates to:
  /// **'List'**
  String get stapleImportListField;

  /// No description provided for @stapleImportListOption.
  ///
  /// In en, this message translates to:
  /// **'{name} · {count}'**
  String stapleImportListOption(String name, int count);

  /// No description provided for @stapleImportButton.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Import 1 card} other{Import {count} cards}}'**
  String stapleImportButton(int count);

  /// No description provided for @stapleImportFound.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card found} other{{count} cards found}}'**
  String stapleImportFound(int count);

  /// No description provided for @stapleImportUnmatched.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 line matched no card and is left out:} other{{count} lines matched no card and are left out:}}'**
  String stapleImportUnmatched(int count);

  /// No description provided for @stapleImportAndMore.
  ///
  /// In en, this message translates to:
  /// **'and {count} more'**
  String stapleImportAndMore(int count);

  /// Name a deck is created with when the user does not supply one. Stored as typed, and renameable afterwards.
  ///
  /// In en, this message translates to:
  /// **'New Deck'**
  String get defaultDeckName;

  /// No description provided for @importImporting.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get importImporting;

  /// No description provided for @importAction.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get importAction;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
