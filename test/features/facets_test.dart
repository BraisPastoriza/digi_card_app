import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/card_filter.dart';
import 'package:digi_card_app/features/library/facets.dart';
import 'package:digi_card_app/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppLocalizations en;
  late AppLocalizations es;

  setUpAll(() async {
    en = await AppLocalizations.delegate.load(const Locale('en'));
    es = await AppLocalizations.delegate.load(const Locale('es'));
  });

  group('activeFacets', () {
    test('a card-number scope is not a facet', () {
      // The staple list being browsed is the source of the search, not a
      // filter the user picked.
      const scoped = CardFilter(cardNumbers: {'BT1-001', 'BT1-002'});

      expect(activeFacets(scoped, en), isEmpty);
    });

    test('one chip per trait, each removing only itself', () {
      const filter = CardFilter(traits: {'Dragon', 'Vaccine'});
      final facets = activeFacets(filter, en);

      expect(facets.map((f) => f.label), ['Dragon', 'Vaccine']);
      expect(facets.first.removed.traits, {'Vaccine'});
      expect(facets.last.removed.traits, {'Dragon'});
    });

    test('an all-of set is one chip that comes off whole', () {
      const filter = CardFilter(
        traits: {'Dragon', 'Vaccine'},
        traitMatchMode: MatchMode.all,
      );
      final facets = activeFacets(filter, en);

      expect(facets.single.label, 'All of Dragon, Vaccine');
      expect(facets.single.removed.traits, isEmpty);
    });

    test('colours and levels read and clear as one condition each', () {
      const filter = CardFilter(
        colors: {CardColor.red, CardColor.blue},
        levels: {4, 3},
      );
      final facets = activeFacets(filter, en);

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
      final facets = activeFacets(filter, en);

      expect(facets.map((f) => f.label), ['DP 5000+', 'Restricted']);
      expect(facets.first.removed.dp.isEmpty, isTrue);
      expect(facets.first.removed.restrictedOnly, isTrue);
      expect(facets.last.removed.restrictedOnly, isFalse);
    });

    test('a range reads as a range, a floor, or a ceiling', () {
      String dp(RangeFilter range) =>
          activeFacets(CardFilter(dp: range), en).single.label;

      expect(dp(const RangeFilter(min: 3, max: 6)), 'DP 3-6');
      expect(dp(const RangeFilter(min: 4, max: 4)), 'DP 4');
      expect(dp(const RangeFilter(min: 4)), 'DP 4+');
      expect(dp(const RangeFilter(max: 4)), 'DP ≤4');
    });

    test('removing the last facet leaves nothing but the query', () {
      const filter = CardFilter(query: 'greymon', keywords: {'Blocker'});
      final removed = activeFacets(filter, en).single.removed;

      expect(removed.activeFacetCount, 0);
      expect(removed.query, 'greymon');
    });

    test('what the chip says follows the reader, what it filters does not', () {
      const filter = CardFilter(
        colors: {CardColor.red},
        traits: {'Dragon'},
        restrictedOnly: true,
      );

      expect(activeFacets(filter, es).map((f) => f.label), [
        'Cualquiera de Rojo',
        // A trait is card text: it stays as the card prints it.
        'Dragon',
        'Restringida',
      ]);
      expect(
        activeFacets(filter, es).map((f) => f.removed.restrictedOnly),
        activeFacets(filter, en).map((f) => f.removed.restrictedOnly),
      );
    });
  });
}
