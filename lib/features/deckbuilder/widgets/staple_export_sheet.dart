import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models/deck_list.dart';
import '../../../domain/models/staple_list.dart';

/// Hands a staple list over as text, the way the deck export does.
///
/// A sheet rather than a screen: there is no picture to make and no options
/// beyond which punctuation the numbers take, so the whole thing fits over the
/// list it came from.
Future<void> showStapleExportSheet(BuildContext context, StapleList list) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.85,
      child: _StapleExportSheet(list: list),
    ),
  );
}

class _StapleExportSheet extends StatefulWidget {
  const _StapleExportSheet({required this.list});

  final StapleList list;

  @override
  State<_StapleExportSheet> createState() => _StapleExportSheetState();
}

class _StapleExportSheetState extends State<_StapleExportSheet> {
  DeckListFormat _format = DeckListFormat.standard;

  String get _text => writeStapleList(widget.list.cards, _format);

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: _text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${widget.list.name} copied.')));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final unresolved = widget.list.count - widget.list.cards.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
          child: Text(
            'Export ${widget.list.name}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Text(
            'One line per card, the same shape a deck list takes, so the '
            'result reads in this app and in the tools that take deck lists.',
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SegmentedButton<DeckListFormat>(
            segments: [
              for (final format in DeckListFormat.values)
                ButtonSegment(value: format, label: Text(format.label)),
            ],
            selected: {_format},
            showSelectedIcon: false,
            style: const ButtonStyle(
              visualDensity: VisualDensity.compact,
              textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 12)),
            ),
            onSelectionChanged: (selection) =>
                setState(() => _format = selection.first),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppSurfaces.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppSurfaces.outline),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _text.isEmpty ? 'This list has no cards in it yet.' : _text,
                style: const TextStyle(fontSize: 13, height: 1.5),
              ),
            ),
          ),
        ),
        if (unresolved > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Text(
              '$unresolved ${unresolved == 1 ? 'card is' : 'cards are'} in '
              'this list but not in your library yet, so they are not written '
              'out.',
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: widget.list.cards.isEmpty ? null : _copy,
                icon: const Icon(Icons.copy_all_outlined, size: 18),
                label: const Text('Copy to clipboard'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
