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

    test('folds every printed spelling of a keyword into one', () {
      // Card text spells this keyword eleven different ways across sets;
      // each one that survives becomes a duplicate filter chip.
      const variants = [
        'Security Attack',
        'Security Attack +1',
        'Security Attack -2',
        'Security A.',
        'Security A. +1',
        'Security A.+1',
        'Security A. -1',
        // The sign can appear with no number after it.
        'Security A. +',
        'Security A. -',
        'S Attack -1',
      ];
      for (final variant in variants) {
        expect(
          KeywordParser.normalize(variant),
          'Security Attack',
          reason: 'normalizing "$variant"',
        );
      }
    });

    test('rejects structural markers that are not keywords', () {
      expect(KeywordParser.normalize('Rule'), isNull);
      expect(KeywordParser.normalize('Draw 1'), isNull);
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

      expect(KeywordParser.extract([effect]), ['Blocker', 'Security Attack']);
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
