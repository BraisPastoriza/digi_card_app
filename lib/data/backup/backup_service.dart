import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';

import '../../core/app_info.dart';
import '../db/app_database.dart';

/// Thrown when a file is not a backup this version of the app can read.
class BackupFormatException implements Exception {
  const BackupFormatException(this.reason);

  final BackupFormatProblem reason;

  @override
  String toString() => 'BackupFormatException: ${reason.name}';
}

enum BackupFormatProblem {
  /// Not a DigiCard backup at all: some other JSON, or not JSON.
  notABackup,

  /// Written by a newer version of the app, in a shape this one predates.
  tooNew,
}

/// What a backup holds, for asking the user before restoring it.
class BackupContents {
  const BackupContents({required this.decks, required this.stapleLists});

  final int decks;
  final int stapleLists;
}

/// What a restore did.
class RestoreResult {
  const RestoreResult({
    required this.decksAdded,
    required this.decksSkipped,
    required this.listsAdded,
    required this.listsMerged,
  });

  /// Decks the backup had and this device did not.
  final int decksAdded;

  /// Decks already here exactly as the backup has them.
  final int decksSkipped;

  /// Staple lists created because no list here had their name.
  final int listsAdded;

  /// Staple lists here that gained cards from a list of the same name.
  final int listsMerged;
}

/// Writes the user's own data — decks and staple lists — to a file, and reads
/// it back.
///
/// The cards are not in it: they are the published card list, downloaded
/// again on any device. Everything is keyed by printed card number, as the
/// tables themselves are, so a backup restores onto a database synced at a
/// different time, or onto a fresh install before its first sync.
///
/// Restoring adds to what is there rather than replacing it, so it can never
/// cost the user a deck. Running it twice is harmless: a deck already here
/// exactly as the backup has it is skipped, and a staple list gains only the
/// cards it was missing.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  static const format = 'digicard-backup';

  /// Bumped when the shape changes in a way an older app could misread. An
  /// app refuses backups newer than it knows rather than half-restoring them.
  static const version = 1;

  Future<Map<String, dynamic>> export() async {
    final decks = await _db.select(_db.decks).get();
    final revisions = await (_db.select(
      _db.deckRevisions,
    )..orderBy([(r) => OrderingTerm.asc(r.id)])).get();
    final entries = await _db.select(_db.deckEntries).get();
    final lists = await (_db.select(
      _db.stapleLists,
    )..orderBy([(l) => OrderingTerm.asc(l.sortIndex)])).get();
    final listEntries = await (_db.select(
      _db.stapleEntries,
    )..orderBy([(e) => OrderingTerm.asc(e.addedAt)])).get();

    final revisionsOf = revisions.groupListsBy((r) => r.deckId);
    final entriesOf = entries.groupListsBy((e) => e.revisionId);
    final cardsOf = listEntries.groupListsBy((e) => e.listId);

    return {
      'format': format,
      'version': version,
      'app': AppInfo.version,
      'exportedAt': DateTime.now().toUtc().toIso8601String(),
      'decks': [
        for (final deck in decks)
          () {
            final own = revisionsOf[deck.id] ?? const <DeckRevisionRow>[];
            final active = own.indexWhere((r) => r.id == deck.activeRevisionId);
            return {
              'name': deck.name,
              if (deck.description != null) 'description': deck.description,
              if (deck.thumbnailCardNumber != null)
                'thumbnailCardNumber': deck.thumbnailCardNumber,
              'createdAt': _date(deck.createdAt),
              'updatedAt': _date(deck.updatedAt),
              if (active >= 0) 'activeRevision': active,
              'revisions': [
                for (final revision in own)
                  {
                    'name': revision.name,
                    'createdAt': _date(revision.createdAt),
                    'updatedAt': _date(revision.updatedAt),
                    'entries': [
                      for (final entry
                          in entriesOf[revision.id] ?? const <DeckEntryRow>[])
                        {
                          'cardNumber': entry.cardNumber,
                          'quantity': entry.quantity,
                          if (entry.printingId != null)
                            'printingId': entry.printingId,
                        },
                    ],
                  },
              ],
            };
          }(),
      ],
      'stapleLists': [
        for (final list in lists)
          {
            'name': list.name,
            'createdAt': _date(list.createdAt),
            'updatedAt': _date(list.updatedAt),
            'cards': [
              for (final entry in cardsOf[list.id] ?? const <StapleEntryRow>[])
                {
                  'cardNumber': entry.cardNumber,
                  'addedAt': _date(entry.addedAt),
                },
            ],
          },
      ],
    };
  }

  /// [export] as the bytes of a file, readable as it is.
  Future<Uint8List> exportBytes() async => Uint8List.fromList(
    utf8.encode(const JsonEncoder.withIndent('  ').convert(await export())),
  );

  /// Reads a file's bytes as a backup, or throws [BackupFormatException].
  static Map<String, dynamic> parse(List<int> bytes) {
    final Object? json;
    try {
      json = jsonDecode(utf8.decode(bytes));
    } on FormatException {
      throw const BackupFormatException(BackupFormatProblem.notABackup);
    }
    if (json is! Map<String, dynamic> || json['format'] != format) {
      throw const BackupFormatException(BackupFormatProblem.notABackup);
    }
    final fileVersion = json['version'];
    if (fileVersion is! int) {
      throw const BackupFormatException(BackupFormatProblem.notABackup);
    }
    if (fileVersion > version) {
      throw const BackupFormatException(BackupFormatProblem.tooNew);
    }
    return json;
  }

  static BackupContents contentsOf(Map<String, dynamic> backup) =>
      BackupContents(
        decks: _maps(backup['decks']).length,
        stapleLists: _maps(backup['stapleLists']).length,
      );

  Future<RestoreResult> restore(Map<String, dynamic> backup) async {
    var decksAdded = 0;
    var decksSkipped = 0;
    var listsAdded = 0;
    var listsMerged = 0;

    await _db.transaction(() async {
      final existing = await _deckFingerprints();
      for (final deck in _maps(backup['decks'])) {
        final name = _string(deck['name']);
        if (name == null) continue;
        final revisions = _maps(deck['revisions']);
        // Added as it goes, so a deck the file lists twice comes back once.
        if (!existing.add(_fingerprint(name, revisions))) {
          decksSkipped++;
          continue;
        }
        await _insertDeck(name, deck, revisions);
        decksAdded++;
      }

      final lists = await _db.select(_db.stapleLists).get();
      var nextSort = lists.map((l) => l.sortIndex).fold(-1, max) + 1;
      for (final list in _maps(backup['stapleLists'])) {
        final name = _string(list['name']);
        if (name == null) continue;
        final cards = _maps(list['cards']);
        final match = lists.firstWhereOrNull((l) => l.name == name);
        if (match == null) {
          final id = await _db
              .into(_db.stapleLists)
              .insert(
                StapleListsCompanion.insert(
                  name: name,
                  sortIndex: Value(nextSort++),
                  createdAt: _parseDate(list['createdAt']),
                  updatedAt: _parseDate(list['updatedAt']),
                ),
              );
          await _insertListCards(id, cards);
          listsAdded++;
        } else if (await _insertListCards(match.id, cards) > 0) {
          listsMerged++;
        }
      }
    });

    return RestoreResult(
      decksAdded: decksAdded,
      decksSkipped: decksSkipped,
      listsAdded: listsAdded,
      listsMerged: listsMerged,
    );
  }

  Future<void> _insertDeck(
    String name,
    Map<String, dynamic> deck,
    List<Map<String, dynamic>> revisions,
  ) async {
    final deckId = await _db
        .into(_db.decks)
        .insert(
          DecksCompanion.insert(
            name: name,
            description: Value(_string(deck['description'])),
            thumbnailCardNumber: Value(_string(deck['thumbnailCardNumber'])),
            createdAt: _parseDate(deck['createdAt']),
            updatedAt: _parseDate(deck['updatedAt']),
          ),
        );

    final revisionIds = <int>[];
    for (final revision in revisions) {
      final revisionId = await _db
          .into(_db.deckRevisions)
          .insert(
            DeckRevisionsCompanion.insert(
              deckId: deckId,
              name: _string(revision['name']) ?? name,
              createdAt: _parseDate(revision['createdAt']),
              updatedAt: _parseDate(revision['updatedAt']),
            ),
          );
      revisionIds.add(revisionId);
      await _db.batch((batch) {
        batch.insertAll(_db.deckEntries, [
          for (final entry in _entries(revision))
            DeckEntriesCompanion.insert(
              revisionId: revisionId,
              cardNumber: entry.cardNumber,
              quantity: entry.quantity,
              printingId: Value(entry.printingId),
            ),
        ], mode: InsertMode.insertOrReplace);
      });
    }

    // A deck is always shown through one of its revisions; the one the backup
    // marks, or the newest if it marks none the restore could make sense of.
    final active = deck['activeRevision'];
    final activeId = active is int && active >= 0 && active < revisionIds.length
        ? revisionIds[active]
        : revisionIds.lastOrNull;
    if (activeId != null) {
      await (_db.update(_db.decks)..where((d) => d.id.equals(deckId))).write(
        DecksCompanion(activeRevisionId: Value(activeId)),
      );
    }
  }

  /// Adds [cards] to a staple list, skipping the ones it has. Returns how many
  /// it gained.
  Future<int> _insertListCards(
    int listId,
    List<Map<String, dynamic>> cards,
  ) async {
    final had =
        (await (_db.select(
              _db.stapleEntries,
            )..where((e) => e.listId.equals(listId))).get())
            .map((e) => e.cardNumber)
            .toSet();
    final fresh = [
      for (final card in cards)
        if (_string(card['cardNumber']) case final number?
            when !had.contains(number))
          (number: number, addedAt: _parseDate(card['addedAt'])),
    ];
    await _db.batch((batch) {
      batch.insertAll(_db.stapleEntries, [
        for (final card in fresh)
          StapleEntriesCompanion.insert(
            listId: listId,
            cardNumber: card.number,
            addedAt: card.addedAt,
          ),
      ], mode: InsertMode.insertOrIgnore);
    });
    return fresh.map((card) => card.number).toSet().length;
  }

  /// One string per deck here, equal for two decks with the same name and
  /// the same revisions holding the same cards — which is what "already
  /// restored" means.
  Future<Set<String>> _deckFingerprints() async {
    final decks = await _db.select(_db.decks).get();
    final revisions = await (_db.select(
      _db.deckRevisions,
    )..orderBy([(r) => OrderingTerm.asc(r.id)])).get();
    final entries = await _db.select(_db.deckEntries).get();
    final revisionsOf = revisions.groupListsBy((r) => r.deckId);
    final entriesOf = entries.groupListsBy((e) => e.revisionId);
    return {
      for (final deck in decks)
        _fingerprint(deck.name, [
          for (final revision
              in revisionsOf[deck.id] ?? const <DeckRevisionRow>[])
            {
              'name': revision.name,
              'entries': [
                for (final entry
                    in entriesOf[revision.id] ?? const <DeckEntryRow>[])
                  {'cardNumber': entry.cardNumber, 'quantity': entry.quantity},
              ],
            },
        ]),
    };
  }

  /// The art a card was picked in is left out on purpose: the same list in a
  /// different printing is still the deck the user already has.
  static String _fingerprint(
    String name,
    List<Map<String, dynamic>> revisions,
  ) => jsonEncode([
    name,
    for (final revision in revisions)
      [
        _string(revision['name']),
        for (final entry in _entries(
          revision,
        ).sortedBy((entry) => entry.cardNumber))
          '${entry.cardNumber}x${entry.quantity}',
      ],
  ]);

  static List<({String cardNumber, int quantity, String? printingId})> _entries(
    Map<String, dynamic> revision,
  ) => [
    for (final entry in _maps(revision['entries']))
      if ((_string(entry['cardNumber']), entry['quantity']) case (
        final number?,
        final int quantity,
      ) when quantity > 0)
        (
          cardNumber: number,
          quantity: quantity,
          printingId: _string(entry['printingId']),
        ),
  ];

  static List<Map<String, dynamic>> _maps(Object? value) => [
    if (value is List)
      for (final item in value)
        if (item is Map<String, dynamic>) item,
  ];

  static String? _string(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;

  static String _date(DateTime date) => date.toUtc().toIso8601String();

  /// A date the file has, or now when it has none worth reading: a missing
  /// timestamp is no reason to lose a deck.
  static DateTime _parseDate(Object? value) =>
      (value is String ? DateTime.tryParse(value)?.toLocal() : null) ??
      DateTime.now();
}
