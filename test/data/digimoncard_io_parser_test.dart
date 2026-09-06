import 'dart:convert';

import 'package:digi_card_app/data/sync/digimoncard_io_parser.dart';
import 'package:digi_card_app/domain/models/card_enums.dart';
import 'package:digi_card_app/domain/models/card_release.dart';
import 'package:flutter_test/flutter_test.dart';

const _release = PreviewRelease(
  id: 'bt-26',
  name: 'TIMELESS BONDS [BT-26]',
  pack: 'BT-26',
);

/// Rows copied from live digimoncard.io responses, trimmed to the columns the
/// parser reads. Keeping them verbatim is the point: this is the contract the
/// mapping is written against.
Map<String, dynamic> _row(Map<String, dynamic> overrides) => {
  'id': 'BT26-009',
  'name': 'Hyokomon',
  'type': 'Digimon',
  'level': 3,
  'play_cost': 3,
  'evolution_cost': 0,
  'evolution_color': 'Red',
  'evolution_level': 2,
  'xros_req': '',
  'color': 'Red',
  'color2': null,
  'digi_type': 'Bird',
  'digi_type2': 'Iliad',
  'digi_type3': null,
  'digi_type4': null,
  'digi_type5': null,
  'form': null,
  'stage': null,
  'dp': 2000,
  'attribute': 'Data',
  'rarity': 'U',
  'main_effect': '[Start of Your Main Phase] gain 1 memory.',
  'source_effect': '[When Attacking] [Once Per Turn] Draw 1.',
  'alt_effect': '',
  ...overrides,
};

void main() {
  group('parseDigimonCardIoPack', () {
    test('maps a Digimon row onto the shape the primary source produces', () {
      final card = parseDigimonCardIoPack([_row({})], _release).single;

      expect(card.id, 'BT26-009');
      expect(card.number, 'BT26-009');
      expect(card.parallelId, 0);
      expect(card.isPrimary, isTrue);
      expect(card.name, 'Hyokomon');
      expect(card.category, CardCategory.digimon.apiValue);
      expect(card.colors, ['red']);
      expect(card.traits, ['Bird', 'Iliad']);
      expect(card.level, 3);
      expect(card.dp, 2000);
      expect(card.attribute, 'Data');
      expect(card.rarity, 'U');
      expect(card.releaseIds, ['bt-26']);
      expect(card.notes, 'TIMELESS BONDS [BT-26]');
      expect(card.imageUrl, endsWith('/BT26-009.jpg'));
    });

    test('drops the duplicate rows their API returns per printing', () {
      final cards = parseDigimonCardIoPack([
        _row({}),
        _row({}),
        _row({'id': 'BT26-010'}),
      ], _release);

      expect(cards.map((c) => c.number), ['BT26-009', 'BT26-010']);
    });

    test(
      'rejoins the effect text their schema splits across three columns',
      () {
        final card = parseDigimonCardIoPack([
          _row({
            'xros_req': '[Digivolve] Lv.2 w/[TS] trait: Cost 0',
            'alt_effect': '[Digivolve] [Aegiomon]: Cost 3',
            'main_effect': '[On Play] Draw 1.',
          }),
        ], _release).single;

        expect(
          card.effect,
          '[Digivolve] Lv.2 w/[TS] trait: Cost 0\n'
          '[Digivolve] [Aegiomon]: Cost 3\n'
          '[On Play] Draw 1.',
        );
      },
    );

    test('reads source_effect as inherited or security by its marker', () {
      final digimon = parseDigimonCardIoPack([_row({})], _release).single;
      expect(digimon.inheritedEffect, startsWith('[When Attacking]'));
      expect(digimon.securityEffect, isNull);

      final option = parseDigimonCardIoPack([
        _row({
          'type': 'Option',
          'source_effect': '[Security] Play this card without paying the cost.',
        }),
      ], _release).single;
      expect(option.securityEffect, startsWith('[Security]'));
      expect(option.inheritedEffect, isNull);
    });

    test('throws away the wiki fragment that leaks into source_effect', () {
      final card = parseDigimonCardIoPack([
        _row({'source_effect': '|applinkdp ='}),
      ], _release).single;

      expect(card.inheritedEffect, isNull);
      expect(card.securityEffect, isNull);
    });

    test('keeps an Option cost where the app looks for it', () {
      final option = parseDigimonCardIoPack([
        _row({'type': 'Option', 'play_cost': 4}),
      ], _release).single;

      expect(option.useCost, 4);
      expect(option.playCost, isNull);
      expect(option.cost, 4);

      final digimon = parseDigimonCardIoPack([_row({})], _release).single;
      expect(digimon.playCost, 3);
      expect(digimon.useCost, isNull);
      expect(digimon.cost, 3);
    });

    test('files a dual card as a Digimon that answers an Option filter', () {
      final card = parseDigimonCardIoPack([
        _row({'id': 'BT26-080', 'type': 'Dual', 'name': 'Bacchusmon'}),
      ], _release).single;

      expect(card.category, CardCategory.digimon.apiValue);
      expect(card.dualCategory, CardCategory.option.apiValue);
    });

    test('normalises mixed-case rarity codes', () {
      final card = parseDigimonCardIoPack([
        _row({'rarity': 'sr'}),
      ], _release).single;

      expect(card.rarity, 'SR');
    });

    test('normalises the CRLF line endings their columns carry', () {
      final card = parseDigimonCardIoPack([
        _row({'main_effect': 'First line.\r\nSecond line.'}),
      ], _release).single;

      expect(card.effect, 'First line.\nSecond line.');
    });

    test('builds a digivolution requirement from the evolution columns', () {
      final card = parseDigimonCardIoPack([_row({})], _release).single;

      expect(jsonDecode(card.digivolutionRequirements), [
        {
          'level': 2,
          'cost': 0,
          'category': 'digimon',
          'color': ['red'],
        },
      ]);
      expect(card.digivolveCostMin, 0);
      expect(card.digivolveCostMax, 0);
    });

    test('leaves the fields their API does not carry empty', () {
      final card = parseDigimonCardIoPack([_row({})], _release).single;

      expect(card.faqs, '[]');
      expect(card.limitations, '[]');
      expect(card.blockIcon, isNull);
      expect(card.supplementalStars, isNull);
      expect(card.dualFace, isNull);
      // No restriction list for a set this new, so the printed cap applies.
      expect(card.copyLimit, 4);
    });

    test('takes both colours of a two-colour card', () {
      final card = parseDigimonCardIoPack([
        _row({'color': 'Purple', 'color2': 'Green'}),
      ], _release).single;

      expect(card.colors, ['purple', 'green']);
    });

    test('skips a row with no card number', () {
      expect(
        parseDigimonCardIoPack([
          _row({'id': ''}),
        ], _release),
        isEmpty,
      );
    });
  });
}
