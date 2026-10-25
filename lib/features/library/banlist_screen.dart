import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/navigation.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/banlist.dart';
import '../../domain/models/digimon_card.dart';
import '../../l10n/l10n.dart';
import '../../shared/widgets/card_thumbnail.dart';
import '../../shared/widgets/common.dart';
import 'library_providers.dart';
import 'widgets/card_grid.dart';

/// The restriction list in force: banned cards, cards limited to fewer than
/// four copies, and the pairs no deck may run together.
class BanlistScreen extends ConsumerWidget {
  const BanlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final banlist = ref.watch(banlistProvider);
    final scheme = Theme.of(context).colorScheme;

    void openCard(DigimonCard card) => context.pushOnce('/card/${card.number}');

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            leading: IconButton(
              onPressed: () => context.goBack('/library'),
              icon: const Icon(Icons.arrow_back),
            ),
            title: Text(context.l10n.banlistTitle),
          ),
          ...banlist.when(
            loading: () => const [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
            error: (error, _) => [
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.error_outline,
                  title: context.l10n.banlistError,
                  message: '$error',
                ),
              ),
            ],
            data: (banlist) => banlist.isEmpty
                ? [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        icon: Icons.gavel,
                        title: context.l10n.banlistEmptyTitle,
                        message: context.l10n.banlistEmptyMessage,
                      ),
                    ),
                  ]
                : [
                    if (banlist.latestDate case final date?)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                          child: Text(
                            context.l10n.banlistLatestChange(date),
                            style: TextStyle(
                              fontSize: 13,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    if (banlist.banned.isNotEmpty) ...[
                      _Header(
                        title: context.l10n.banlistBanned,
                        subtitle: context.l10n.banlistBannedSubtitle,
                        count: banlist.banned.length,
                      ),
                      // The heading already says what the list says, so the
                      // tiles go without the badge that would repeat it.
                      SliverCardGrid(
                        cards: banlist.banned,
                        onCardTap: openCard,
                        showRestriction: false,
                      ),
                    ],
                    for (final MapEntry(key: limit, value: cards)
                        in banlist.limited.entries) ...[
                      _Header(
                        title: context.l10n.banlistLimited(limit),
                        count: cards.length,
                      ),
                      SliverCardGrid(
                        cards: cards,
                        onCardTap: openCard,
                        showRestriction: false,
                      ),
                    ],
                    if (banlist.pairs.isNotEmpty) ...[
                      _Header(
                        title: context.l10n.banlistPairs,
                        subtitle: context.l10n.banlistPairsSubtitle,
                        count: banlist.pairs.length,
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 32),
                        sliver: SliverList.separated(
                          itemCount: banlist.pairs.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) => _PairTile(
                            pair: banlist.pairs[index],
                            onCardTap: openCard,
                          ),
                        ),
                      ),
                    ],
                  ],
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.count, this.subtitle});

  final String title;
  final String? subtitle;
  final int count;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SectionHeader(
        title,
        subtitle: subtitle,
        trailing: Text(
          '$count',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// One banned-pair ruling: the card it is written on, then the cards a deck
/// running it may not also run.
class _PairTile extends StatelessWidget {
  const _PairTile({required this.pair, required this.onCardTap});

  static const _thumbWidth = 76.0;

  final BannedPair pair;
  final void Function(DigimonCard) onCardTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    String label(String number) => switch (pair.cards[number]) {
      final card? => '${card.name} ($number)',
      null => number,
    };

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppSurfaces.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppSurfaces.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _thumb(pair.cardNumber),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(Icons.block, size: 22, color: scheme.error),
              ),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final number in pair.partnerNumbers) _thumb(number),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            context.l10n.banlistPairLine(
              label(pair.cardNumber),
              pair.partnerNumbers.map(label).join(', '),
            ),
            style: const TextStyle(fontSize: 13, height: 1.4),
          ),
          if (pair.date != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                context.l10n.banlistSince(pair.date!),
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ),
        ],
      ),
    );
  }

  Widget _thumb(String number) => switch (pair.cards[number]) {
    final card? => SizedBox(
      width: _thumbWidth,
      child: AspectRatio(
        aspectRatio: cardAspectRatio,
        child: GestureDetector(
          onTap: () => onCardTap(card),
          child: CardThumbnail(
            card: card,
            borderRadius: 6,
            showRestriction: false,
          ),
        ),
      ),
    ),
    null => _MissingCard(number: number, width: _thumbWidth),
  };
}

/// Stands in for a card a ruling names that the library does not have.
class _MissingCard extends StatelessWidget {
  const _MissingCard({required this.number, required this.width});

  final String number;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: AspectRatio(
        aspectRatio: cardAspectRatio,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppSurfaces.outline),
          ),
          child: Text(
            number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
