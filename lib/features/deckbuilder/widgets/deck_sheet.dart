import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/digimon_colors.dart';
import '../../../domain/models/card_enums.dart';
import '../../../domain/models/deck.dart';
import '../../../shared/widgets/card_thumbnail.dart';

/// How a deck image arranges its cards.
enum DeckSheetLayout {
  /// One block per section, the way the deck builder lists the deck: eggs,
  /// then Digimon a level at a time, then Tamers and Options.
  detailed(
    label: 'Detailed',
    description: 'Split into sections, 8 per row',
    columns: 8,
    grouped: true,
  ),

  /// Every card in one grid. Dropping the section headings and going seven to
  /// a row makes the picture wider than it is tall, which is the shape that
  /// fits a post or a chat window.
  compact(
    label: 'Compact',
    description: 'One grid, 7 per row',
    columns: 7,
    grouped: false,
  );

  const DeckSheetLayout({
    required this.label,
    required this.description,
    required this.columns,
    required this.grouped,
  });

  final String label;
  final String description;

  /// Cards per row.
  final int columns;

  /// Whether section headings are drawn between the blocks.
  final bool grouped;
}

/// The deck laid out as a single picture: every card in the deck at a size you
/// can actually read, with the copies of each stamped on it.
///
/// This renders at a fixed logical [width] rather than at the size of whatever
/// screen it is previewed on, because it is captured by a `RepaintBoundary`
/// and the capture is only as good as the layout underneath it. Callers scale
/// it to fit for the preview and capture it at its own size.
class DeckSheet extends StatelessWidget {
  const DeckSheet({
    super.key,
    required this.deckName,
    required this.revisionName,
    required this.composition,
    this.layout = DeckSheetLayout.detailed,
    this.width = 1400,
  });

  final String deckName;
  final String revisionName;
  final DeckComposition composition;

  final DeckSheetLayout layout;

  /// Logical width of the finished sheet.
  final double width;

  static const _padding = 40.0;
  static const _gap = 14.0;

  double get _cardWidth =>
      (width - _padding * 2 - _gap * (layout.columns - 1)) / layout.columns;

  /// Every card in the deck in reading order, section by section, without the
  /// section breaks. Used by the compact layout, which keeps the order the
  /// deck builder puts cards in but not the headings.
  List<DeckEntry> get _allInOrder => [
    for (final section in composition.sections) ...section.entries,
  ];

  @override
  Widget build(BuildContext context) {
    // The sheet is a fixed layout, so the viewer's font scale must not reach
    // it: a large system font would push text out of the boxes it sits in.
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
      child: Container(
        width: width,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppSurfaces.background, AppSurfaces.surface],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        padding: const EdgeInsets.all(_padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(),
            const SizedBox(height: 28),
            if (layout.grouped)
              for (final section in composition.sections) ...[
                _sectionLabel(section),
                const SizedBox(height: 12),
                _grid(section.entries),
                const SizedBox(height: 26),
              ]
            else
              _grid(_allInOrder),
          ],
        ),
      ),
    );
  }

  Widget _grid(List<DeckEntry> entries) => Wrap(
    spacing: _gap,
    runSpacing: _gap,
    children: [
      for (final entry in entries) _SheetCard(entry: entry, width: _cardWidth),
    ],
  );

  Widget _header() => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              deckName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 44,
                height: 1.1,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: Color(0xFFF2F1F6),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$revisionName · ${composition.mainDeckCount} main deck · '
              '${composition.eggDeckCount} egg deck',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Color(0xFF9E9DAB),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(width: 24),
      _ColorBar(spread: composition.colorSpread),
    ],
  );

  Widget _sectionLabel(DeckSection section) => Row(
    children: [
      Container(
        width: 5,
        height: 26,
        decoration: BoxDecoration(
          color: AppTheme.seed,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
      const SizedBox(width: 12),
      Text(
        section.label,
        style: const TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE6E5EA),
        ),
      ),
      const SizedBox(width: 12),
      Text(
        '${section.count}',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: Color(0xFF9E9DAB),
        ),
      ),
    ],
  );
}

/// One card on the sheet: the art, with its copy count stamped in the corner.
class _SheetCard extends StatelessWidget {
  const _SheetCard({required this.entry, required this.width});

  final DeckEntry entry;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: width / cardAspectRatio,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(width * 0.055),
              // A plain Image, not CachedNetworkImage: the exporter warms every
              // card into the image cache first, and this paints straight out
              // of it with no placeholder to catch mid-fade.
              child: Image(
                image: CachedNetworkImageProvider(entry.card.imageUrl),
                fit: BoxFit.cover,
                gaplessPlayback: true,
                errorBuilder: (context, _, _) => _MissingArt(entry: entry),
              ),
            ),
          ),
          // Top corner, not bottom: the copyright and artist credit are
          // printed along the bottom edge of every card, and the data sources
          // require that they not be covered or cropped.
          Positioned(
            right: width * 0.04,
            top: width * 0.04,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.1,
                vertical: width * 0.035,
              ),
              decoration: BoxDecoration(
                color: const Color(0xF20E0E12),
                borderRadius: BorderRadius.circular(width * 0.08),
                border: Border.all(color: AppTheme.seed, width: width * 0.014),
              ),
              child: Text(
                '×${entry.quantity}',
                style: TextStyle(
                  fontSize: width * 0.17,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFF2F1F6),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Stand-in for a card whose art could not be fetched, so the sheet still says
/// which card sits in that slot.
class _MissingArt extends StatelessWidget {
  const _MissingArt({required this.entry});

  final DeckEntry entry;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppSurfaces.surfaceHigh,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            '${entry.card.name}\n${entry.cardNumber}',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Color(0xFF9E9DAB)),
          ),
        ),
      ),
    );
  }
}

/// The deck's colour spread, drawn as the vertical bar that sits beside the
/// title — the same identity the deck list shows.
class _ColorBar extends StatelessWidget {
  const _ColorBar({required this.spread});

  final Map<CardColor, int> spread;

  @override
  Widget build(BuildContext context) {
    final ordered = CardColor.values
        .where((color) => (spread[color] ?? 0) > 0)
        .toList();
    if (ordered.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        width: 220,
        height: 14,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final color in ordered)
              Expanded(
                flex: spread[color]!,
                child: ColoredBox(color: DigimonColors.of(color)),
              ),
          ],
        ),
      ),
    );
  }
}
