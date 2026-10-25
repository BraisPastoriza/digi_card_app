import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router/navigation.dart';
import '../../core/theme/digimon_colors.dart';
import '../../domain/models/deck.dart';
import '../../domain/models/restriction_change.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/common.dart';
import 'deck_providers.dart';

/// What the last card syncs changed on the restriction list, until the user
/// has seen it.
final restrictionChangesProvider = StreamProvider<List<RestrictionChange>>((
  ref,
) {
  final db = ref.watch(appDatabaseProvider);
  return db
      .select(db.restrictionChanges)
      .watch()
      .map(
        (rows) => [
          for (final row in rows)
            if (row.partnerNumber case final partner?)
              PairChange(
                cardNumber: row.cardNumber,
                cardName: row.cardName,
                partnerNumber: partner,
                partnerName: row.partnerName ?? partner,
                banned: row.pairBanned ?? true,
              )
            else if ((row.oldLimit, row.newLimit) case (final old?, final now?))
              LimitChange(
                cardNumber: row.cardNumber,
                cardName: row.cardName,
                oldLimit: old,
                newLimit: now,
              ),
        ],
      );
});

final _activeQuantitiesProvider = StreamProvider<Map<int, Map<String, int>>>(
  (ref) => ref.watch(deckDaoProvider).watchActiveQuantities(),
);

/// The decks a restriction change reaches, with what it does to each, in the
/// order the deck list shows them.
final deckRestrictionImpactsProvider =
    Provider<List<({Deck deck, List<DeckRestrictionImpact> impacts})>>((ref) {
      final changes = ref.watch(restrictionChangesProvider).valueOrNull;
      if (changes == null || changes.isEmpty) return const [];
      final decks = ref.watch(decksProvider).valueOrNull ?? const [];
      final quantities =
          ref.watch(_activeQuantitiesProvider).valueOrNull ?? const {};
      return [
        for (final deck in decks)
          if (impactOn(quantities[deck.id] ?? const {}, changes)
              case final impacts when impacts.isNotEmpty)
            (deck: deck, impacts: impacts),
      ];
    });

/// Forgets the recorded changes once the user has seen them.
Future<void> dismissRestrictionChanges(WidgetRef ref) {
  final db = ref.read(appDatabaseProvider);
  return db.delete(db.restrictionChanges).go();
}

/// Tells the user, on the deck list, which of their decks the restriction
/// list changed and how.
///
/// A deck's legality badge already turns red on its own; this says why, which
/// is the part a player cannot work out from the badge — the deck was legal
/// yesterday and nothing in it changed.
class RestrictionChangesBanner extends ConsumerWidget {
  const RestrictionChangesBanner({super.key, this.margin = EdgeInsets.zero});

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affected = ref.watch(deckRestrictionImpactsProvider);
    if (affected.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;

    return NoticeBanner(
      icon: Icons.gavel,
      title: l10n.restrictionsTitle,
      margin: margin,
      body: [
        for (final (:deck, :impacts) in affected) ...[
          const SizedBox(height: 4),
          InkWell(
            onTap: () => context.pushOnce('/decks/${deck.id}'),
            child: Text(
              deck.name,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
          for (final impact in impacts)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6, right: 8),
                  child: Icon(
                    Icons.circle,
                    size: 7,
                    color: impact.breaksDeck
                        ? scheme.error
                        : DigimonColors.green,
                  ),
                ),
                Expanded(
                  child: NoticeBanner.text(context, describe(impact, l10n)),
                ),
              ],
            ),
        ],
      ],
      actions: [
        TextButton(
          onPressed: () => dismissRestrictionChanges(ref),
          child: Text(l10n.restrictionsDismiss),
        ),
      ],
    );
  }

  static String describe(DeckRestrictionImpact impact, AppLocalizations l10n) {
    final change = impact.change;
    return switch (change) {
      LimitChange(newLimit: 0) => l10n.restrictionsBanned(
        change.cardName,
        impact.copies,
      ),
      LimitChange(:final newLimit, isTighter: true) => l10n.restrictionsLimited(
        change.cardName,
        newLimit,
        impact.copies,
      ),
      LimitChange(:final newLimit)
          when newLimit >= DeckRules.defaultCopyLimit =>
        l10n.restrictionsFreed(change.cardName),
      LimitChange(:final newLimit) => l10n.restrictionsRaised(
        change.cardName,
        newLimit,
      ),
      PairChange(:final partnerName, banned: true) =>
        l10n.restrictionsPairBanned(change.cardName, partnerName),
      PairChange(:final partnerName) => l10n.restrictionsPairLifted(
        change.cardName,
        partnerName,
      ),
    };
  }
}

/// The same news on the library, which is where a session starts: one line
/// and a way to the decks, where the details are.
class RestrictionChangesTeaser extends ConsumerWidget {
  const RestrictionChangesTeaser({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affected = ref.watch(deckRestrictionImpactsProvider);
    if (affected.isEmpty) return const SizedBox.shrink();
    final l10n = context.l10n;
    return NoticeBanner(
      icon: Icons.gavel,
      title: l10n.restrictionsTitle,
      body: [
        NoticeBanner.text(context, l10n.restrictionsAffects(affected.length)),
      ],
      actions: [
        TextButton(
          onPressed: () => context.go('/decks'),
          child: Text(l10n.restrictionsShowDecks),
        ),
      ],
    );
  }
}
