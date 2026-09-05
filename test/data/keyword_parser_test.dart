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

    test('folds the abbreviated form into the printed keyword', () {
      expect(KeywordParser.normalize('Security A. +1'), 'Security Attack');
      expect(KeywordParser.normalize('Security Attack -1'), 'Security Attack');
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
