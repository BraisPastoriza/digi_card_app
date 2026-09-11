import '../domain/models/card_enums.dart';
import '../domain/models/card_filter.dart';
import '../domain/models/deck_list.dart';
import '../domain/models/digimon_card.dart';
import '../features/deckbuilder/widgets/deck_sheet.dart';
import 'app_localizations.dart';

/// Reader-facing names for the values the card data is built out of.
///
/// The enums keep an English `label` of their own, which is what gets written
/// into exported deck lists and used as a key; these are what the interface
/// says. The split matters: a deck list has to read the same on anyone's
/// device, and a screen has to read in the language the device is set to.
///
/// Card text is not here. Names, effects, traits, keywords, rarities, forms
/// and attributes come from the card itself and stay in English whatever the
/// interface language, because that is the text printed on the card the player
/// is holding.
extension CardColorName on CardColor {
  String name(AppLocalizations l10n) => switch (this) {
    CardColor.red => l10n.colorRed,
    CardColor.blue => l10n.colorBlue,
    CardColor.yellow => l10n.colorYellow,
    CardColor.green => l10n.colorGreen,
    CardColor.black => l10n.colorBlack,
    CardColor.purple => l10n.colorPurple,
    CardColor.white => l10n.colorWhite,
  };
}

extension CardCategoryName on CardCategory {
  String name(AppLocalizations l10n) => switch (this) {
    CardCategory.digimon => l10n.categoryDigimon,
    CardCategory.tamer => l10n.categoryTamer,
    CardCategory.option => l10n.categoryOption,
    CardCategory.digiEgg => l10n.categoryDigiEgg,
  };
}

extension ReleaseGroupName on ReleaseGroup {
  String name(AppLocalizations l10n) => switch (this) {
    ReleaseGroup.booster => l10n.releaseGroupBooster,
    ReleaseGroup.ex => l10n.releaseGroupEx,
    ReleaseGroup.starter => l10n.releaseGroupStarter,
    ReleaseGroup.advanceDeck => l10n.releaseGroupAdvanceDeck,
    ReleaseGroup.limited => l10n.releaseGroupLimited,
    ReleaseGroup.resurgence => l10n.releaseGroupResurgence,
    ReleaseGroup.promo => l10n.releaseGroupPromo,
    ReleaseGroup.other => l10n.releaseGroupOther,
  };
}

extension LimitationTypeName on LimitationType {
  String name(AppLocalizations l10n) => switch (this) {
    LimitationType.restrict => l10n.limitationRestricted,
    LimitationType.ban => l10n.limitationBanned,
    LimitationType.bannedPair => l10n.limitationBannedPair,
    LimitationType.unrestrict => l10n.limitationUnrestricted,
  };
}

extension CardSortName on CardSort {
  String name(AppLocalizations l10n) => switch (this) {
    CardSort.number => l10n.sortCardNumber,
    CardSort.nameAsc => l10n.sortNameAsc,
    CardSort.costAsc => l10n.sortCostAsc,
    CardSort.costDesc => l10n.sortCostDesc,
    CardSort.dpDesc => l10n.sortDpDesc,
    CardSort.levelAsc => l10n.sortLevelAsc,
  };
}

extension ColorMatchModeName on ColorMatchMode {
  String name(AppLocalizations l10n) => switch (this) {
    ColorMatchMode.any => l10n.matchAnyOf,
    ColorMatchMode.all => l10n.matchAllOf,
    ColorMatchMode.exact => l10n.matchExactly,
  };
}

extension MatchModeName on MatchMode {
  String name(AppLocalizations l10n) => switch (this) {
    MatchMode.any => l10n.matchAnyOf,
    MatchMode.all => l10n.matchAllOf,
  };
}

extension DigivolveRequirementText on DigivolveRequirement {
  /// The condition in the reader's language, without the cost.
  ///
  /// A condition the source published as a sentence is card text and is shown
  /// as it came; only the ones this app assembles out of level, grade, colour
  /// and card type are put into words here. [describe] stays as the English
  /// form the parser keys conditions by, which must not move with the
  /// interface language.
  String describeIn(AppLocalizations l10n) {
    final printed = text;
    if (printed != null && printed.isNotEmpty) return printed;
    return [
      if (level != null) l10n.digivolveLevel(level!),
      if (form != null)
        l10n.digivolveAppmonGrade(
          '${form![0].toUpperCase()}${form!.substring(1)}',
        ),
      if (colors.isNotEmpty)
        if (isAnyColor)
          l10n.digivolveAnyColor
        else
          colors.map((c) => c.name(l10n)).join('/'),
      if (category != null && category != CardCategory.digimon)
        category!.name(l10n),
    ].join(' ');
  }
}

extension DeckListFormatName on DeckListFormat {
  String name(AppLocalizations l10n) => switch (this) {
    DeckListFormat.standard => l10n.listFormatStandard,
    DeckListFormat.untap => l10n.listFormatUntap,
  };
}

extension DeckSheetLayoutName on DeckSheetLayout {
  String name(AppLocalizations l10n) => switch (this) {
    DeckSheetLayout.detailed => l10n.layoutDetailed,
    DeckSheetLayout.compact => l10n.layoutCompact,
  };

  /// Not `description`: the enum already has a field by that name, which is
  /// the English text this replaces on screen.
  String summary(AppLocalizations l10n) => switch (this) {
    DeckSheetLayout.detailed => l10n.layoutDetailedDescription,
    DeckSheetLayout.compact => l10n.layoutCompactDescription,
  };
}
