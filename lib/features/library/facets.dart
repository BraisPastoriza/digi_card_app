import 'package:collection/collection.dart';

import '../../domain/models/card_filter.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';

/// One active facet as the results header shows it: what it says, and the
/// filter that remains once the user takes it off.
class FacetChip {
  const FacetChip(this.label, this.removed);

  final String label;

  /// The filter with this facet cleared, ready to be applied as-is.
  final CardFilter removed;
}

/// The active facets of [filter], each paired with the filter left behind when
/// it is taken off, so a chip in the results header can remove its own facet.
///
/// This lives beside the header that shows it rather than on [CardFilter]: the
/// chips are sentences in the reader's language, and a filter is not the place
/// to know what language that is.
///
/// Facets a card holds several of at once come off one value at a time — two
/// traits are two chips — while the ones that read as a single condition come
/// off whole: the colours, an "all of" set, a level list, a numeric range.
///
/// Expansions are the one active facet with no chip: they are picked by name
/// on a page of their own, and their ids do not read as anything here.
///
/// Traits, keywords, rarities, forms and attributes are card text, so they
/// appear as the card prints them whatever the interface language.
List<FacetChip> activeFacets(CardFilter filter, AppLocalizations l10n) => [
  if (filter.colors.isNotEmpty)
    FacetChip(
      '${filter.colorMatchMode.name(l10n)} '
      '${filter.colors.map((c) => c.name(l10n)).join(', ')}',
      filter.copyWith(colors: const {}),
    ),
  for (final category in filter.categories)
    FacetChip(
      category.name(l10n),
      filter.copyWith(categories: _without(filter.categories, category)),
    ),
  if (filter.levels.isNotEmpty)
    FacetChip(
      l10n.facetLevels(
        filter.levels.sorted((a, b) => a.compareTo(b)).join(', '),
      ),
      filter.copyWith(levels: const {}),
    ),
  for (final rarity in filter.rarities)
    FacetChip(
      rarity,
      filter.copyWith(rarities: _without(filter.rarities, rarity)),
    ),
  ..._valueFacets(
    filter.traits,
    filter.traitMatchMode,
    l10n,
    (next) => filter.copyWith(traits: next),
  ),
  ..._valueFacets(
    filter.keywords,
    filter.keywordMatchMode,
    l10n,
    (next) => filter.copyWith(keywords: next),
  ),
  for (final form in filter.forms)
    FacetChip(form, filter.copyWith(forms: _without(filter.forms, form))),
  for (final attribute in filter.attributes)
    FacetChip(
      attribute,
      filter.copyWith(attributes: _without(filter.attributes, attribute)),
    ),
  if (!filter.playCost.isEmpty)
    FacetChip(
      _range(filter.playCost, l10n.facetCost, l10n),
      filter.copyWith(playCost: const RangeFilter()),
    ),
  if (!filter.digivolveCost.isEmpty)
    FacetChip(
      _range(filter.digivolveCost, l10n.facetDigivolve, l10n),
      filter.copyWith(digivolveCost: const RangeFilter()),
    ),
  if (!filter.dp.isEmpty)
    FacetChip(
      _range(filter.dp, l10n.facetDp, l10n),
      filter.copyWith(dp: const RangeFilter()),
    ),
  if (filter.aceOnly) FacetChip('ACE', filter.copyWith(aceOnly: false)),
  if (filter.dualOnly)
    FacetChip(l10n.facetDualCard, filter.copyWith(dualOnly: false)),
  if (filter.tokens == TokenMode.only)
    FacetChip(l10n.facetToken, filter.copyWith(tokens: TokenMode.include)),
  if (filter.includeAlternateArts)
    FacetChip(
      l10n.facetAlternateArts,
      filter.copyWith(includeAlternateArts: false),
    ),
  if (filter.restrictedOnly)
    FacetChip(
      l10n.limitationRestricted,
      filter.copyWith(restrictedOnly: false),
    ),
];

/// One chip per value when any of them will do, and a single chip naming the
/// mode when every one of them is required — "All of Dragon, Vaccine" reads as
/// the one condition it is, so it comes off as one.
List<FacetChip> _valueFacets(
  Set<String> values,
  MatchMode mode,
  AppLocalizations l10n,
  CardFilter Function(Set<String>) replaced,
) => mode == MatchMode.all && values.length > 1
    ? [FacetChip('${mode.name(l10n)} ${values.join(', ')}', replaced(const {}))]
    : [
        for (final value in values)
          FacetChip(value, replaced(_without(values, value))),
      ];

String _range(RangeFilter range, String label, AppLocalizations l10n) {
  final (min, max) = (range.min, range.max);
  if (min != null && max != null) {
    return min == max
        ? l10n.facetRangeExact(label, min)
        : l10n.facetRangeBetween(label, min, max);
  }
  if (min != null) return l10n.facetRangeFrom(label, min);
  return l10n.facetRangeUpTo(label, max!);
}

Set<T> _without<T>(Set<T> values, T value) =>
    values.where((v) => v != value).toSet();
