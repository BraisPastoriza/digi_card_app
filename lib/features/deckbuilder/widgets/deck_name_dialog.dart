import 'package:flutter/material.dart';

import '../../../l10n/l10n.dart';

/// Prompts for a deck or revision name. Returns null if cancelled.
Future<String?> showDeckNameDialog(
  BuildContext context, {
  required String title,
  String initialValue = '',
  String? label,
  String? confirmLabel,
  String? helperText,
}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _DeckNameDialog(
      title: title,
      initialValue: initialValue,
      label: label ?? context.l10n.dialogNameLabel,
      confirmLabel: confirmLabel ?? context.l10n.actionSave,
      helperText: helperText,
    ),
  );
}

class _DeckNameDialog extends StatefulWidget {
  const _DeckNameDialog({
    required this.title,
    required this.initialValue,
    required this.label,
    required this.confirmLabel,
    this.helperText,
  });

  final String title;
  final String initialValue;
  final String label;
  final String confirmLabel;
  final String? helperText;

  @override
  State<_DeckNameDialog> createState() => _DeckNameDialogState();
}

class _DeckNameDialogState extends State<_DeckNameDialog> {
  late final _controller = TextEditingController(text: widget.initialValue);

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final value = _controller.text.trim();
    if (value.isEmpty) return;
    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          labelText: widget.label,
          helperText: widget.helperText,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.actionCancel),
        ),
        FilledButton(
          onPressed: _controller.text.trim().isEmpty ? null : _submit,
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}
