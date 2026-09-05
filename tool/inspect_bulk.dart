// This is a developer tool run from the terminal; printing is the point.
// ignore_for_file: avoid_print

// Parses a downloaded bulk card dump and prints a summary of what came out.
//
// Useful when the API changes shape, or to sanity-check the keyword and
// sort-key derivations against the real dataset without launching the app:
//
//   dart run tool/inspect_bulk.dart path/to/en-bulk.json
import 'dart:io';

import 'package:digi_card_app/data/sync/bulk_parser.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty) {
    stderr.writeln('Usage: dart run tool/inspect_bulk.dart <bulk.json>');
    exitCode = 64;
    return;
  }

  final stopwatch = Stopwatch()..start();
  final cards = await parseBulkFile(args.first);
  stopwatch.stop();

  print(
    'Parsed ${cards.length} printings in ${stopwatch.elapsedMilliseconds}ms',
  );
  print('Primary printings: ${cards.where((c) => c.isPrimary).length}');
  print('Distinct numbers:  ${cards.map((c) => c.number).toSet().length}');
  print('Dual cards:        ${cards.where((c) => c.dualFace != null).length}');
  print('Restricted:        ${cards.where((c) => c.copyLimit < 4).length}');
  final raised = cards.where((c) => c.copyLimit > 4).toList();
  print('Raised copy limit: ${raised.length}');
  for (final card in {for (final c in raised) c.number: c}.values) {
    print(
      '  ${card.number.padRight(12)} ${card.name} — up to ${card.copyLimit}',
    );
  }

  final missingImages = cards.where((c) => c.imageUrl.isEmpty).length;
  final missingNames = cards.where((c) => c.name.isEmpty).length;
  print('Missing images:    $missingImages');
  print('Missing names:     $missingNames');

  _printTally('KEYWORDS', cards.expand((c) => c.keywords));
  _printTally('TRAITS', cards.expand((c) => c.traits), limit: 15);

  final noRelease = cards.where((c) => c.releaseIds.isEmpty).toList();
  print('\nPrintings with no release link: ${noRelease.length}');
  for (final card in noRelease.take(5)) {
    print('  ${card.number} — ${card.name}');
  }

  print('\nSORT ORDER (first 8 and last 5 by numberSort)');
  final sorted = cards.where((c) => c.isPrimary).toList()
    ..sort((a, b) => a.numberSort.compareTo(b.numberSort));
  for (final card in [...sorted.take(8), ...sorted.skip(sorted.length - 5)]) {
    print('  ${card.numberSort}  ${card.number.padRight(12)} ${card.name}');
  }
}

void _printTally(String title, Iterable<String> values, {int limit = 40}) {
  final tally = <String, int>{};
  for (final value in values) {
    tally[value] = (tally[value] ?? 0) + 1;
  }
  final ordered = tally.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  print('\n$title — ${tally.length} distinct');
  for (final entry in ordered.take(limit)) {
    print('  ${entry.value.toString().padLeft(5)}  ${entry.key}');
  }
}
