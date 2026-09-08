import 'package:digi_card_app/data/db/app_database.dart';
import 'package:digi_card_app/data/db/card_data_versions.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('the pinned versions', () {
    // These three numbers decide what an app update costs the person using it,
    // and two of them are easy to raise by reflex. The test pins all three so
    // that changing one is a deliberate edit with a reason attached, rather
    // than a number that drifted upwards.
    //
    // Raising `schemaVersion`: the tables changed. Migrate them in `onUpgrade`
    // and update the expectation here.
    //
    // Raising `CardDataVersions.invalidatedAt`: every user re-downloads 25 MB
    // and re-fetches 93 expansions. It is only correct when the stored rows
    // genuinely cannot be repaired from what is on the device — a new column
    // only the API can fill, or a value parsed from an API field the database
    // does not keep. If the change is in how *stored text* is read, raise
    // `derived` instead and leave this alone.
    //
    // Raising `CardDataVersions.derived`: the parsers read stored card text
    // differently. Costs a local pass over the rows and no network. This is
    // the one to reach for.
    test('are what this build declares', () {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      expect(db.schemaVersion, 12);
      expect(CardDataVersions.invalidatedAt, 9);
      expect(CardDataVersions.derived, 2);
    });

    test('a schema bump cannot silently invalidate the card data', () {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      expect(
        CardDataVersions.invalidatedAt,
        lessThanOrEqualTo(db.schemaVersion),
        reason:
            'a version that has never existed cannot have invalidated '
            'anything',
      );
    });
  });

  group('needsCardReset', () {
    test('only a database older than the last invalidating version', () {
      expect(CardDataVersions.needsCardReset(8), isTrue);
      expect(CardDataVersions.needsCardReset(9), isFalse);
    });

    test('the versions added since keep their cards', () {
      // Staples (11) and the derived-version column (12) do not touch a single
      // card row, and neither did the keyword fix (10) — that one is a
      // re-derivation. None of them may cost a download.
      for (var from = CardDataVersions.invalidatedAt; from <= 12; from++) {
        expect(
          CardDataVersions.needsCardReset(from),
          isFalse,
          reason: 'upgrading from schema $from',
        );
      }
    });
  });

  group('needsRederive', () {
    test('a database that never recorded a version is stale', () {
      // Every install that predates the mechanism reports 0.
      expect(CardDataVersions.needsRederive(0), isTrue);
    });

    test('one written by this build is not', () {
      expect(CardDataVersions.needsRederive(CardDataVersions.derived), isFalse);
    });

    test('a newer database is left alone', () {
      // Downgrading is not supported, but re-deriving with older parsers would
      // actively make the data worse, so the check is one-directional.
      expect(
        CardDataVersions.needsRederive(CardDataVersions.derived + 1),
        isFalse,
      );
    });
  });
}
