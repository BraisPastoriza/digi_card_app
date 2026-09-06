import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router/navigation.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/deck.dart';
import '../../domain/models/deck_list.dart';
import 'deck_providers.dart';

/// Builds a deck out of a pasted text list — the reverse of the text export.
///
/// The list can land either as a deck of its own or as a new revision of a
/// deck the user already has, which is what makes it useful for trying
/// somebody else's build against your own without overwriting it.
class DeckImportScreen extends ConsumerStatefulWidget {
  const DeckImportScreen({super.key});

  @override
  ConsumerState<DeckImportScreen> createState() => _DeckImportScreenState();
}

/// Where an imported list is written.
enum _Destination { newDeck, newRevision }

class _DeckImportScreenState extends ConsumerState<DeckImportScreen> {
  final _listController = TextEditingController();
  final _nameController = TextEditingController();

  List<DeckListMatch>? _matches;
  bool _reading = false;
  bool _importing = false;

  _Destination _destination = _Destination.newDeck;
  int? _targetDeckId;

  @override
  void dispose() {
    _listController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  List<DeckListMatch> get _resolved =>
      _matches?.where((m) => m.isResolved).toList() ?? const [];

  List<DeckListMatch> get _unresolved =>
      _matches?.where((m) => !m.isResolved).toList() ?? const [];

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text;
    if (text == null || text.trim().isEmpty) {
      _report('The clipboard has no text in it.');
      return;
    }
    setState(() {
      _listController.text = text;
      _matches = null;
    });
  }

  /// Parses the pasted text and matches every line against the library.
  Future<void> _read() async {
    setState(() => _reading = true);
    final lines = readDeckList(_listController.text);
    final dao = ref.read(cardDaoProvider);

    // Numbers are printed upper case; a list typed by hand may not be.
    final byNumber = await dao.cardsByNumbers(
      lines.map((l) => l.cardNumber?.toUpperCase()).whereType<String>(),
    );
    // Names are only needed for the lines that gave no number.
    final byName = await dao.cardsByNames(
      lines
          .where((l) => l.cardNumber == null)
          .map((l) => l.name)
          .whereType<String>(),
    );

    if (!mounted) return;
    setState(() {
      // A pasted list can name a token; it is reported as unmatched rather
      // than silently written into a deck that could not legally hold it.
      _matches = [
        for (final match in matchDeckList(
          lines,
          byNumber: byNumber,
          byName: byName,
        ))
          match.card?.isToken ?? false
              ? DeckListMatch(line: match.line)
              : match,
      ];
      _reading = false;
      if (_nameController.text.trim().isEmpty) {
        _nameController.text = 'Imported deck';
      }
    });
  }

  Future<void> _import() async {
    final quantities = quantitiesOf(_resolved);
    if (quantities.isEmpty) return;

    setState(() => _importing = true);
    final dao = ref.read(deckDaoProvider);
    final name = _nameController.text.trim();

    if (_destination == _Destination.newDeck) {
      final deckId = await dao.createDeckFromList(
        name: name.isEmpty ? null : name,
        revisionName: 'v1',
        quantities: quantities,
      );
      if (!mounted) return;
      context.pushReplacement('/decks/$deckId');
      return;
    }

    final deckId = _targetDeckId;
    if (deckId == null) {
      setState(() => _importing = false);
      return;
    }
    await dao.createRevisionFromList(
      deckId: deckId,
      name: name.isEmpty ? 'Imported' : name,
      quantities: quantities,
    );
    if (!mounted) return;
    context.pushReplacement('/decks/$deckId');
  }

  void _report(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final decks = ref.watch(decksProvider).valueOrNull ?? const <Deck>[];
    final matches = _matches;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.goBack('/decks'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Import deck list'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          Text(
            'Paste a deck list in either format — "4 Agumon BT1-010" or '
            '"4 Agumon (BT1-010)". Headings and comments between the lines '
            'are ignored.',
            style: TextStyle(
              fontSize: 13,
              height: 1.45,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _listController,
            minLines: 6,
            maxLines: 12,
            style: const TextStyle(fontSize: 13.5, fontFamily: 'monospace'),
            decoration: const InputDecoration(
              hintText: '4 Agumon BT1-010\n3 Koromon BT1-002\n…',
              alignLabelWithHint: true,
            ),
            // Rebuild on every keystroke: the Read button turns on with the
            // first character, and a changed list invalidates what was read.
            onChanged: (_) => setState(() => _matches = null),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _paste,
                  icon: const Icon(Icons.content_paste, size: 18),
                  label: const Text('Paste'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _reading || _listController.text.trim().isEmpty
                      ? null
                      : _read,
                  icon: const Icon(Icons.playlist_add_check, size: 18),
                  label: Text(_reading ? 'Reading…' : 'Read list'),
                ),
              ),
            ],
          ),
          if (matches != null) ...[
            const SizedBox(height: 20),
            _Summary(resolved: _resolved, unresolved: _unresolved),
            if (_resolved.isNotEmpty) ...[
              const SizedBox(height: 20),
              _destinationPicker(decks),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                      _importing ||
                          (_destination == _Destination.newRevision &&
                              _targetDeckId == null)
                      ? null
                      : _import,
                  icon: const Icon(Icons.download_done, size: 18),
                  label: Text(_importing ? 'Importing…' : 'Import'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _destinationPicker(List<Deck> decks) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: double.infinity,
        child: SegmentedButton<_Destination>(
          segments: const [
            ButtonSegment(value: _Destination.newDeck, label: Text('New deck')),
            ButtonSegment(
              value: _Destination.newRevision,
              label: Text('New revision'),
            ),
          ],
          selected: {_destination},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              setState(() => _destination = selection.first),
        ),
      ),
      const SizedBox(height: 14),
      if (_destination == _Destination.newRevision) ...[
        if (decks.isEmpty)
          const Text('You have no decks to add a revision to yet.')
        else
          DropdownButtonFormField<int>(
            initialValue: _targetDeckId,
            isExpanded: true,
            decoration: const InputDecoration(labelText: 'Deck'),
            items: [
              for (final deck in decks)
                DropdownMenuItem(
                  value: deck.id,
                  child: Text(deck.name, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: (value) => setState(() => _targetDeckId = value),
          ),
        const SizedBox(height: 12),
      ],
      TextField(
        controller: _nameController,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: _destination == _Destination.newDeck
              ? 'Deck name'
              : 'Revision name',
        ),
      ),
    ],
  );
}

/// What the list turned into: how many cards were found, and which lines the
/// library did not recognise.
class _Summary extends StatelessWidget {
  const _Summary({required this.resolved, required this.unresolved});

  final List<DeckListMatch> resolved;
  final List<DeckListMatch> unresolved;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final copies = resolved.fold(0, (sum, m) => sum + m.line.quantity);

    return Container(
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
          Row(
            children: [
              Icon(
                resolved.isEmpty ? Icons.error_outline : Icons.check_circle,
                size: 18,
                color: resolved.isEmpty ? scheme.error : scheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  resolved.isEmpty
                      ? 'No cards recognised in that list.'
                      : '${resolved.length} cards · $copies copies',
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (unresolved.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '${unresolved.length} ${unresolved.length == 1 ? 'line' : 'lines'} '
              'could not be matched and will be left out:',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            for (final match in unresolved.take(12))
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  match.line.raw,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontFamily: 'monospace',
                    color: scheme.error,
                  ),
                ),
              ),
            if (unresolved.length > 12)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '…and ${unresolved.length - 12} more',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
