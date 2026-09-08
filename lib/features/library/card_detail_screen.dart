import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/digimon_colors.dart';
import '../../domain/models/card_enums.dart';
import '../../domain/models/card_release.dart';
import '../../domain/models/digimon_card.dart';
import '../../shared/widgets/card_image_viewer.dart';
import '../../shared/widgets/card_thumbnail.dart';
import '../../shared/widgets/common.dart';
import '../../shared/widgets/game_text.dart';
import '../deckbuilder/widgets/add_to_deck_sheet.dart';
import 'library_providers.dart';

/// Everything the card database knows about one card, including its alternate
/// arts, rulings, errata and restriction status.
class CardDetailScreen extends ConsumerWidget {
  const CardDetailScreen({super.key, required this.number});

  /// Card number, so every printing of the card opens the same screen.
  final String number;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printings = ref.watch(cardPrintingsProvider(number));

    return Scaffold(
      body: printings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => EmptyState(
          icon: Icons.error_outline,
          title: 'Could not load card',
          message: '$error',
        ),
        data: (printings) => printings.isEmpty
            ? const EmptyState(
                icon: Icons.help_outline,
                title: 'Card not found',
                message: 'It may have been removed in the last card update.',
              )
            : _CardDetailView(printings: printings),
      ),
    );
  }
}

class _CardDetailView extends StatefulWidget {
  const _CardDetailView({required this.printings});

  final List<DigimonCard> printings;

  @override
  State<_CardDetailView> createState() => _CardDetailViewState();
}

class _CardDetailViewState extends State<_CardDetailView> {
  late final PageController _pageController = PageController(
    viewportFraction: 0.72,
  );
  int _index = 0;

  DigimonCard get _card => widget.printings[_index];

  /// Rules data is identical across printings, so the base printing is the
  /// source of truth for everything except the art.
  DigimonCard get _rules => widget.printings.first;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = _rules;
    final limitation = card.activeLimitation;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(card.name, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              tooltip: 'Add to deck',
              onPressed: () => showAddToDeckSheet(context, _card),
              icon: const Icon(Icons.add_box_outlined),
            ),
          ],
        ),
        if (previewReleases.any((p) => card.releaseIds.contains(p.id)))
          const SliverToBoxAdapter(child: _PreviewCardNotice()),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 4),
              SizedBox(
                height: 400,
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: widget.printings.length,
                  onPageChanged: (index) => setState(() => _index = index),
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    child: AnimatedScale(
                      scale: index == _index ? 1 : 0.92,
                      duration: const Duration(milliseconds: 180),
                      child: GestureDetector(
                        onTap: () => showCardImage(
                          context,
                          printings: widget.printings,
                          initialIndex: index,
                        ),
                        child: CardThumbnail(
                          card: widget.printings[index],
                          borderRadius: 14,
                          showColorEdge: false,
                          // The page slot is not the card's aspect ratio, so
                          // covering would crop the top and bottom off the art.
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.printings.length > 1) ...[
                const SizedBox(height: 12),
                _ArtIndicator(
                  printings: widget.printings,
                  index: _index,
                  onSelect: (index) => _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                  ),
                ),
              ],
              const SizedBox(height: 18),
              _Header(card: card, printing: _card),
              if (limitation != null) ...[
                const SizedBox(height: 14),
                _LimitationBanner(limitation: limitation),
              ] else if (card.hasRaisedCopyLimit) ...[
                const SizedBox(height: 14),
                _CopyLimitBanner(limit: card.copyLimit),
              ],
              const SizedBox(height: 20),
              _StatGrid(card: card),
              if (card.digivolutionRequirements.isNotEmpty)
                _DigivolveSection(card: card),
              if (card.effect != null)
                _TextSection(title: 'Effect', text: card.effect!),
              if (card.securityEffect != null)
                _TextSection(
                  title: 'Security effect',
                  text: card.securityEffect!,
                ),
              if (card.inheritedEffect != null)
                _TextSection(
                  title: card.category == CardCategory.digiEgg
                      ? 'Inherited effect'
                      : 'Inherited effects',
                  text: card.inheritedEffect!,
                ),
              if (card.dualFace != null) _DualFaceSection(face: card.dualFace!),
              if (card.errata != null) _ErrataSection(errata: card.errata!),
              _ReleasesSection(card: card),
              if (card.faqs.isNotEmpty) _FaqSection(faqs: card.faqs),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

class _ArtIndicator extends StatelessWidget {
  const _ArtIndicator({
    required this.printings,
    required this.index,
    required this.onSelect,
  });

  final List<DigimonCard> printings;
  final int index;
  final void Function(int) onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final current = printings[index];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < printings.length; i++)
              GestureDetector(
                onTap: () => onSelect(i),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == index ? 18 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: i == index
                        ? scheme.primary
                        : AppSurfaces.outlineStrong,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          current.isBasePrinting
              ? 'Original art'
              : current.notes ?? 'Alternate art ${current.parallelId}',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.card, required this.printing});

  final DigimonCard card;
  final DigimonCard printing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Text(
            card.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              MetaBadge(printing.number, color: scheme.primary),
              MetaBadge(card.category.label),
              if (printing.rarity != null) MetaBadge(printing.rarity!),
              if (card.blockIcon != null) MetaBadge('Block ${card.blockIcon}'),
              if (card.isDual)
                const MetaBadge('Dual card', color: DigimonColors.yellow),
            ],
          ),
          if (card.colors.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ColorDots(colors: card.colors, size: 10),
                const SizedBox(width: 8),
                Text(
                  card.colors.map((c) => c.label).join(' / '),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
          if (card.traits.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              card.traitsLabel,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _LimitationBanner extends StatelessWidget {
  const _LimitationBanner({required this.limitation});

  final CardLimitation limitation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final banned = limitation.effectiveAllowance == 0;
    final accent = banned ? scheme.error : DigimonColors.yellow;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: accent.withValues(alpha: 0.45)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.gavel_rounded, size: 16, color: accent),
                const SizedBox(width: 8),
                Text(
                  banned
                      ? '${limitation.type.label} — not tournament legal'
                      : '${limitation.type.label} to '
                            '${limitation.effectiveAllowance} '
                            '${limitation.effectiveAllowance == 1 ? 'copy' : 'copies'}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
                if (limitation.date != null) ...[
                  const Spacer(),
                  Text(
                    limitation.date!,
                    style: TextStyle(
                      fontSize: 11,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
            if (limitation.note != null) ...[
              const SizedBox(height: 8),
              Text(
                limitation.note!,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.45,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Shown for the handful of cards whose own rule text lets a deck run more
/// than four copies — the reason a deck can be fifty of the same card.
class _CopyLimitBanner extends StatelessWidget {
  const _CopyLimitBanner({required this.limit});

  final int limit;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: DigimonColors.green.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: DigimonColors.green.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.library_add_check_outlined,
              size: 16,
              color: DigimonColors.green,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'A deck may run up to $limit copies of this card.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  const _StatGrid({required this.card});

  final DigimonCard card;

  @override
  Widget build(BuildContext context) {
    final stats = <(String, String)>[
      if (card.level != null) ('Level', '${card.level}'),
      if (card.playCost != null) ('Play cost', '${card.playCost}'),
      if (card.useCost != null) ('Use cost', '${card.useCost}'),
      if (card.dp != null) ('DP', '${card.dp}'),
      if (card.form != null) ('Form', card.form!),
      if (card.attribute != null) ('Attribute', card.attribute!),
    ];
    if (stats.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppSurfaces.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppSurfaces.outline),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        // Measured against the box the stats actually sit in rather than
        // against the screen: a third of the screen width is not a third of
        // this container, so the columns never lined up.
        child: LayoutBuilder(
          builder: (context, constraints) => Wrap(
            children: [
              for (final (label, value) in stats)
                SizedBox(
                  width: constraints.maxWidth / 3,
                  child: _Stat(label: label, value: value),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.icon});

  final String title;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, size: 15, color: scheme.onSurfaceVariant),
                const SizedBox(width: 7),
              ],
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.7,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({required this.title, required this.text});

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: title,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppSurfaces.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppSurfaces.outline),
        ),
        child: GameText(text),
      ),
    );
  }
}

class _DigivolveSection extends StatelessWidget {
  const _DigivolveSection({required this.card});

  final DigimonCard card;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final requirements = card.digivolutionRequirements;
    final alternatives = requirements.where((r) => r.isAlternative).length;

    return _SectionCard(
      title: 'Digivolution requirements',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final requirement in requirements)
            _DigivolveRow(requirement: requirement),
          // The extra conditions are printed in the effect box rather than in
          // the cost box, and a player checking whether a digivolution is
          // legal needs to know which is which: the first row is the one on
          // the corner of the card, the rest are granted by its text.
          if (alternatives > 0)
            Padding(
              padding: const EdgeInsets.only(top: 2, left: 2),
              child: Text(
                alternatives == 1
                    ? 'The last condition is printed in the card’s effect '
                          'box, not in its cost box.'
                    : 'The last $alternatives conditions are printed in the '
                          'card’s effect box, not in its cost box.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DigivolveRow extends StatelessWidget {
  const _DigivolveRow({required this.requirement});

  final DigivolveRequirement requirement;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppSurfaces.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: requirement.isAlternative
              ? scheme.primary.withValues(alpha: 0.35)
              : AppSurfaces.outline,
        ),
      ),
      // Centred, so the colour dots sit on the text's midline whether the
      // condition takes one line or three.
      child: Row(
        children: [
          // Seven dots say no more than the words "any colour" already do,
          // and they crowd out the condition itself.
          if (requirement.colors.isNotEmpty && !requirement.isAnyColor) ...[
            ColorDots(colors: requirement.colors, size: 9),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Text(
              // A cost with no condition attached comes from the preview
              // source, which does not publish one. Saying so beats "Any",
              // which claimed the card digivolves from anything. When that
              // source did publish the colour, the dots to the left are
              // already showing it and only the level is missing.
              switch (requirement) {
                _ when !requirement.isConditionUnpublished =>
                  requirement.describe(),
                _ when requirement.colors.isNotEmpty =>
                  'Level not published yet',
                _ => 'Condition not published yet',
              },
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                fontStyle: requirement.isConditionUnpublished
                    ? FontStyle.italic
                    : FontStyle.normal,
                color: requirement.isConditionUnpublished
                    ? scheme.onSurfaceVariant
                    : null,
              ),
            ),
          ),
          if (requirement.cost != null) ...[
            const SizedBox(width: 10),
            Text(
              'Cost ${requirement.cost}',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ],
        ],
      ),
    );
  }
}

class _DualFaceSection extends StatelessWidget {
  const _DualFaceSection({required this.face});

  final CardFace face;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: 'Other face — ${face.category.label}',
      icon: Icons.flip_camera_android_outlined,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppSurfaces.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: DigimonColors.yellow.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    face.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (face.cost != null)
                  Text(
                    'Cost ${face.cost}',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
            if (face.effect != null) ...[
              const SizedBox(height: 10),
              GameText(face.effect!),
            ],
          ],
        ),
      ),
    );
  }
}

class _ErrataSection extends StatelessWidget {
  const _ErrataSection({required this.errata});

  final CardErrata errata;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: 'Errata${errata.date == null ? '' : ' · ${errata.date}'}',
      icon: Icons.edit_note,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppSurfaces.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppSurfaces.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errata.error != null) ...[
              Text(
                'Printed',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                errata.error!,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: scheme.onSurfaceVariant,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (errata.correction != null) ...[
              Text(
                'Should read',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              GameText(errata.correction!, fontSize: 13),
            ],
            if (errata.notes != null) ...[
              const SizedBox(height: 12),
              Text(
                errata.notes!,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReleasesSection extends ConsumerWidget {
  const _ReleasesSection({required this.card});

  final DigimonCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (card.releaseIds.isEmpty) return const SizedBox.shrink();
    final sections = ref.watch(releaseSectionsProvider).valueOrNull;

    String label(String id) {
      if (sections == null) return id;
      for (final section in sections) {
        for (final release in section.releases) {
          if (release.id == id) return release.name;
        }
      }
      return id;
    }

    return _SectionCard(
      title: 'Found in',
      icon: Icons.inventory_2_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final id in card.releaseIds)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(label(id), style: const TextStyle(fontSize: 13.5)),
            ),
        ],
      ),
    );
  }
}

class _FaqSection extends StatelessWidget {
  const _FaqSection({required this.faqs});

  final List<CardFaq> faqs;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: 'Rulings (${faqs.length})',
      icon: Icons.help_outline,
      child: Column(
        children: [
          for (final faq in faqs)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppSurfaces.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppSurfaces.outline),
              ),
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 14),
                  childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  // Without this the children column defaults to centred, so a
                  // short answer sat in the middle of the tile while a long one
                  // filled the width and looked left-aligned.
                  expandedAlignment: Alignment.centerLeft,
                  title: Text(
                    faq.question,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  children: [
                    Text(
                      faq.answer,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    if (faq.date != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        faq.date!,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Shown on a card from a set the main database has not published yet, so the
/// empty rulings and missing alternate arts read as "not published" rather
/// than "this card has none".
class _PreviewCardNotice extends StatelessWidget {
  const _PreviewCardNotice();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppSurfaces.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.science_outlined, size: 16, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Preview card from a set that is not in the main card database '
              'yet. Its text is community-sourced and may change, and it has '
              'no rulings or alternate arts here.',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.45,
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
