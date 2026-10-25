import 'deck.dart';

/// What a deck QR code holds: the deck's name on a `#` line, then one line per
/// card of copies and printed number — `4 BT1-010`.
///
/// Card names are left out on purpose. The number already says which card it
/// is, and every character makes the code denser: a 50-card list with names
/// needs a code too fine for a phone camera at arm's length, and without them
/// it stays around 200 characters. It is still plain text, so a code scanned
/// with any other app reads as a deck list, and `readDeckList` — which skips
/// `#` lines as comments — imports it like one pasted by hand.
String writeDeckQr(String deckName, DeckComposition composition) => [
  '# ${deckName.replaceAll('\n', ' ').trim()}',
  for (final section in composition.sections)
    for (final entry in section.entries)
      '${entry.quantity} ${entry.cardNumber}',
].join('\n');

/// The deck name a scanned code carries on its first line, if it has one.
String? deckNameInQr(String text) {
  final first = text.trimLeft().split('\n').first.trim();
  if (!first.startsWith('#')) return null;
  final name = first.substring(1).trim();
  return name.isEmpty ? null : name;
}
