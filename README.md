# DigiCard App

A Digimon Card Game card library and deck builder, built with Flutter for
Android and iOS.

Fan-made and not affiliated with Bandai, Toei Animation or Akiyoshi Hongo.
See [Attribution](#attribution).

## Installing

Download the APK from the [latest
release](https://github.com/BraisPastoriza/digi_card_app/releases/latest) and
open it on your phone. Android will ask you to allow installing from your
browser or file manager, since this is not coming from the Play Store.

Check the SHA-256 printed in the release notes against the file you downloaded
if you want to be sure it is the build that was published.

The first launch downloads the card database, about 25 MB over roughly two
minutes. After that the app works offline.

## What it does

**Library** — every English card, browsable by expansion (BT, EX, ST, AD, LM,
promos and other products) and searchable by name, effect text, trait, colour,
card type, level, play/use cost, digivolution cost, DP, rarity, attribute,
form, keyword and expansion. Card pages show the full rules text, digivolution
requirements, alternate arts, official rulings, errata and restriction status.

**Deck builder** — decks of 50 main-deck cards plus up to 5 Digi-Eggs, checked
against the official rules and the current restriction list as you build.
Every deck holds named **revisions**: one is active and takes your edits, and
you can branch a new one from it to try a change without losing the list that
was working.

Everything runs offline. The card database is downloaded once and stored
locally; card images are cached as you view them.

## Card data

Card data comes from the [Heroicc API](https://heroi.cc/docs/api) at
`https://api.heroi.cc`, which is public and unauthenticated.

Both APIs are run as a courtesy, so every request the app makes identifies
itself: `DigiCardApp/<version> (+<repository URL>)`, defined once in
`AppInfo`. An operator looking at their access log can tell which client the
traffic is, what version of it, and read the code that produced it. The
secondary source publishes a rate limit, and the client backs off and retries
when it is told to rather than treating a 429 as an empty set.

The app syncs by downloading the English bulk dump (~25 MB, ~7,700 printings
covering ~4,400 distinct cards) in one request and writing it to a local
SQLite database, rather than fetching cards individually — the per-card and
per-release endpoints return only identifiers, so building the library card by
card would take thousands of requests.

Sets Heroicc has not published yet come from a second source, the
[digimoncard.io public API](https://digimoncard.io/api-documentation), one
request per set. Those sets are marked PREVIEW throughout the app: their data
is community-maintained, still changing, and carries no rulings or alternate
arts. The list of them is hardcoded in `previewReleases`, and each one retires
itself the day Heroicc starts publishing it — the sync skips any preview whose
id the primary API already serves, so no code has to be deleted.

Two things the API does not provide are derived at sync time:

- **Keywords** (`Blocker`, `Rush`, `Piercing`, …) are parsed out of the effect
  text, where they appear wrapped in angle brackets. See `KeywordParser`.
- **Alternative digivolution conditions** — the `[Digivolve]`,
  `[DNA Digivolve]` and `[Burst Digivolve]` lines a card prints in its effect
  box, which around 2,200 cards have on top of the single condition the API
  models as data. See `DigivolveParser`. These are derived when a card is read
  from the database rather than when it is written, so a change to the parser
  reaches the user on the next app update instead of costing them a 25 MB
  re-download.
- **Expansion grouping** (BT / EX / ST / AD / LM) comes from the release slug,
  because the API's own `genre` field files BT, EX and AD together as
  "Booster Pack".

Card images are © Akiyoshi Hongo, Toei Animation and Bandai, and are shown
unmodified as the API's terms require: never cropped, and never covered by a
watermark or a copy count — which is why the deck-image export puts its badge
in the top corner, away from the copyright line printed along the bottom edge
of every card.

## Running it

```bash
flutter pub get
dart run build_runner build --force-jit   # generates the drift database code
flutter run
```

`--force-jit` is required: a package in the dependency graph ships build
hooks, which the default AOT path for the build script cannot compile.

### Building a release

Release builds are signed with a key that is not in this repository. Create one
once:

```bash
keytool -genkey -v -keystore ~/digicard-upload.jks -keyalg RSA         -keysize 2048 -validity 10000 -alias upload
```

Then write `android/key.properties`, which `.gitignore` keeps out of the repo:

```properties
storePassword=<the password you chose>
keyPassword=<the same one, unless you set a separate key password>
keyAlias=upload
storeFile=/absolute/path/to/digicard-upload.jks
```

```bash
flutter build apk --release                 # one APK, every ABI
flutter build apk --release --split-per-abi # three smaller ones
flutter build appbundle --release           # for the Play Store
```

Keep the keystore and its passwords backed up somewhere you will not lose them.
Android identifies an app by its signing key: lose it and no existing install
can ever be updated again. Without `key.properties` the build still works, but
falls back to the shared debug key — fine for `flutter run`, never for
something you hand to someone.

### Tests

```bash
flutter test
```

The suite covers keyword parsing, card-number sort keys, deck legality and the
restriction list — the logic that would silently produce wrong results rather
than crash.

### Inspecting the card data

`tool/inspect_bulk.dart` parses a downloaded bulk dump and prints a summary
(keyword and trait tallies, sort ordering, cards missing a release link).
Useful when the API changes shape:

```bash
curl -H "User-Agent: DigiCardApp/1.1.0 (+https://github.com/BraisPastoriza/digi_card_app)"   https://api.heroi.cc/bulk-data
curl -o en.json <the English download link from that response>
dart run tool/inspect_bulk.dart en.json
```

## Layout

```
lib/
  core/            theme, router, providers, card-text parsing
  domain/models/   cards, releases, decks, filters, deck rules
  data/
    api/           Heroicc API client
    db/            drift schema, DAOs, row mappers
    sync/          bulk download, isolate parsing, database load
  features/
    library/       expansions, search, filters, card detail
    deckbuilder/   deck list, editor, revisions, stats, card picker
    sync/          first-run download screen
  shared/widgets/  card thumbnails, game text, common UI
```

State is Riverpod; storage is SQLite through drift, with an FTS5 index over
card text; navigation is go_router.

The database holds two kinds of thing, and they are treated differently. Card
data is a cache of the published card list: a schema change throws it away and
re-syncs rather than migrating column by column. Decks are the only data the
user authored, so they survive every upgrade — which works because a deck
references cards by printed number, not by row.

Adding a column to a card table therefore only needs `schemaVersion` bumped;
adding one to a deck table needs a real migration step.

## Attribution

Card images, card text and related imagery are the intellectual property of
© Akiyoshi Hongo, Toei Animation and © BANDAI. This project is not affiliated
with, endorsed by, or connected to Bandai Namco Entertainment, Toei Animation,
Heroicc or digimoncard.io.

Original content provided by Heroicc is used under
[CC BY-NC-SA 4.0](https://creativecommons.org/licenses/by-nc-sa/4.0/). The
**NonCommercial** term applies to the app as it runs, not just to this
repository: no ads, no paid version, no monetisation while it uses that data.

The app carries the same notice in-app, under Library → ⓘ → Data sources &
credits.

## Licence

The source code is [MIT](LICENSE). That covers the code and nothing else — the
card data and artwork belong to the parties above and are not licensed by it.
`LICENSE` spells out the split.

## Roadmap

1.1.0 covers the library, the deck builder with revisions, deck import and
export, and the preview sets.

Planned next:

- **API courtesy** — a User-Agent that identifies the project rather than a
  bare name, and fewer requests per sync: a first run currently makes one call
  per expansion on top of the bulk download.

- **Suggestions** — cards an algorithm rates as a fit for the deck being built,
  by shared traits, name families and other heuristics.
- **Staples** — a curated list of generic staples, plus a personal
  "My Staples" list the user fills from the library.
- **Accounts** — publishing and sharing decks, and tracking a physical
  collection.
