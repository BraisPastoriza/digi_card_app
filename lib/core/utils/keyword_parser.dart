/// Extracts the game's keywords from card text.
///
/// The API exposes no keyword field: keywords are printed inline in the effect
/// text wrapped in angle brackets, e.g. `＜Blocker＞` or `＜De-Digivolve 2＞`.
/// This parser pulls them out at sync time so the library can filter on them.
///
/// The printed forms vary a lot — the same keyword appears with per-card
/// numbers, colour or trait qualifiers, and several bracket styles — so
/// normalising is what keeps the filter from listing one keyword five times.
abstract final class KeywordParser {
  /// Matches a bracketed term in any of the bracket styles the card text uses:
  /// fullwidth `＜＞`, ASCII `<>`, and the mathematical `⟨⟩` / `〈〉` pairs.
  static final _bracketed = RegExp(r'[＜<〈⟨]([^＞>〉⟩\n]{1,60})[＞>〉⟩]');

  /// Per-card qualifiers: `Decoy (Black)`, `Decode ([Aegiomon])`,
  /// `Fragment ≪3≫`, `Decode《[Aegiomon]》`. All of them narrow which cards a
  /// keyword applies to, not which keyword it is.
  static final _qualifier = RegExp(r'\s*[(（≪《][^)）≫》]*[)）≫》]');

  /// `Digi-Burst up to 4`.
  static final _upTo = RegExp(r'\s*up\s+to\s*\d*\s*$', caseSensitive: false);

  /// Trailing magnitude, capturing the sign when there is one:
  /// `De-Digivolve 2`, `Security Attack +1`, `Security A. -`, `Link +1`.
  static final _trailingModifier = RegExp(r'\s*(?:([+\-])\s*\d*|\d+)\s*$');

  /// Leftover joiners once qualifiers are gone, as in `Decoy (Red)/(Black)`,
  /// which would otherwise normalise to `Decoy/`.
  static final _trailingSeparator = RegExp(r'[\s/·,、]+$');

  /// Bracketed terms that are structural markers rather than keywords.
  static const _notKeywords = {'rule', 'draw'};

  /// Abbreviations the printed text uses interchangeably with the full name.
  static const _aliases = {
    'Security A.': 'Security Attack',
    'Security Atk.': 'Security Attack',
    'S Attack': 'Security Attack',
    'S. Attack': 'Security Attack',
  };

  /// Keywords whose sign changes what the card does rather than by how much,
  /// so `＜Security Attack +1＞` and `＜Security Attack -1＞` stay apart while
  /// `＜Digi-Burst 2＞` and `＜Digi-Burst 3＞` collapse together.
  static const _directional = {'Security Attack'};

  /// Reduces a printed term to the keyword it names, or `null` if the term is
  /// not a keyword.
  static String? normalize(String raw) {
    var term = raw.trim();

    // Qualifiers can nest side by side — `Decoy (Red)/(Black)` has two — so
    // strip until nothing changes.
    String previous;
    do {
      previous = term;
      term = term.replaceAll(_qualifier, '');
    } while (term != previous);

    term = term.replaceAll(_upTo, '');

    // Read the direction before the magnitude is thrown away.
    final sign = _trailingModifier.firstMatch(term)?.group(1);

    term = term
        .replaceAll(_trailingModifier, '')
        .replaceAll(_trailingSeparator, '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (term.isEmpty) return null;

    for (final entry in _aliases.entries) {
      if (term == entry.key || term.startsWith('${entry.key} ')) {
        term = term.replaceFirst(entry.key, entry.value);
      }
    }
    term = term
        .replaceAll(_trailingModifier, '')
        .replaceAll(_trailingSeparator, '')
        .trim();

    if (term.isEmpty || term.length > 32) return null;
    if (_notKeywords.contains(term.toLowerCase())) return null;

    // Reject leftovers that are clearly sentence fragments rather than terms.
    if (term.split(' ').length > 4) return null;

    if (sign != null && _directional.contains(term)) return '$term $sign';
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
