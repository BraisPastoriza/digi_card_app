import 'package:drift/drift.dart';

import '../../../domain/models/deck.dart';
import '../../../domain/models/digimon_card.dart';
import '../app_database.dart';
import '../mappers.dart';
import '../tables.dart';

part 'deck_dao.g.dart';

@DriftAccessor(tables: [Decks, DeckRevisions, DeckEntries, Cards])
class DeckDao extends DatabaseAccessor<AppDatabase> with _$DeckDaoMixin {
  DeckDao(super.db);

  /// Decks with their revisions, most recently edited first. Entries are left
  /// out: the list screen only needs counts, which it reads per revision.
  Stream<List<Deck>> watchDecks() {
    final query = select(decks)
      ..orderBy([(d) => OrderingTerm.desc(d.updatedAt)]);
    return query.watch().asyncMap((rows) async {
      final revisions = await _revisionsForDecks(rows.map((d) => d.id));
      return rows
          .map((row) => _toDeck(row, revisions[row.id] ?? const []))
          .toList();
    });
  }

  Stream<Deck?> watchDeck(int deckId) {
    final query = select(decks)..where((d) => d.id.equals(deckId));
    return query.watchSingleOrNull().asyncMap((row) async {
      if (row == null) return null;
      final revisions = await _revisionsForDecks([deckId]);
      return _toDeck(row, revisions[deckId] ?? const []);
    });
  }

  /// The cards in a revision, resolved against the library.
  Stream<List<DeckEntry>> watchRevisionEntries(int revisionId) {
    final query = select(deckEntries)
      ..where((e) => e.revisionId.equals(revisionId));
    return query.watch().asyncMap(_resolveEntries);
  }

  Future<List<DeckEntry>> revisionEntries(int revisionId) async {
    final rows = await (select(
      deckEntries,
    )..where((e) => e.revisionId.equals(revisionId))).get();
    return _resolveEntries(rows);
  }

  /// Name a deck gets when the user did not supply one, if the screen does
  /// not pass one of its own.
  ///
  /// Creating a deck does not stop to ask: naming it is far easier once you
  /// can see what is in it, and the deck list renames in place. Screens pass
  /// the name in the reader's language; this is the fallback for callers with
  /// no interface to read it from.
  static const defaultDeckName = 'New Deck';

  /// [base], numbered past the decks already called that, so a shelf of
  /// unnamed decks can still be told apart.
  Future<String> nextDefaultDeckName({String base = defaultDeckName}) async {
    final taken = (await select(decks).get()).map((d) => d.name).toSet();
    if (!taken.contains(base)) return base;
    for (var suffix = 2; ; suffix++) {
      final candidate = '$base $suffix';
      if (!taken.contains(candidate)) return candidate;
    }
  }

  /// Creates a deck along with its first revision, which becomes the active
  /// one. A deck always has at least one revision.
  Future<int> createDeck({
    String? name,
    String? description,
    String firstRevisionName = 'v1',
  }) async {
    final deckName = name ?? await nextDefaultDeckName();
    return transaction(() async {
      final now = DateTime.now();
      final deckId = await into(decks).insert(
        DecksCompanion.insert(
          name: deckName,
          description: Value(description),
          createdAt: now,
          updatedAt: now,
        ),
      );
      final revisionId = await into(deckRevisions).insert(
        DeckRevisionsCompanion.insert(
          deckId: deckId,
          name: firstRevisionName,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await (update(decks)..where((d) => d.id.equals(deckId))).write(
        DecksCompanion(activeRevisionId: Value(revisionId)),
      );
      return deckId;
    });
  }

  /// The revision a deck is currently being edited on, for callers that need
  /// it right after creating the deck and have nothing to listen to yet.
  Future<int?> activeRevisionIdOf(int deckId) async {
    final deck = await (select(
      decks,
    )..where((d) => d.id.equals(deckId))).getSingleOrNull();
    if (deck?.activeRevisionId != null) return deck!.activeRevisionId;

    final fallback =
        await (select(deckRevisions)
              ..where((r) => r.deckId.equals(deckId))
              ..orderBy([(r) => OrderingTerm.asc(r.createdAt)])
              ..limit(1))
            .getSingleOrNull();
    return fallback?.id;
  }

  Future<void> updateDeck(
    int deckId, {
    String? name,
    String? description,
  }) async {
    await (update(decks)..where((d) => d.id.equals(deckId))).write(
      DecksCompanion(
        name: name == null ? const Value.absent() : Value(name),
        description: description == null
            ? const Value.absent()
            : Value(description),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Pins the card whose art stands for the deck in the deck list. Null hands
  /// the choice back to the deck itself.
  Future<void> setDeckThumbnail(int deckId, String? cardNumber) async {
    await (update(decks)..where((d) => d.id.equals(deckId))).write(
      DecksCompanion(
        thumbnailCardNumber: Value(cardNumber),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Throws a deck away when it holds no cards in any of its revisions.
  ///
  /// A deck is a container for cards, and one created and left empty is a row
  /// the user never really asked for — creating a deck opens it straight away,
  /// so backing out of that screen is how somebody says "not this after all".
  /// Called when the editor closes; returns whether the deck was discarded.
  ///
  /// It counts across every revision on purpose: a deck whose cards live on a
  /// branch the user is not currently editing is not empty.
  Future<bool> discardIfEmpty(int deckId) async {
    final revisions = await (select(
      deckRevisions,
    )..where((r) => r.deckId.equals(deckId))).get();

    if (revisions.isNotEmpty) {
      final cards = deckEntries.quantity.sum();
      final row =
          await (selectOnly(deckEntries)
                ..addColumns([cards])
                ..where(
                  deckEntries.revisionId.isIn(revisions.map((r) => r.id)),
                ))
              .getSingle();
      if ((row.read(cards) ?? 0) > 0) return false;
    }

    await deleteDeck(deckId);
    return true;
  }

  Future<void> deleteDeck(int deckId) async {
    await (delete(decks)..where((d) => d.id.equals(deckId))).go();
  }

  Future<void> setActiveRevision(int deckId, int revisionId) async {
    await (update(decks)..where((d) => d.id.equals(deckId))).write(
      DecksCompanion(
        activeRevisionId: Value(revisionId),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Branches a new revision off [sourceRevisionId], copying its cards, and
  /// makes it the active one so the user keeps editing where they left off.
  Future<int> createRevisionFrom({
    required int deckId,
    required int sourceRevisionId,
    required String name,
    bool makeActive = true,
  }) async {
    return transaction(() async {
      final now = DateTime.now();
      final revisionId = await into(deckRevisions).insert(
        DeckRevisionsCompanion.insert(
          deckId: deckId,
          name: name,
          createdAt: now,
          updatedAt: now,
        ),
      );
      final source = await (select(
        deckEntries,
      )..where((e) => e.revisionId.equals(sourceRevisionId))).get();
      if (source.isNotEmpty) {
        await batch((b) {
          b.insertAll(deckEntries, [
            for (final entry in source)
              DeckEntriesCompanion.insert(
                revisionId: revisionId,
                cardNumber: entry.cardNumber,
                quantity: entry.quantity,
                printingId: Value(entry.printingId),
              ),
          ]);
        });
      }
      await (update(decks)..where((d) => d.id.equals(deckId))).write(
        DecksCompanion(
          activeRevisionId: makeActive
              ? Value(revisionId)
              : const Value.absent(),
          updatedAt: Value(now),
        ),
      );
      return revisionId;
    });
  }

  /// Creates an empty revision, for starting a variant from scratch.
  Future<int> createEmptyRevision({
    required int deckId,
    required String name,
    bool makeActive = true,
  }) async {
    return transaction(() async {
      final now = DateTime.now();
      final revisionId = await into(deckRevisions).insert(
        DeckRevisionsCompanion.insert(
          deckId: deckId,
          name: name,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await (update(decks)..where((d) => d.id.equals(deckId))).write(
        DecksCompanion(
          activeRevisionId: makeActive
              ? Value(revisionId)
              : const Value.absent(),
          updatedAt: Value(now),
        ),
      );
      return revisionId;
    });
  }

  Future<void> renameRevision(int revisionId, String name) async {
    await (update(deckRevisions)..where((r) => r.id.equals(revisionId))).write(
      DeckRevisionsCompanion(
        name: Value(name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes a revision. Refuses to remove the last one, since a deck without
  /// a revision has nowhere to hold its cards.
  Future<bool> deleteRevision(int deckId, int revisionId) async {
    return transaction(() async {
      final siblings = await (select(
        deckRevisions,
      )..where((r) => r.deckId.equals(deckId))).get();
      if (siblings.length <= 1) return false;

      await (delete(deckRevisions)..where((r) => r.id.equals(revisionId))).go();

      final deck = await (select(
        decks,
      )..where((d) => d.id.equals(deckId))).getSingle();
      if (deck.activeRevisionId == revisionId) {
        final fallback = siblings.firstWhere((r) => r.id != revisionId);
        await (update(decks)..where((d) => d.id.equals(deckId))).write(
          DecksCompanion(
            activeRevisionId: Value(fallback.id),
            updatedAt: Value(DateTime.now()),
          ),
        );
      }
      return true;
    });
  }

  /// Sets how many copies of a card a revision holds. A quantity of zero or
  /// less removes the entry.
  Future<void> setQuantity({
    required int revisionId,
    required String cardNumber,
    required int quantity,
    String? printingId,
  }) async {
    await transaction(() async {
      if (quantity <= 0) {
        await (delete(deckEntries)..where(
              (e) =>
                  e.revisionId.equals(revisionId) &
                  e.cardNumber.equals(cardNumber),
            ))
            .go();
      } else {
        await into(deckEntries).insertOnConflictUpdate(
          DeckEntriesCompanion.insert(
            revisionId: revisionId,
            cardNumber: cardNumber,
            quantity: quantity,
            printingId: Value(printingId),
          ),
        );
      }
      await _touchRevision(revisionId);
    });
  }

  /// Adds [delta] copies of a card, clamped to the copy limit the restriction
  /// list allows. Returns the resulting quantity.
  Future<int> adjustQuantity({
    required int revisionId,
    required DigimonCard card,
    required int delta,
  }) async {
    // The last line of defence: tokens are created by card effects during
    // play and can never be part of a deck, whichever screen asked.
    if (card.isToken) return 0;
    return transaction(() async {
      final existing =
          await (select(deckEntries)..where(
                (e) =>
                    e.revisionId.equals(revisionId) &
                    e.cardNumber.equals(card.number),
              ))
              .getSingleOrNull();
      final current = existing?.quantity ?? 0;
      final next = (current + delta).clamp(0, card.copyLimit);
      await setQuantity(
        revisionId: revisionId,
        cardNumber: card.number,
        quantity: next,
        printingId:
            existing?.printingId ?? (card.isBasePrinting ? null : card.id),
      );
      return next;
    });
  }

  /// Swaps which printing's art an entry displays.
  Future<void> setEntryPrinting({
    required int revisionId,
    required String cardNumber,
    String? printingId,
  }) async {
    await transaction(() async {
      await (update(deckEntries)..where(
            (e) =>
                e.revisionId.equals(revisionId) &
                e.cardNumber.equals(cardNumber),
          ))
          .write(DeckEntriesCompanion(printingId: Value(printingId)));
      await _touchRevision(revisionId);
    });
  }

  /// Creates a deck whose first revision holds [quantities], keyed by card
  /// number. Used by the deck-list importer.
  Future<int> createDeckFromList({
    String? name,
    required String revisionName,
    required Map<String, int> quantities,
  }) async {
    final deckId = await createDeck(
      name: name,
      firstRevisionName: revisionName,
    );
    final revisionId = await activeRevisionIdOf(deckId);
    if (revisionId != null) await replaceEntries(revisionId, quantities);
    return deckId;
  }

  /// Adds an imported list to an existing deck as a revision of its own, so a
  /// list found elsewhere can be tried against the deck it belongs to without
  /// overwriting it.
  Future<int> createRevisionFromList({
    required int deckId,
    required String name,
    required Map<String, int> quantities,
    bool makeActive = true,
  }) async {
    final revisionId = await createEmptyRevision(
      deckId: deckId,
      name: name,
      makeActive: makeActive,
    );
    await replaceEntries(revisionId, quantities);
    return revisionId;
  }

  /// Replaces everything in a revision with [quantities], keyed by card
  /// number. Copies are written as given; legality is reported by
  /// [DeckComposition], not enforced here.
  Future<void> replaceEntries(
    int revisionId,
    Map<String, int> quantities,
  ) async {
    await transaction(() async {
      await (delete(
        deckEntries,
      )..where((e) => e.revisionId.equals(revisionId))).go();
      final wanted = quantities.entries.where((e) => e.value > 0).toList();
      if (wanted.isNotEmpty) {
        await batch((b) {
          b.insertAll(deckEntries, [
            for (final entry in wanted)
              DeckEntriesCompanion.insert(
                revisionId: revisionId,
                cardNumber: entry.key,
                quantity: entry.value,
              ),
          ]);
        });
      }
      await _touchRevision(revisionId);
    });
  }

  Future<void> clearRevision(int revisionId) async {
    await transaction(() async {
      await (delete(
        deckEntries,
      )..where((e) => e.revisionId.equals(revisionId))).go();
      await _touchRevision(revisionId);
    });
  }

  /// Bumps the revision's and its deck's `updatedAt`, so the deck list orders
  /// by real activity.
  Future<void> _touchRevision(int revisionId) async {
    final now = DateTime.now();
    await (update(deckRevisions)..where((r) => r.id.equals(revisionId))).write(
      DeckRevisionsCompanion(updatedAt: Value(now)),
    );
    final revision = await (select(
      deckRevisions,
    )..where((r) => r.id.equals(revisionId))).getSingleOrNull();
    if (revision == null) return;
    await (update(decks)..where((d) => d.id.equals(revision.deckId))).write(
      DecksCompanion(updatedAt: Value(now)),
    );
  }

  Future<Map<int, List<DeckRevision>>> _revisionsForDecks(
    Iterable<int> deckIds,
  ) async {
    final ids = deckIds.toList();
    if (ids.isEmpty) return {};
    final query = select(deckRevisions)
      ..where((r) => r.deckId.isIn(ids))
      ..orderBy([(r) => OrderingTerm.asc(r.createdAt)]);
    final rows = await query.get();
    final grouped = <int, List<DeckRevision>>{};
    for (final row in rows) {
      grouped
          .putIfAbsent(row.deckId, () => [])
          .add(
            DeckRevision(
              id: row.id,
              deckId: row.deckId,
              name: row.name,
              createdAt: row.createdAt,
              updatedAt: row.updatedAt,
            ),
          );
    }
    return grouped;
  }

  /// Joins entry rows against the library. Entries whose card is missing from
  /// the local database are dropped rather than shown as blanks; that only
  /// happens if a sync removed a card the deck referenced.
  Future<List<DeckEntry>> _resolveEntries(List<DeckEntryRow> rows) async {
    if (rows.isEmpty) return const [];

    final numbers = rows.map((r) => r.cardNumber).toSet();
    final printingIds = rows
        .map((r) => r.printingId)
        .whereType<String>()
        .toSet();

    final primaryQuery = select(cards)
      ..where((c) => c.number.isIn(numbers) & c.isPrimary.equals(true));
    final byNumber = {
      for (final row in await primaryQuery.get()) row.number: row,
    };

    final byPrintingId = <String, CardRow>{};
    if (printingIds.isNotEmpty) {
      final printingQuery = select(cards)..where((c) => c.id.isIn(printingIds));
      for (final row in await printingQuery.get()) {
        byPrintingId[row.id] = row;
      }
    }

    final entries = <DeckEntry>[];
    for (final row in rows) {
      final chosen = byPrintingId[row.printingId] ?? byNumber[row.cardNumber];
      if (chosen == null) continue;
      entries.add(
        DeckEntry(
          cardNumber: row.cardNumber,
          quantity: row.quantity,
          printingId: row.printingId,
          card: chosen.toDigimonCard(),
        ),
      );
    }
    return entries;
  }

  Deck _toDeck(DeckRow row, List<DeckRevision> revisions) => Deck(
    id: row.id,
    name: row.name,
    description: row.description,
    thumbnailCardNumber: row.thumbnailCardNumber,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    activeRevisionId: row.activeRevisionId,
    revisions: revisions,
  );
}
