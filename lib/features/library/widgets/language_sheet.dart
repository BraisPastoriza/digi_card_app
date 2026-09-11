import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/language.dart';
import '../../../l10n/l10n.dart';

/// Lets the reader pick the interface language, or hand it back to the device.
Future<void> showLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (context) => const _LanguageSheet(),
  );
}

class _LanguageSheet extends ConsumerWidget {
  const _LanguageSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final selected = ref.watch(languageProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: RadioGroup<Locale?>(
          groupValue: selected,
          onChanged: (locale) => _choose(context, ref, locale),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                child: Text(
                  context.l10n.languageTitle,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text(
                  context.l10n.languageSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              const Divider(height: 1),
              RadioListTile<Locale?>(
                value: null,
                title: Text(context.l10n.languageSystem),
                // Says what following the device works out to right now, so the
                // option is not a guess.
                subtitle: Text(
                  context.l10n.languageSystemDetail(
                    languageName(Localizations.localeOf(context)),
                  ),
                ),
              ),
              for (final locale in AppLocalizations.supportedLocales)
                RadioListTile<Locale?>(
                  value: locale,
                  title: Text(languageName(locale)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _choose(BuildContext context, WidgetRef ref, Locale? locale) {
    ref.read(languageProvider.notifier).select(locale);
    Navigator.of(context).pop();
  }
}
