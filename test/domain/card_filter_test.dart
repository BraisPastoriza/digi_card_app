import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/card_filter.dart';
import 'package:digi_card_app/domain/models/card_release.dart';
import 'package:digi_card_app/domain/models/digimon_card.dart';
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

  group('CardFilter.activeFacets', () {
    test('one chip per trait, each removing only itself', () {
      const filter = CardFilter(traits: {'Dragon', 'Vaccine'});
      final facets = filter.activeFacets();

      expect(facets.map((f) => f.label), ['Dragon', 'Vaccine']);
      expect(facets.first.removed.traits, {'Vaccine'});
      expect(facets.last.removed.traits, {'Dragon'});
    });

    test('an all-of set is one chip that comes off whole', () {
      const filter = CardFilter(
        traits: {'Dragon', 'Vaccine'},
        traitMatchMode: MatchMode.all,
      );
      final facets = filter.activeFacets();

      expect(facets.single.label, 'All of Dragon, Vaccine');
      expect(facets.single.removed.traits, isEmpty);
    });

    test('colours and levels read and clear as one condition each', () {
      const filter = CardFilter(
        colors: {CardColor.red, CardColor.blue},
        levels: {4, 3},
      );
      final facets = filter.activeFacets();

      expect(facets.map((f) => f.label), ['Any of Red, Blue', 'Lv. 3, 4']);
      expect(facets.first.removed.colors, isEmpty);
      expect(
        facets.first.removed.levels,
        {3, 4},
        reason: 'taking the colours off leaves the levels alone',
      );
      expect(facets.last.removed.levels, isEmpty);
    });

    test('a range and a flag clear themselves', () {
      const filter = CardFilter(
        dp: RangeFilter(min: 5000),
        restrictedOnly: true,
      );
      final facets = filter.activeFacets();

      expect(facets.map((f) => f.label), ['DP 5000+', 'Restricted']);
      expect(facets.first.removed.dp.isEmpty, isTrue);
      expect(facets.first.removed.restrictedOnly, isTrue);
      expect(facets.last.removed.restrictedOnly, isFalse);
    });

    test('removing the last facet leaves nothing but the query', () {
      const filter = CardFilter(query: 'greymon', keywords: {'Blocker'});
      final removed = filter.activeFacets().single.removed;

      expect(removed.activeFacetCount, 0);
      expect(removed.query, 'greymon');
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

  group('CardRelease.isOwnCardNumber', () {
    CardRelease release(String name, {String id = 'x'}) => CardRelease(
      id: id,
      name: name,
      group: ReleaseGroup.booster,
      cardCount: 0,
      sortIndex: 0,
    );

    test('separates a set own cards from the reprints it bundles', () {
      final bt25 = release('DUAL REVOLUTION [BT-25]');

      expect(bt25.isOwnCardNumber('BT25-001'), isTrue);
      expect(bt25.isOwnCardNumber('BT25-137'), isTrue);
      // The eight alternate arts BT-25 ships, which sort ahead of BT25-001
      // by printed number because 2 reads as less than 25.
      expect(bt25.isOwnCardNumber('BT2-047'), isFalse);
      expect(bt25.isOwnCardNumber('BT11-032'), isFalse);
      expect(bt25.isOwnCardNumber('ST24-01'), isFalse);
      expect(bt25.isOwnCardNumber('EX1-020'), isFalse);
    });

    test('lines up a set number written with a leading zero', () {
      final ad01 = release('DIGIMON GENERATION [AD-01]');

      expect(ad01.isOwnCardNumber('AD1-002'), isTrue);
      expect(ad01.isOwnCardNumber('BT21-046'), isFalse);
    });

    test('keeps the plain LM cards a Limited pack introduces', () {
      final lm08 = release('LIMITED CARD PACK FINAL CREST [LM-08]');

      expect(lm08.isOwnCardNumber('LM-057'), isTrue);
      expect(lm08.isOwnCardNumber('P-201'), isFalse);
      expect(lm08.isOwnCardNumber('BT11-023'), isFalse);
    });

    test('treats everything as its own when the name has no set code', () {
      final promos = release('All Promos');

      expect(promos.isOwnCardNumber('P-001'), isTrue);
      expect(promos.isOwnCardNumber('BT2-047'), isTrue);
    });
  });

  group('withOwnCardsFirst', () {
    DigimonCard card(String number) => DigimonCard(
      id: number,
      number: number,
      parallelId: 0,
      name: number,
      category: CardCategory.digimon,
      colors: const [CardColor.red],
      imageUrl: 'https://example.invalid/$number.webp',
    );

    test('moves the reprints after the set, keeping each order', () {
      final release = CardRelease(
        id: 'bt-25',
        name: 'DUAL REVOLUTION [BT-25]',
        group: ReleaseGroup.booster,
        cardCount: 0,
        sortIndex: 0,
      );
      // The order the card-number query returns them in.
      final cards = [
        card('BT2-047'),
        card('BT11-032'),
        card('BT25-001'),
        card('BT25-002'),
      ];

      expect(withOwnCardsFirst(cards, release).map((c) => c.number), [
        'BT25-001',
        'BT25-002',
        'BT2-047',
        'BT11-032',
      ]);
    });

    test('leaves a release with nothing to move untouched', () {
      final cards = [card('BT25-001'), card('BT25-002')];

      expect(
        withOwnCardsFirst(cards, null),
        same(cards),
        reason: 'no release to compare against',
      );
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

    test('files the Special Limited Set with the LM packs it is made of', () {
      expect(classifyRelease('special-limited-set'), ReleaseGroup.limited);
    });

    test('files the synthetic aggregates in the group they gather from', () {
      expect(classifyRelease(allPromosReleaseId), ReleaseGroup.promo);
      expect(classifyRelease(allLimitedReleaseId), ReleaseGroup.limited);
    });

    test('the preview sets land in the group their slug implies', () {
      for (final preview in previewReleases) {
        expect(
          classifyRelease(preview.id),
          isNot(ReleaseGroup.other),
          reason: preview.id,
        );
      }
      expect(classifyRelease('lm-08'), ReleaseGroup.limited);
      expect(classifyRelease('lm-09'), ReleaseGroup.limited);
      expect(classifyRelease('bt-26'), ReleaseGroup.booster);
      expect(classifyRelease('ex-13'), ReleaseGroup.ex);
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
