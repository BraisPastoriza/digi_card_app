# DigiCard App

A Digimon Card Game card library and deck builder, built with Flutter for
Android and iOS.

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

The app syncs by downloading the English bulk dump (~25 MB, ~7,600 printings
covering ~4,300 distinct cards) in one request and writing it to a local
SQLite database, rather than fetching cards individually — the per-card and
per-release endpoints return only identifiers, so building the library card by
card would take thousands of requests.

Two things the API does not provide are derived at sync time:

- **Keywords** (`Blocker`, `Rush`, `Piercing`, …) are parsed out of the effect
  text, where they appear wrapped in angle brackets. See `KeywordParser`.
- **Expansion grouping** (BT / EX / ST / AD / LM) comes from the release slug,
  because the API's own `genre` field files BT, EX and AD together as
  "Booster Pack".

Card images are © Akiyoshi Hongo, Toei Animation and Bandai, and are shown
unmodified as the API's terms require.

## Running it

```bash
flutter pub get
dart run build_runner build --force-jit   # generates the drift database code
flutter run
```

`--force-jit` is required: a package in the dependency graph ships build
hooks, which the default AOT path for the build script cannot compile.

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
curl -H "User-Agent: DigiCardApp/1.0" https://api.heroi.cc/bulk-data
curl -o en.json <the English download link from that response>
dart run tool/inspect_bulk.dart en.json
```

## Layout

```
lib/
  core/            theme, router, providers, keyword parsing
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

## Roadmap

Phase 1 (this) covers the library and the deck builder with revisions.

Planned next:

- **Suggestions** — cards an algorithm rates as a fit for the deck being built,
  by shared traits, name families and other heuristics.
- **Staples** — a curated list of generic staples, plus a personal
  "My Staples" list the user fills from the library.
- **Accounts** — publishing and sharing decks, and tracking a physical
  collection.
