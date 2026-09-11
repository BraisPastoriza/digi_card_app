/// The two version numbers that decide what an app update costs the user.
///
/// They are separate because the two kinds of change cost wildly different
/// things, and lumping them together made every change cost the expensive one.
///
///  * A **schema** change alters the tables. It is [AppDatabase.schemaVersion]
///    and is migrated column by column.
///  * A **card data** change means the rows themselves are unusable — a new
///    column only the API can fill. Nothing but a fresh download fixes that,
///    so [invalidatedAt] says which schema version last needed one, and the
///    upgrade throws the card tables away and re-syncs: 25 MB and 93 requests.
///  * A **derived data** change means the app now reads the same card text
///    differently — the keyword parser, the digivolution conditions, the sort
///    key. Every input for those is already stored (`effect`,
///    `inherited_effect`, `security_effect`, `dual_face` and the requirement
///    JSON), so nothing has to be downloaded: [derived] goes up and the cards
///    already on the device are read again locally.
///
/// The one thing a re-derivation cannot fix is a value whose *source* is not
/// stored — traits, for instance, are split from an API field the database
/// does not keep. A change to that parsing is a card data change, not a
/// derived one, and belongs in [invalidatedAt].
abstract final class CardDataVersions {
  /// Last schema version whose change left the stored card data unusable.
  ///
  /// Schema 9 is the last one that added a column the API had to fill. Every
  /// version since has either added tables of the user's own (staples) or
  /// changed how stored text is read, and neither needs new cards.
  static const invalidatedAt = 9;

  /// Version of the values worked out from card text.
  ///
  /// 1. As published in 1.1.0.
  /// 2. Keywords printed inside reminder text no longer count as the card's
  ///    own, and the digivolution conditions in the effect box now feed the
  ///    cost filter.
  /// 3. A banned pair no longer reads as a copy limit of zero. The three cards
  ///    on the list were unaddable to any deck; they are legal in fours, and
  ///    only the deck that also runs their partner is not.
  static const derived = 3;

  /// Whether a database last written at schema [from] holds card rows this
  /// build cannot use, and therefore has to re-download them.
  static bool needsCardReset(int from) => from < invalidatedAt;

  /// Whether cards derived under [storedVersion] have to be read again.
  ///
  /// A database that has never recorded one reports 0, which is every install
  /// that predates this mechanism — exactly the ones that need the pass.
  static bool needsRederive(int storedVersion) => storedVersion < derived;
}
