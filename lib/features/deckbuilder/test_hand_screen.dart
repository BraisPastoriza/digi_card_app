import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/router/navigation.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/deck.dart';
import '../../l10n/l10n.dart';
import '../../domain/models/digimon_card.dart';
import '../../domain/models/test_hand.dart';
import '../../shared/widgets/card_thumbnail.dart';
import '../../shared/widgets/common.dart';
import 'deck_providers.dart';

/// Deals a revision's opening hand and security stack, over and over.
///
/// This is the question a deck list cannot answer on its own: not whether the
/// cards are in there, but how often they arrive together. Redealing is the
/// whole point of the screen, so the button that does it sits under the thumb.
class TestHandScreen extends ConsumerStatefulWidget {
  const TestHandScreen({
    super.key,
    required this.deckId,
    required this.revisionId,
  });

  final int deckId;
  final int revisionId;

  @override
  ConsumerState<TestHandScreen> createState() => _TestHandScreenState();
}

class _TestHandScreenState extends ConsumerState<TestHandScreen> {
  /// Seed of the deal on screen.
  ///
  /// The seed is kept rather than the cards it produced, so the opening
  /// survives a rebuild — a card image arriving, the deck being edited in
  /// another tab — instead of quietly reshuffling itself while it is being
  /// read.
  int _seed = Random().nextInt(1 << 32);

  void _dealAgain() => setState(() => _seed = Random().nextInt(1 << 32));

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final deck = ref.watch(deckProvider(widget.deckId)).valueOrNull;
    final revision = deck?.revisions.firstWhereOrNull(
      (r) => r.id == widget.revisionId,
    );
    final composition = ref.watch(compositionProvider(widget.revisionId));

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.goBack('/decks/${widget.deckId}'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.handTitle),
            if (revision != null)
              Text(
                revision.name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
      body: composition.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: context.l10n.revisionLoadError,
          message: '$error',
        ),
        data: (composition) {
          final hand = TestHand.deal(composition, random: Random(_seed));
          if (hand == null) {
            return EmptyState(
              icon: Icons.style_outlined,
              title: context.l10n.handNotFullTitle,
              message:
                  context.l10n.handNotFullMessage(
                    composition.mainDeckCount,
                    DeckRules.mainDeckSize,
                  ),
              action: FilledButton.icon(
                onPressed: () => context.pushOnce(
                  '/decks/${widget.deckId}/add/${widget.revisionId}',
                ),
                icon: const Icon(Icons.add, size: 18),
                label: Text(context.l10n.deckAddCards),
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    SectionHeader(
                      context.l10n.handOpeningTitle,
                      subtitle: context.l10n.handOpeningSubtitle,
                    ),
                    _CardRow(cards: hand.hand),
                    SectionHeader(
                      context.l10n.handSecurityTitle,
                      subtitle: context.l10n.handSecuritySubtitle,
                    ),
                    _CardRow(cards: hand.security, numbered: true),
                  ],
                ),
              ),
              _DealBar(onDeal: _dealAgain),
            ],
          );
        },
      ),
    );
  }
}

/// The five cards of one pile, side by side so a whole opening is read at a
/// glance rather than scrolled through.
class _CardRow extends StatelessWidget {
  const _CardRow({required this.cards, this.numbered = false});

  final List<DigimonCard> cards;

  /// Numbers the cards, which security needs: the stack is checked in order,
  /// so which card is on top is part of what is being tested.
  final bool numbered;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        // The gap belongs to the row, not to the cards: padding one side of
        // each card leaves the last one wider, and a wider card is a taller
        // card, which drops its name below the other four.
        spacing: 6,
        children: [
          for (final (index, card) in cards.indexed)
            Expanded(
              child: _DealtCard(
                card: card,
                position: numbered ? index + 1 : null,
              ),
            ),
        ],
      ),
    );
  }
}

class _DealtCard extends StatelessWidget {
  const _DealtCard({required this.card, this.position});

  final DigimonCard card;
  final int? position;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            GestureDetector(
              onTap: () => context.pushOnce('/card/${card.number}'),
              child: AspectRatio(
                aspectRatio: cardAspectRatio,
                child: CardThumbnail(card: card, borderRadius: 7),
              ),
            ),
            if (position != null)
              Positioned(
                top: 3,
                left: 3,
                child: Container(
                  width: 16,
                  height: 16,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppSurfaces.background.withValues(alpha: 0.85),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppSurfaces.outline),
                  ),
                  child: Text(
                    '$position',
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          card.name,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 9.5, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

/// The redeal button, on a bar of its own so it stays put while the cards
/// above it change.
class _DealBar extends StatelessWidget {
  const _DealBar({required this.onDeal});

  final VoidCallback onDeal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppSurfaces.surfaceHigh,
        border: Border(top: BorderSide(color: AppSurfaces.outline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: onDeal,
            icon: const Icon(Icons.shuffle, size: 18),
            label: Text(context.l10n.handTestAgain),
          ),
        ),
      ),
    );
  }
}
