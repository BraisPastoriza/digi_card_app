import 'dart:convert';

import '../../domain/models/card_enums.dart';
import '../../domain/models/card_release.dart';
import '../../domain/models/digimon_card.dart';
import 'app_database.dart';
import 'tables.dart';

/// Converts rows from the local database into the domain models the UI uses.
///
/// Alternate art ids are not stored on the row; the library joins them in when
/// it needs them, so [toDigimonCard] takes them as a parameter.
extension CardRowMapper on CardRow {
  DigimonCard toDigimonCard({List<String> alternateArtIds = const []}) {
    return DigimonCard(
      id: id,
      number: number,
      parallelId: parallelId,
      name: name,
      category: CardCategory.tryParse(category) ?? CardCategory.digimon,
      colors: decodeList(
        colors,
      ).map(CardColor.tryParse).whereType<CardColor>().toList(),
      imageUrl: imageUrl,
      rarity: rarity,
      supplementalStars: supplementalStars,
      level: level,
      playCost: playCost,
      useCost: useCost,
      dp: dp,
      form: form,
      attribute: attribute,
      blockIcon: blockIcon,
      traits: decodeList(traits),
      keywords: decodeList(keywords),
      effect: effect,
      inheritedEffect: inheritedEffect,
      securityEffect: securityEffect,
      digivolutionRequirements: _decodeJsonList(
        digivolutionRequirements,
      ).map(DigivolveRequirement.fromJson).toList(),
      notes: notes,
      faqs: _decodeJsonList(faqs).map(CardFaq.fromJson).toList(),
      errata: errata == null
          ? null
          : CardErrata.fromJson(jsonDecode(errata!) as Map<String, dynamic>),
      limitations: _decodeJsonList(
        limitations,
      ).map(CardLimitation.fromJson).toList(),
      releaseIds: decodeList(releaseIds),
      alternateArtIds: alternateArtIds,
      dualFace: dualFace == null
          ? null
          : CardFace.fromJson(jsonDecode(dualFace!) as Map<String, dynamic>),
      isAce: isAce,
      ruleCopyLimit: ruleCopyLimit,
    );
  }
}

extension ReleaseRowMapper on ReleaseRow {
  CardRelease toCardRelease() => CardRelease(
    id: id,
    name: name,
    group: ReleaseGroup.values.firstWhere(
      (g) => g.name == groupName,
      orElse: () => ReleaseGroup.other,
    ),
    cardCount: cardCount,
    printingCount: printingCount,
    sortIndex: sortIndex,
    genre: genre,
    date: releaseDate,
    imageUrl: imageUrl,
    thumbnailUrl: thumbnailUrl,
    productUri: productUri,
    cardlistUri: cardlistUri,
  );
}

List<Map<String, dynamic>> _decodeJsonList(String? raw) {
  if (raw == null || raw.isEmpty || raw == '[]') return const [];
  final decoded = jsonDecode(raw);
  if (decoded is! List) return const [];
  return decoded.whereType<Map<String, dynamic>>().toList();
}
