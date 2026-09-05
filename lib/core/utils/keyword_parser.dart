/// Extracts the game's keywords from card text.
///
/// The API exposes no keyword field: keywords are printed inline in the effect
/// text wrapped in angle brackets, e.g. `＜Blocker＞` or `＜De-Digivolve 2＞`.
/// This parser pulls them out at sync time so the library can filter on them.
abstract final class KeywordParser {
  /// Matches a bracketed term in any of the bracket styles the card text uses:
  /// fullwidth `＜＞`, ASCII `<>`, and the mathematical `⟨⟩` / `〈〉` pairs.
  static final _bracketed = RegExp(r'[＜<〈⟨]([^＞>〉⟩\n]{1,40})[＞>〉⟩]');

  /// Trailing numeric modifiers that vary per card but not per keyword:
  /// `De-Digivolve 2`, `Security Attack +1`, `DigiXros -2`, `Link +1`.
  static final _trailingModifier = RegExp(r'\s*[+\-]?\d+\s*$');

  /// Parenthetical qualifiers such as `Overflow (-4)` or `Recovery +1 (Deck)`.
  static final _qualifier = RegExp(r'\s*[(（≪][^)）≫]*[)）≫]');

  /// Bracketed terms that are structural markers rather than keywords.
  static const _notKeywords = {'rule', 'draw', 'draw 1', 'draw 2', 'draw 3'};

  /// Abbreviations the printed text uses interchangeably with the full name.
  static const _aliases = {
    'Security A.': 'Security Attack',
    'Security Atk.': 'Security Attack',
  };

  /// Reduces a printed term to the keyword it names, or `null` if the term is
  /// not a keyword. `＜Security A. +1＞` and `＜Security Attack -1＞` both
  /// become `Security Attack`.
  static String? normalize(String raw) {
    var term = raw.replaceAll(_qualifier, '').trim();
    term = term.replaceAll(_trailingModifier, '').trim();
    term = term.replaceAll(RegExp(r'\s+'), ' ');
    if (term.isEmpty) return null;

    for (final entry in _aliases.entries) {
      if (term == entry.key || term.startsWith('${entry.key} ')) {
        term = term.replaceFirst(entry.key, entry.value);
      }
    }
    term = term.replaceAll(_trailingModifier, '').trim();

    if (term.isEmpty || term.length > 32) return null;
    if (_notKeywords.contains(term.toLowerCase())) return null;

    // Reject leftovers that are clearly sentence fragments rather than terms.
    if (term.split(' ').length > 4) return null;
    return term;
  }

  /// Every distinct keyword across the given blocks of card text, in the order
  /// they first appear.
  static List<String> extract(Iterable<String?> texts) {
    final found = <String>{};
    for (final text in texts) {
      if (text == null || text.isEmpty) continue;
      for (final match in _bracketed.allMatches(text)) {
        final keyword = normalize(match.group(1)!);
        if (keyword != null) found.add(keyword);
      }
    }
    return found.toList();
  }
}
