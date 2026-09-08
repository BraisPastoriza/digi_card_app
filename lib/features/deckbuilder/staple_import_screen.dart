import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers.dart';
import '../../core/router/navigation.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/deck_list.dart';
import '../../domain/models/staple_list.dart';
import 'staple_providers.dart';

/// Builds a staple list out of a pasted text list — the reverse of the export.
///
/// It reads the same text a deck list is written in, because that is what
/// people have to hand: the copies on each line are ignored, since a list
/// holds a card once however many the deck it came from ran. That also makes
/// this the quick way to turn somebody else's deck list into a catalogue of
/// the cards in it.
class StapleImportScreen extends ConsumerStatefulWidget {
  const StapleImportScreen({super.key});

  @override
  ConsumerState<StapleImportScreen> createState() => _StapleImportScreenState();
}

/// Where an imported list is written.
enum _Destination { newList, existingList }

class _StapleImportScreenState extends ConsumerState<StapleImportScreen> {
  final _listController = TextEditingController();
  final _nameController = TextEditingController();

  List<DeckListMatch>? _matches;
  bool _reading = false;
  bool _importing = false;

  _Destination _destination = _Destination.newList;
  int? _targetListId;

  @override
  void dispose() {
    _listController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  /// One entry per card, in the order the list first names it: a staple list
  /// is a set, so a card named twice is one card.
  List<DeckListMatch> get _resolved {
    final seen = <String>{};
    return [
      for (final match in _matches ?? const <DeckListMatch>[])
        if (match.isResolved && seen.add(match.card!.number)) match,
    ];
  }

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

  Future<void> _read() async {
    setState(() => _reading = true);
    final lines = readDeckList(_listController.text);
    final dao = ref.read(cardDaoProvider);

    final byNumber = await dao.cardsByNumbers(
      lines.map((l) => l.cardNumber?.toUpperCase()).whereType<String>(),
    );
    final byName = await dao.cardsByNames(
      lines
          .where((l) => l.cardNumber == null)
          .map((l) => l.name)
          .whereType<String>(),
    );

    if (!mounted) return;
    setState(() {
      _matches = matchDeckList(lines, byNumber: byNumber, byName: byName);
      _reading = false;
    });
  }

  Future<void> _import() async {
    final cards = _resolved.map((m) => m.card!.number).toList();
    if (cards.isEmpty) return;

    setState(() => _importing = true);
    final dao = ref.read(stapleDaoProvider);
    final int listId;
    if (_destination == _Destination.newList) {
      final name = _nameController.text.trim();
      listId = await dao.createList(name: name.isEmpty ? null : name);
    } else {
      listId = _targetListId!;
    }
    await dao.addCards(listId, cards);

    if (!mounted) return;
    setState(() => _importing = false);
    context.pushReplacement('/decks/staples/$listId');
  }

  void _report(String message) {
    ScaffoldMessenger.of(context)
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lists = ref.watch(stapleListsProvider).valueOrNull ?? const [];
    final matches = _matches;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.goBack('/decks'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Import a staple list'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            'Paste a list of cards — the export from this app, or any deck '
            'list. Copies are ignored: a staple list holds each card once.',
            style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _listController,
            maxLines: 8,
            minLines: 5,
            onChanged: (_) => setState(() => _matches = null),
            decoration: InputDecoration(
              hintText: '1 Gravity Crush BT1-090\n1 Jack Raid BT4-111',
              alignLabelWithHint: true,
              suffixIcon: IconButton(
                tooltip: 'Paste',
                onPressed: _paste,
                icon: const Icon(Icons.content_paste, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: _listController.text.trim().isEmpty || _reading
                ? null
                : _read,
            child: Text(_reading ? 'Reading…' : 'Read the list'),
          ),
          if (matches != null) ...[
            const SizedBox(height: 20),
            _Summary(resolved: _resolved.length, unresolved: _unresolved),
            const SizedBox(height: 16),
            Text(
              'Where it goes',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SegmentedButton<_Destination>(
              segments: const [
                ButtonSegment(
                  value: _Destination.newList,
                  label: Text('New list'),
                ),
                ButtonSegment(
                  value: _Destination.existingList,
                  label: Text('Add to a list'),
                ),
              ],
              selected: {_destination},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _destination = selection.first),
            ),
            const SizedBox(height: 12),
            if (_destination == _Destination.newList)
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'List name',
                  hintText: 'Blue tech',
                ),
              )
            else if (lists.isEmpty)
              Text(
                'You have no lists to add to yet.',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              )
            else
              DropdownButtonFormField<int>(
                initialValue: _targetListId ?? lists.first.id,
                decoration: const InputDecoration(labelText: 'List'),
                items: [
                  for (final list in lists)
                    DropdownMenuItem(
                      value: list.id,
                      child: Text(
                        '${list.name} · ${list.count}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (value) => setState(() => _targetListId = value),
              ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _canImport(lists) ? _import : null,
              child: Text(_importing ? 'Importing…' : _importLabel()),
            ),
          ],
        ],
      ),
    );
  }

  bool _canImport(List<StapleList> lists) {
    if (_importing || _resolved.isEmpty) return false;
    if (_destination == _Destination.newList) return true;
    return lists.isNotEmpty;
  }

  String _importLabel() {
    final count = _resolved.length;
    return count == 1 ? 'Import 1 card' : 'Import $count cards';
  }
}

/// What the list resolved to, and what it did not.
class _Summary extends StatelessWidget {
  const _Summary({required this.resolved, required this.unresolved});

  final int resolved;
  final List<DeckListMatch> unresolved;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
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
          Text(
            resolved == 1 ? '1 card found' : '$resolved cards found',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          if (unresolved.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              unresolved.length == 1
                  ? '1 line matched no card and is left out:'
                  : '${unresolved.length} lines matched no card and are left '
                        'out:',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 6),
            for (final match in unresolved.take(6))
              Text(
                match.line.raw,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12.5, color: scheme.error),
              ),
            if (unresolved.length > 6)
              Text(
                'and ${unresolved.length - 6} more',
                style: TextStyle(
                  fontSize: 12.5,
                  color: scheme.onSurfaceVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
