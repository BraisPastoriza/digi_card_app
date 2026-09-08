import 'deck.dart';
import 'digimon_card.dart';

/// The text layouts a deck list can be written in.
///
/// Both put the same three things on a line — copies, name, card number — and
/// differ only in how the number is punctuated, which is enough to matter:
/// Untap refuses a list whose numbers are not in brackets.
enum DeckListFormat {
  standard('Default', '4 Agumon BT1-010'),
  untap('Untap', '4 Agumon (BT1-010)');

  const DeckListFormat(this.label, this.example);

  final String label;

  /// A sample line, shown so the user can tell the two apart at a glance.
  final String example;

  String line({
    required int quantity,
    required String name,
    required String number,
  }) => switch (this) {
    DeckListFormat.standard => '$quantity $name $number',
    DeckListFormat.untap => '$quantity $name ($number)',
  };
}

/// Writes a revision out as a deck list, in the order the deck builder shows
/// it: Digi-Eggs, then Digimon by level, then Tamers and Options.
///
/// Section headings are deliberately left out. Both formats are consumed by
/// other tools, and a bare list of lines is what every one of them reads.
String writeDeckList(DeckComposition composition, DeckListFormat format) => [
  for (final section in composition.sections)
    for (final entry in section.entries)
      format.line(
        quantity: entry.quantity,
        name: entry.card.name,
        number: entry.cardNumber,
      ),
].join('\n');

/// Writes a staple list out in the same shape.
///
/// Every line says one copy: a staple list is a set of cards, and the copies
/// belong to whatever deck the reader puts them in. Writing it as a deck list
/// anyway means the result pastes into this app's own importer and into the
/// tools that read deck lists, rather than being a format only this app knows.
String writeStapleList(List<DigimonCard> cards, DeckListFormat format) => [
  for (final card in cards)
    format.line(quantity: 1, name: card.name, number: card.number),
].join('\n');

/// One line of a pasted deck list, before it is matched against the library.
class DeckListLine {
  const DeckListLine({
    required this.raw,
    required this.quantity,
    this.cardNumber,
    this.name,
  });

  /// The line as pasted, so an unmatched one can be shown back to the user.
  final String raw;

  final int quantity;

  /// Printed number read off the line, when it carried one.
  final String? cardNumber;

  /// Whatever was left after the copies and the number were taken out.
  final String? name;
}

/// Copies at the start of a line: `4 `, `4x `, `x4 `, `4. `.
final _quantity = RegExp(r'^(?:x\s*(\d{1,3})|(\d{1,3}))\s*(?:x\b|[.)])?\s+');

/// A printed card number at the end of a line, with or without the brackets
/// the Untap format wraps it in. Numbers run `BT1-010`, `ST23-09`, `P-001`,
/// `EX12-018`, `LM-045`, `AD1-002`, plus the odd `BT11-TOKEN`.
///
/// The tail has to be digits or `TOKEN` rather than any word: a card named
/// "Omnimon X-Antibody" would otherwise have its own name read as its number.
final _trailingNumber = RegExp(
  r'[(\[]?\b([A-Za-z]{1,3}\d{0,2}-(?:\d{2,3}|TOKEN\d{0,2}))\b[)\]]?[\s.,;]*$',
  caseSensitive: false,
);

/// Lines that carry no cards: blank lines, comments, and the section headings
/// exporters like to write ("Egg Deck", "// Digimon", "Options (12)").
bool _isNoise(String line) =>
    line.isEmpty ||
    line.startsWith('//') ||
    line.startsWith('#') ||
    line.startsWith(';');

/// Reads a pasted deck list.
///
/// Accepts both formats this app writes and the usual variations around them —
/// `4x`, trailing punctuation, headings between blocks — because a list is
/// almost always pasted from somewhere else. Lines that name no card at all
/// are dropped silently as headings; a line that clearly meant to be a card
/// comes back for the importer to report.
List<DeckListLine> readDeckList(String text) {
  final lines = <DeckListLine>[];
  for (final raw in text.split('\n')) {
    final trimmed = raw.trim();
    if (_isNoise(trimmed)) continue;

    final quantityMatch = _quantity.firstMatch(trimmed);
    final rest = quantityMatch == null
        ? trimmed
        : trimmed.substring(quantityMatch.end).trim();

    final numberMatch = _trailingNumber.firstMatch(rest);
    final number = numberMatch?.group(1);

    // A heading has neither copies nor a card number; skipping it quietly is
    // what lets a list pasted with its section titles import cleanly.
    if (quantityMatch == null && number == null) continue;

    final name = numberMatch == null
        ? rest
        : rest.substring(0, numberMatch.start).trim();

    lines.add(
      DeckListLine(
        raw: trimmed,
        quantity:
            int.tryParse(
              quantityMatch?.group(1) ?? quantityMatch?.group(2) ?? '',
            ) ??
            1,
        cardNumber: number,
        // Trim the separators lists put between a name and its number.
        name: name.replaceAll(RegExp(r'^[-|·:\s]+|[-|·:\s]+$'), ''),
      ),
    );
  }
  return lines;
}

/// A parsed line matched against the card library.
class DeckListMatch {
  const DeckListMatch({required this.line, this.card});

  final DeckListLine line;

  /// The card the line resolved to, or null if the library has no such card.
  final DigimonCard? card;

  bool get isResolved => card != null;
}

/// Matches parsed lines against the library.
///
/// The printed number decides it wherever the line carries one — names repeat
/// across a dozen sets — and the name is only used as a fallback for lists
/// written without numbers. [byNumber] is keyed by upper-case card number and
/// [byName] by lower-case card name, so a list typed in either case matches.
List<DeckListMatch> matchDeckList(
  List<DeckListLine> lines, {
  required Map<String, DigimonCard> byNumber,
  required Map<String, DigimonCard> byName,
}) => [
  for (final line in lines)
    DeckListMatch(
      line: line,
      card:
          byNumber[line.cardNumber?.toUpperCase() ?? ''] ??
          byName[line.name?.toLowerCase().trim() ?? ''],
    ),
];

/// Copies per card number, summing lines that named the same card twice.
Map<String, int> quantitiesOf(Iterable<DeckListMatch> matches) {
  final quantities = <String, int>{};
  for (final match in matches) {
    final card = match.card;
    if (card == null) continue;
    quantities[card.number] =
        (quantities[card.number] ?? 0) + match.line.quantity;
  }
  return quantities;
}
