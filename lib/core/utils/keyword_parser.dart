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

  /// Everything from the first qualifier bracket onwards: `Decoy (Black)`,
  /// `Decode ([Aegiomon])`, `Fragment ≪3≫`, `Decode《[Aegiomon]》`. All of them
  /// narrow which cards a keyword applies to, not which keyword it is, and a
  /// qualifier always follows the name.
  ///
  /// The cut is made at the first bracket rather than by matching balanced
  /// pairs because the qualifiers nest:
  /// `Partition (green Lv.5 (green Lv.5 & blue Lv.5) blue Lv.5)` closes its
  /// inner bracket first, so a pair-matching strip ends in the wrong place and
  /// leaves `Partition blue Lv.5)` behind as a second, bogus keyword.
  static final _qualifier = RegExp(r'\s*[(（≪《].*$', dotAll: true);

  /// `Digi-Burst up to 4`.
  static final _upTo = RegExp(r'\s*up\s+to\s*\d*\s*$', caseSensitive: false);

  /// Trailing magnitude, capturing the sign when there is one:
  /// `De-Digivolve 2`, `Security Attack +1`, `Security A. -`, `Link +1`.
  static final _trailingModifier = RegExp(r'\s*(?:([+\-])\s*\d*|\d+)\s*$');

  /// Leftover joiners once qualifiers are gone, as in `Decoy (Red)/(Black)`,
  /// which would otherwise normalise to `Decoy/`.
  static final _trailingSeparator = RegExp(r'[\s/·,、]+$');

  /// Brackets that open and close reminder text, in both widths the card
  /// text uses.
  static const _openParen = '(（';
  static const _closeParen = ')）';

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

    term = term.replaceFirst(_qualifier, '');
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
  ///
  /// Terms printed inside reminder text are left out, because reminder text
  /// says what some *other* keyword does:
  ///
  /// ```
  /// ＜Collision＞ (During this Digimon's attack, all of your opponent's
  /// Digimon gain ＜Blocker＞, and must block if possible.)
  /// ```
  ///
  /// That card has Collision, not Blocker — the Blocker is on the Digimon
  /// facing it. Counting it made a search for Blocker return every card that
  /// merely explains Collision, and the same held for the Security Attack in
  /// Alliance's reminder and for the keywords a card lists when it spells out
  /// the token it creates.
  static List<String> extract(Iterable<String?> texts) {
    final found = <String>{};
    for (final text in texts) {
      if (text == null || text.isEmpty) continue;
      for (final match in _printedTerms(text)) {
        final keyword = normalize(match.group(1)!);
        if (keyword != null) found.add(keyword);
      }
    }
    return found.toList();
  }

  /// The bracketed terms in [text] the card carries itself, skipping the ones
  /// inside a parenthetical.
  ///
  /// Nesting is counted over the gaps between terms rather than over the whole
  /// string, so the brackets of a qualifier — `＜Decoy (Red/Black)＞` — belong
  /// to the term they are printed in and never open a reminder of their own.
  static Iterable<RegExpMatch> _printedTerms(String text) sync* {
    var depth = 0;
    var index = 0;
    for (final match in _bracketed.allMatches(text)) {
      final gap = text.substring(index, match.start);
      for (var i = 0; i < gap.length; i++) {
        if (_openParen.contains(gap[i])) {
          depth++;
        } else if (_closeParen.contains(gap[i])) {
          // Clamped: a stray closing bracket must not drive the count below
          // zero and hide the reminder text that comes after it.
          depth = depth == 0 ? 0 : depth - 1;
        }
      }
      if (depth == 0) yield match;
      index = match.end;
    }
  }
}
