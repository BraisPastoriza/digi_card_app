import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gal/gal.dart';

import '../../core/router/navigation.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/deck.dart';
import '../../domain/models/deck_list.dart';
import '../../l10n/l10n.dart';
import '../../l10n/labels.dart';
import '../../shared/widgets/common.dart';
import 'deck_providers.dart';
import 'widgets/deck_sheet.dart';

/// Exports a revision, as a picture of the deck or as a text list.
///
/// Both exist because they are used for different things: the image is what
/// gets posted and shown to people, the text is what other deck tools read.
class DeckExportScreen extends ConsumerWidget {
  const DeckExportScreen({
    super.key,
    required this.deckId,
    required this.revisionId,
  });

  final int deckId;
  final int revisionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final deck = ref.watch(deckProvider(deckId)).valueOrNull;
    final composition = ref.watch(compositionProvider(revisionId));
    final revision = deck?.revisions.firstWhereOrNull(
      (r) => r.id == revisionId,
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => context.goBack('/decks/$deckId'),
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(context.l10n.exportTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: context.l10n.exportTabImage),
              Tab(text: context.l10n.exportTabText),
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
            if (composition.allEntries.isEmpty) {
              return EmptyState(
                icon: Icons.add_card,
                title: context.l10n.exportNothingTitle,
                message: context.l10n.exportNothingMessage,
              );
            }
            return TabBarView(
              children: [
                _ImageExportTab(
                  deckName: deck?.name ?? context.l10n.exportFallbackDeckName,
                  revisionName: revision?.name ?? '',
                  composition: composition,
                ),
                _TextExportTab(composition: composition),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Renders the deck as a picture and hands it to the gallery.
class _ImageExportTab extends StatefulWidget {
  const _ImageExportTab({
    required this.deckName,
    required this.revisionName,
    required this.composition,
  });

  final String deckName;
  final String revisionName;
  final DeckComposition composition;

  @override
  State<_ImageExportTab> createState() => _ImageExportTabState();
}

class _ImageExportTabState extends State<_ImageExportTab> {
  final _sheetKey = GlobalKey();

  DeckSheetLayout _layout = DeckSheetLayout.detailed;

  /// Resolves once every card's art is in the image cache. The sheet is only
  /// built after this: a card still loading would be captured as a blank.
  Future<void>? _artwork;

  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _artwork ??= _warmArtwork();
  }

  Future<void> _warmArtwork() async {
    await Future.wait([
      for (final entry in widget.composition.allEntries)
        // One card that will not load must not stop the export; the sheet
        // draws a labelled placeholder in its place.
        precacheImage(
          CachedNetworkImageProvider(entry.card.imageUrl),
          context,
        ).catchError((_) {}),
    ]);
  }

  /// Longest side of the saved image.
  ///
  /// Capturing above the GPU's maximum texture size comes back blank on a lot
  /// of devices, and 4000px is comfortably under the 4096 that the weakest of
  /// them allow while still being sharper than any screen it will be viewed on.
  static const _maxPixels = 4000.0;

  Future<Uint8List?> _capture() async {
    final boundary =
        _sheetKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    // The boundary captures at its own logical size whatever the preview is
    // scaled to, so the result does not depend on the screen it was made on.
    final size = boundary.size;
    final ratio = math.min(
      3.0,
      math.min(_maxPixels / size.width, _maxPixels / size.height),
    );
    final image = await boundary.toImage(pixelRatio: math.max(1, ratio));
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  }

  Future<void> _saveToGallery() async {
    // Read before the first await: the strings are needed after it, and by
    // then the context may no longer be worth asking.
    final l10n = context.l10n;
    setState(() => _saving = true);
    try {
      final bytes = await _capture();
      if (bytes == null) {
        _report(l10n.exportRenderFailed);
        return;
      }
      if (!await Gal.requestAccess()) {
        _report(l10n.exportNeedsPermission);
        return;
      }
      await Gal.putImageBytes(bytes, name: _fileName());
      _report(l10n.exportSaved);
    } on GalException catch (error) {
      _report(error.type.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _fileName() {
    final parts = [
      widget.deckName,
      widget.revisionName,
      if (_layout == DeckSheetLayout.compact) _layout.label,
    ].where((part) => part.isNotEmpty).join('-');
    final safe = parts.replaceAll(RegExp(r'[^A-Za-z0-9._-]+'), '-');
    return safe.isEmpty ? 'digimon-deck' : safe;
  }

  void _report(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FutureBuilder<void>(
      future: _artwork,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(context.l10n.exportLoadingArt),
              ],
            ),
          );
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: SizedBox(
                width: double.infinity,
                child: SegmentedButton<DeckSheetLayout>(
                  segments: [
                    for (final layout in DeckSheetLayout.values)
                      ButtonSegment(
                        value: layout,
                        label: Text(layout.name(context.l10n)),
                      ),
                  ],
                  selected: {_layout},
                  showSelectedIcon: false,
                  onSelectionChanged: (selection) =>
                      setState(() => _layout = selection.first),
                ),
              ),
            ),
            Expanded(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: FittedBox(
                      child: RepaintBoundary(
                        key: _sheetKey,
                        child: DeckSheet(
                          deckName: widget.deckName,
                          revisionName: widget.revisionName,
                          composition: widget.composition,
                          layout: _layout,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Column(
                  children: [
                    Text(
                      context.l10n.exportLayoutHint(
                        _layout.summary(context.l10n),
                      ),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: _saving ? null : _saveToGallery,
                        icon: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.download, size: 18),
                        label: Text(
                          _saving
                              ? context.l10n.exportSaving
                              : context.l10n.exportSaveToGallery,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Writes the deck out as text, in either of the two formats, ready to copy.
class _TextExportTab extends StatefulWidget {
  const _TextExportTab({required this.composition});

  final DeckComposition composition;

  @override
  State<_TextExportTab> createState() => _TextExportTabState();
}

class _TextExportTabState extends State<_TextExportTab> {
  DeckListFormat _format = DeckListFormat.standard;

  Future<void> _copy(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.exportListCopied(_format.name(context.l10n)),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = writeDeckList(widget.composition, _format);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: SizedBox(
            width: double.infinity,
            child: SegmentedButton<DeckListFormat>(
              segments: [
                for (final format in DeckListFormat.values)
                  ButtonSegment(
                    value: format,
                    label: Text(format.name(context.l10n)),
                  ),
              ],
              selected: {_format},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _format = selection.first),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
          child: Text(
            _format.example,
            style: TextStyle(
              fontSize: 12.5,
              fontFamily: 'monospace',
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppSurfaces.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppSurfaces.outline),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                text,
                style: const TextStyle(
                  fontSize: 13.5,
                  height: 1.55,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _copy(text),
                icon: const Icon(Icons.copy_all, size: 18),
                label: Text(context.l10n.exportCopyToClipboard),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
