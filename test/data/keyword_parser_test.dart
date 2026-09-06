import 'package:digi_card_app/core/utils/keyword_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KeywordParser.normalize', () {
    test('keeps a plain keyword as-is', () {
      expect(KeywordParser.normalize('Blocker'), 'Blocker');
      expect(KeywordParser.normalize('Blast Digivolve'), 'Blast Digivolve');
    });

    test('drops the numeric modifier that varies per card', () {
      expect(KeywordParser.normalize('De-Digivolve 2'), 'De-Digivolve');
      expect(KeywordParser.normalize('DigiXros -2'), 'DigiXros');
      expect(KeywordParser.normalize('Link +1'), 'Link');
    });

    test('drops parenthetical and bracketed qualifiers', () {
      expect(KeywordParser.normalize('Overflow (-4)'), 'Overflow');
      expect(KeywordParser.normalize('Recovery +1 (Deck)'), 'Recovery');
      expect(KeywordParser.normalize('Recovery +1 ≪Deck≫'), 'Recovery');
    });

    test('drops per-card qualifiers that narrow a keyword', () {
      // Each of these would otherwise become its own filter chip.
      expect(KeywordParser.normalize('Decode ([Aegiomon])'), 'Decode');
      expect(KeywordParser.normalize('Decode《[Aegiomon]》'), 'Decode');
      expect(KeywordParser.normalize('Decode (Blue Lv.4)'), 'Decode');
      expect(KeywordParser.normalize('Decoy (Red/Black)'), 'Decoy');
      expect(KeywordParser.normalize('Fragment ≪3≫'), 'Fragment');
      expect(KeywordParser.normalize('Fragment 《3》'), 'Fragment');
      expect(KeywordParser.normalize('Digi-Burst up to 4'), 'Digi-Burst');
    });

    test('drops the joiner left behind by two qualifiers', () {
      // Stripping both parentheses out of "Decoy (Red)/(Black)" leaves a
      // trailing slash.
      expect(KeywordParser.normalize('Decoy (Red)/(Black)'), 'Decoy');
      expect(KeywordParser.normalize('Decoy(Red)/(Black)'), 'Decoy');
    });

    test('folds every spelling of Security Attack, keeping its direction', () {
      // The sign says what the card does; the number only says how much.
      const plus = [
        'Security Attack +1',
        'Security Attack +2',
        'Security A. +1',
        'Security A.+1',
        'Security A. +3',
        // The sign can appear with no number after it.
        'Security A. +',
      ];
      for (final variant in plus) {
        expect(
          KeywordParser.normalize(variant),
          'Security Attack +',
          reason: 'normalizing "$variant"',
        );
      }

      const minus = [
        'Security Attack -1',
        'Security Attack -3',
        'Security A. -2',
        'Security A. -',
        'S Attack -1',
      ];
      for (final variant in minus) {
        expect(
          KeywordParser.normalize(variant),
          'Security Attack -',
          reason: 'normalizing "$variant"',
        );
      }

      // Rules text that refers to the keyword without granting it.
      expect(KeywordParser.normalize('Security Attack'), 'Security Attack');
      expect(KeywordParser.normalize('Security A.'), 'Security Attack');
    });

    test('keeps magnitude-only keywords together', () {
      // Nobody filters for "De-Digivolve 2" as opposed to "De-Digivolve 3".
      expect(KeywordParser.normalize('De-Digivolve 2'), 'De-Digivolve');
      expect(KeywordParser.normalize('De-Digivolve 3'), 'De-Digivolve');
      expect(KeywordParser.normalize('Link +1'), 'Link');
      expect(KeywordParser.normalize('DigiXros -2'), 'DigiXros');
    });

    test('rejects structural markers that are not keywords', () {
      expect(KeywordParser.normalize('Rule'), isNull);
      expect(KeywordParser.normalize('Draw 1'), isNull);
    });

    test('strips a qualifier whose own brackets nest', () {
      // BT23-047 prints Partition with a qualifier inside a qualifier. A
      // pair-matching strip cuts at the inner closing bracket and leaves
      // "Partition blue Lv.5)" behind as a second, bogus keyword.
      expect(
        KeywordParser.normalize(
          'Partition (green Lv.5 (green Lv.5 & blue Lv.5) blue Lv.5)',
        ),
        'Partition',
      );
      expect(KeywordParser.normalize('Partition'), 'Partition');
      expect(
        KeywordParser.normalize('Partition (yellow Lv.6 & black Lv.6)'),
        'Partition',
      );
    });

    test('rejects sentence fragments picked up by the bracket match', () {
      expect(
        KeywordParser.normalize('this Digimon may attack the player'),
        isNull,
      );
    });
  });

  group('KeywordParser.extract', () {
    test('reads keywords out of real card text', () {
      const effect =
          '＜Blocker＞ (When an opponent\'s Digimon attacks, you may suspend '
          'this Digimon to force the attack to target it.)\n'
          '[When Digivolving] ＜Draw 1＞. Then gain ＜Security Attack +1＞.';

      expect(KeywordParser.extract([effect]), ['Blocker', 'Security Attack +']);
    });

    test('merges keywords across effect fields without duplicating', () {
      final keywords = KeywordParser.extract([
        '＜Blocker＞',
        '＜Rush＞ and ＜Blocker＞',
        null,
      ]);

      expect(keywords, ['Blocker', 'Rush']);
    });

    test('returns nothing for text without keywords', () {
      expect(KeywordParser.extract(['[Main] Gain 2 memory.']), isEmpty);
    });
  });
}
