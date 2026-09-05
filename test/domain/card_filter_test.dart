import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/card_filter.dart';
import 'package:digi_card_app/domain/models/card_release.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardFilter', () {
    test('two filters with equal facets are equal and hash alike', () {
      const a = CardFilter(
        query: 'greymon',
        colors: {CardColor.red, CardColor.blue},
        levels: {4, 5},
        playCost: RangeFilter(min: 3, max: 6),
      );
      const b = CardFilter(
        query: 'greymon',
        // Set literals in a different order must still compare equal, or the
        // live result count rebuilds its provider on every keystroke.
        colors: {CardColor.blue, CardColor.red},
        levels: {5, 4},
        playCost: RangeFilter(min: 3, max: 6),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('differing facets are not equal', () {
      const a = CardFilter(colors: {CardColor.red});
      const b = CardFilter(colors: {CardColor.blue});

      expect(a, isNot(b));
    });

    test('an untouched filter is empty', () {
      expect(const CardFilter().isEmpty, isTrue);
      expect(const CardFilter().activeFacetCount, 0);
    });

    test('counts each active facet once', () {
      const filter = CardFilter(
        query: 'ignored by the facet count',
        colors: {CardColor.red, CardColor.blue},
        categories: {CardCategory.digimon},
        dp: RangeFilter(min: 5000),
        restrictedOnly: true,
      );

      expect(filter.activeFacetCount, 4);
      expect(filter.isEmpty, isFalse);
    });

    test('clearing facets keeps the query and sort', () {
      const filter = CardFilter(
        query: 'agumon',
        sort: CardSort.dpDesc,
        colors: {CardColor.red},
      );
      final cleared = filter.clearedFacets();

      expect(cleared.query, 'agumon');
      expect(cleared.sort, CardSort.dpDesc);
      expect(cleared.colors, isEmpty);
    });
  });

  group('RangeFilter.describe', () {
    test('reads as a range, a floor, or a ceiling', () {
      expect(const RangeFilter(min: 3, max: 6).describe('Cost'), 'Cost 3-6');
      expect(const RangeFilter(min: 4, max: 4).describe('Cost'), 'Cost 4');
      expect(const RangeFilter(min: 4).describe('Cost'), 'Cost 4+');
      expect(const RangeFilter(max: 4).describe('Cost'), 'Cost ≤4');
    });
  });

  group('classifyRelease', () {
    test('sorts each product line into its own bucket', () {
      expect(classifyRelease('bt-25'), ReleaseGroup.booster);
      expect(classifyRelease('bt01-03-v1-0'), ReleaseGroup.booster);
      expect(classifyRelease('ex-12'), ReleaseGroup.ex);
      expect(classifyRelease('st-24'), ReleaseGroup.starter);
      expect(classifyRelease('ad-01'), ReleaseGroup.advanceDeck);
      expect(classifyRelease('lm-07'), ReleaseGroup.limited);
      expect(classifyRelease('rb-01'), ReleaseGroup.resurgence);
    });

    test('keeps promo buckets out of the numbered sets', () {
      expect(classifyRelease('p'), ReleaseGroup.promo);
      expect(classifyRelease('large-scale-tournaments'), ReleaseGroup.promo);
      // "store-events" starts with "st" but is not a starter deck.
      expect(classifyRelease('store-events'), ReleaseGroup.promo);
    });

    test('falls back to Other for unrecognised products', () {
      expect(classifyRelease('premium-binder-set'), ReleaseGroup.other);
      expect(classifyRelease('pb-21'), ReleaseGroup.other);
    });
  });

  group('CardRelease naming', () {
    test('splits the set code out of the printed name', () {
      const release = CardRelease(
        id: 'bt-25',
        name: 'DUAL REVOLUTION [BT-25]',
        group: ReleaseGroup.booster,
        cardCount: 145,
        sortIndex: 0,
        date: '2026-05-15',
      );

      expect(release.setCode, 'BT-25');
      expect(release.displayName, 'DUAL REVOLUTION');
      expect(release.releaseYear, '2026');
    });

    test('leaves a name without a set code alone', () {
      const release = CardRelease(
        id: 'store-events',
        name: 'Store Events',
        group: ReleaseGroup.promo,
        cardCount: 395,
        sortIndex: 1,
      );

      expect(release.setCode, isNull);
      expect(release.displayName, 'Store Events');
      expect(release.releaseYear, isNull);
    });
  });
}
