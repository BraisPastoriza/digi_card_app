import 'package:flutter/material.dart';

class MultiSelectOption {
  const MultiSelectOption({
    required this.value,
    required this.label,
    this.detail,
  });

  final String value;
  final String label;

  /// Secondary text, e.g. a set code next to an expansion name.
  final String? detail;
}

/// Full-screen searchable picker for facets with too many values to show as
/// chips — traits (286) and expansions (93).
///
/// Returns the new selection, or null if the user backed out.
Future<Set<String>?> showMultiSelect(
  BuildContext context, {
  required String title,
  required List<MultiSelectOption> options,
  required Set<String> selected,
}) {
  return Navigator.of(context).push<Set<String>>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (context) =>
          _MultiSelectPage(title: title, options: options, initial: selected),
    ),
  );
}

class _MultiSelectPage extends StatefulWidget {
  const _MultiSelectPage({
    required this.title,
    required this.options,
    required this.initial,
  });

  final String title;
  final List<MultiSelectOption> options;
  final Set<String> initial;

  @override
  State<_MultiSelectPage> createState() => _MultiSelectPageState();
}

class _MultiSelectPageState extends State<_MultiSelectPage> {
  late final Set<String> _selected = Set.of(widget.initial);
  String _query = '';

  List<MultiSelectOption> get _visible {
    if (_query.isEmpty) return widget.options;
    final needle = _query.toLowerCase();
    return widget.options
        .where(
          (option) =>
              option.label.toLowerCase().contains(needle) ||
              (option.detail?.toLowerCase().contains(needle) ?? false),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final visible = _visible;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_selected.isNotEmpty)
            TextButton(
              onPressed: () => setState(_selected.clear),
              child: const Text('Clear'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(_selected),
            child: const Text('Done'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: TextField(
              autofocus: false,
              onChanged: (value) => setState(() => _query = value),
              decoration: InputDecoration(
                hintText: 'Search ${widget.title.toLowerCase()}',
                prefixIcon: const Icon(Icons.search, size: 20),
              ),
            ),
          ),
          if (_selected.isNotEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                '${_selected.length} selected',
                style: TextStyle(fontSize: 13, color: scheme.primary),
              ),
            ),
          const Divider(),
          Expanded(
            child: visible.isEmpty
                ? Center(
                    child: Text(
                      'Nothing matches "$_query"',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                  )
                : ListView.builder(
                    itemCount: visible.length,
                    itemBuilder: (context, index) {
                      final option = visible[index];
                      final checked = _selected.contains(option.value);
                      return CheckboxListTile(
                        value: checked,
                        onChanged: (_) => setState(() {
                          if (!_selected.remove(option.value)) {
                            _selected.add(option.value);
                          }
                        }),
                        dense: true,
                        title: Text(option.label),
                        subtitle: option.detail == null
                            ? null
                            : Text(option.detail!),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
