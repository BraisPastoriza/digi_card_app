import 'package:digi_card_app/core/utils/digivolve_parser.dart';
import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/digimon_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('alternativesIn', () {
    test('reads the condition Coronamon BT25-008 prints in its effect box', () {
      final alternatives = DigivolveParser.alternativesIn(
        '[Digivolve] Lv.2 w/[TS] trait: Cost 0\n'
        '[When Moving] [On Play] By trashing up to 2 [Iliad] or [TS] trait '
        'cards from your hand, ＜Draw 1＞ for each card trashed.',
      );

      expect(alternatives, hasLength(1));
      expect(alternatives.single.describe(), 'Lv.2 w/[TS] trait');
      expect(alternatives.single.cost, 0);
      expect(alternatives.single.isAlternative, isTrue);
    });

    test('returns nothing for a card that prints no extra condition', () {
      expect(DigivolveParser.alternativesIn('[On Play] Draw 1 card.'), isEmpty);
      expect(DigivolveParser.alternativesIn(null), isEmpty);
    });

    test('splits a line that prints two conditions', () {
      final alternatives = DigivolveParser.alternativesIn(
        '[Digivolve] [Seraphimon]: Cost 1/[Sephirothmon] w/[Mercurymon] in '
        'digivolution cards: Cost 4',
      );

      expect(alternatives.map((r) => r.describe()), [
        '[Seraphimon]',
        '[Sephirothmon] w/[Mercurymon] in digivolution cards',
      ]);
      expect(alternatives.map((r) => r.cost), [1, 4]);
    });

    test('keeps a slash that joins traits inside one condition', () {
      final alternatives = DigivolveParser.alternativesIn(
        '[Digivolve] Lv.5 w/[X Antibody]/[DigiPolice] trait: Cost 4',
      );

      expect(alternatives, hasLength(1));
      expect(
        alternatives.single.describe(),
        'Lv.5 w/[X Antibody]/[DigiPolice] trait',
      );
      expect(alternatives.single.cost, 4);
    });

    test('reads the older cost-first form used by armour lines', () {
      final alternatives = DigivolveParser.alternativesIn(
        '[Digivolve] 2 from [Armadillomon]\n＜Armor Purge＞',
      );

      expect(alternatives.single.describe(), 'From [Armadillomon]');
      expect(alternatives.single.cost, 2);
    });

    test(
      'labels DNA and Burst conditions so they are not read as ordinary',
      () {
        final alternatives = DigivolveParser.alternativesIn(
          '[DNA Digivolve] Blue Lv.6 + red Lv.6: Cost 0 Digivolve unsuspended '
          'with the 2 specified Digimon stacked on top of each other.',
        );

        expect(
          alternatives.single.describe(),
          'DNA digivolve — Blue Lv.6 + red Lv.6',
        );
        expect(alternatives.single.cost, 0);
      },
    );

    test('separates a second marker glued onto the same line', () {
      // BT22-015 Omnimon prints its DNA condition on the [Digivolve] line.
      final alternatives = DigivolveParser.alternativesIn(
        '[Digivolve] Lv.6 w/[CS] trait: Cost 5 [DNA Digivolve] Lv.6 '
        'w/[Greymon] in name+Lv.6 w/[Garurumon] in name: Cost 0',
      );

      expect(alternatives.map((r) => r.describe()), [
        'Lv.6 w/[CS] trait',
        'DNA digivolve — Lv.6 w/[Greymon] in name+Lv.6 w/[Garurumon] in name',
      ]);
      expect(alternatives.map((r) => r.cost), [5, 0]);
    });

    test('does not print a flat cost the card qualifies', () {
      // BT24-101 charges "Cost 1 for each of your security cards"; showing
      // "Cost 1" next to it would be a lie about what it costs.
      final alternatives = DigivolveParser.alternativesIn(
        '[Digivolve] Lv.5 w/[Aegiochusmon] in name: Cost 1 for each of your '
        'security cards',
      );

      expect(alternatives.single.cost, isNull);
      expect(
        alternatives.single.describe(),
        'Lv.5 w/[Aegiochusmon] in name: Cost 1 for each of your security cards',
      );
    });

    test('drops the rules reminder printed after a DNA condition', () {
      final alternatives = DigivolveParser.alternativesIn(
        '[DNA Digivolve] [Apollomon] + [Dianamon]: Cost 0 Stack the 2 '
        'specified Digimon and digivolve unsuspended.',
      );

      expect(
        alternatives.single.describe(),
        'DNA digivolve — [Apollomon] + [Dianamon]',
      );
    });

    test('shows an unrecognised shape verbatim rather than dropping it', () {
      final alternatives = DigivolveParser.alternativesIn(
        '[Digivolve] Something nobody has printed yet',
      );

      expect(
        alternatives.single.describe(),
        'Something nobody has printed yet',
      );
      expect(alternatives.single.cost, isNull);
    });
  });

  group('allConditions', () {
    const printed = DigivolveRequirement(
      level: 2,
      cost: 0,
      category: CardCategory.digimon,
      colors: [CardColor.blue, CardColor.red],
    );

    test('lists the printed condition first, then the effect-box ones', () {
      final all = DigivolveParser.allConditions(
        printed: const [printed],
        effect: '[Digivolve] Lv.2 w/[TS] trait: Cost 0',
      );

      expect(all, hasLength(2));
      expect(all.first.isAlternative, isFalse);
      expect(all.first.level, 2);
      expect(all.last.isAlternative, isTrue);
      expect(all.last.describe(), 'Lv.2 w/[TS] trait');
    });

    test('leaves a card with no effect-box condition exactly as it was', () {
      expect(
        DigivolveParser.allConditions(
          printed: const [printed],
          effect: '[On Play] Draw 1 card.',
        ),
        hasLength(1),
      );
    });

    // The preview source publishes `evolution_cost` and leaves
    // `evolution_level` null on every card, so its structured requirement is a
    // cost with no condition attached.
    const costOnly = DigivolveRequirement(
      cost: 2,
      category: CardCategory.digimon,
    );

    // BT26-024 Tinkermon: the handful of preview rows that do publish
    // `evolution_color` still leave the level out, so the colour arrives on
    // its own.
    const colorOnly = DigivolveRequirement(
      cost: 0,
      category: CardCategory.digimon,
      colors: [CardColor.yellow],
    );

    test('a cost with no condition is not described as "Any"', () {
      expect(costOnly.describe(), isEmpty);
      expect(costOnly.isConditionUnpublished, isTrue);
    });

    test('a colour on its own is not a condition either', () {
      expect(colorOnly.isConditionUnpublished, isTrue);
    });

    test('a level or an Appmon grade is what makes it one', () {
      expect(printed.isConditionUnpublished, isFalse);
      expect(
        const DigivolveRequirement(
          form: 'ultimate',
          cost: 4,
          category: CardCategory.digimon,
          colors: [CardColor.red],
        ).isConditionUnpublished,
        isFalse,
      );
    });

    test('an unpublished cost keeps its own row beside the text one', () {
      // EX13-011 BaoHuckmon: evolution_cost 2 with no level or colour, and a
      // trait condition at the same cost in the card's text. The 36 BT-25
      // cards both sources carry show these are two different routes, so the
      // cost box keeps its row rather than borrowing the effect box's.
      final all = DigivolveParser.allConditions(
        printed: const [costOnly],
        effect: '[Digivolve] Lv.3 w/[Huckmon] in text: Cost 2',
      );

      expect(all, hasLength(2));
      expect(all.first.isConditionUnpublished, isTrue);
      expect(all.first.cost, 2);
      expect(all.last.describe(), 'Lv.3 w/[Huckmon] in text');
      expect(all.last.isAlternative, isTrue);
    });

    test('a cost-only row survives when the card spells nothing out', () {
      final all = DigivolveParser.allConditions(
        printed: const [costOnly],
        effect: '[On Play] Draw 1 card.',
      );

      expect(all, hasLength(1));
      expect(all.single.isConditionUnpublished, isTrue);
      expect(all.single.cost, 2);
    });

    test('a published colour is not answered by the text condition', () {
      // BT26-084 Copipemon: the cost box prints a purple condition at cost 0
      // and the effect box an [Appmon] trait one, also at cost 0. Both belong
      // to the card, and only the purple one's level is missing.
      final all = DigivolveParser.allConditions(
        printed: const [colorOnly],
        effect: '[Digivolve] Lv.2 w/[Appmon] trait: Cost 0',
      );

      expect(all, hasLength(2));
      expect(all.first.colors, [CardColor.yellow]);
      expect(all.first.isConditionUnpublished, isTrue);
      expect(all.last.describe(), 'Lv.2 w/[Appmon] trait');
      expect(all.last.isAlternative, isTrue);
    });

    test('a colour-only row survives when the card spells nothing out', () {
      final all = DigivolveParser.allConditions(
        printed: const [colorOnly],
        effect: '[On Play] Draw 1 card.',
      );

      expect(all, hasLength(1));
      expect(all.single.isConditionUnpublished, isTrue);
      expect(all.single.colors, [CardColor.yellow]);
    });

    test('the line the preview source repeats in two columns counts once', () {
      // Their `xros_req` and `alt_effect` carry the same digivolve line, and
      // the parser joins both into the effect text.
      final all = DigivolveParser.allConditions(
        printed: const [costOnly],
        effect:
            '[Digivolve] Lv.3 w/[Huckmon] in text: Cost 2\n'
            '[Digivolve] Lv.3 w/[Huckmon] in text: Cost 2',
      );

      expect(all, hasLength(2));
    });

    test('a full printed condition keeps the text one as an alternative', () {
      final all = DigivolveParser.allConditions(
        printed: const [printed],
        effect: '[Digivolve] Lv.2 w/[TS] trait: Cost 0',
      );

      expect(all, hasLength(2));
      expect(all.first.isAlternative, isFalse);
      expect(all.last.isAlternative, isTrue);
    });
  });

  group('describe', () {
    test(
      'leaves the cost out, because the card screen prints it alongside',
      () {
        const requirement = DigivolveRequirement(
          level: 3,
          cost: 2,
          category: CardCategory.digimon,
          colors: [CardColor.red],
        );

        expect(requirement.describe(), 'Lv.3 Red');
        expect(requirement.describe(), isNot(contains('cost')));
      },
    );

    test('names the Appmon grade a condition uses in place of a level', () {
      // BT21-018 DoGatchmon: Appmon digivolve by grade, and the grades share
      // their names with the Digimon forms.
      const requirement = DigivolveRequirement(
        form: 'standard',
        cost: 3,
        category: CardCategory.digimon,
        colors: [CardColor.red],
      );

      expect(requirement.describe(), 'Standard Appmon Red');
    });

    test('collapses the whole colour wheel to "any colour"', () {
      // BT16-082 Ukkomon and every Appmon grade: the source lists all seven
      // colours where the card prints "any colour".
      const requirement = DigivolveRequirement(
        level: 2,
        cost: 1,
        category: CardCategory.digimon,
        colors: CardColor.values,
      );

      expect(requirement.isAnyColor, isTrue);
      expect(requirement.describe(), 'Lv.2 any colour');
    });
  });
}
