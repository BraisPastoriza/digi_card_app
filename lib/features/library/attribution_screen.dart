import 'package:flutter/material.dart';

import '../../core/router/navigation.dart';
import '../../l10n/l10n.dart';
import '../../domain/models/card_release.dart';
import '../../shared/widgets/common.dart';

/// Who the card data and the card images belong to, and under what terms this
/// app uses them.
///
/// This is not decoration. Both APIs the app reads ask for specific
/// acknowledgements, and the artwork belongs to neither of them.
class AttributionScreen extends StatelessWidget {
  const AttributionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.goBack('/library'),
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(context.l10n.creditsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          _Section(
            title: context.l10n.creditsArtworkTitle,
            body: context.l10n.creditsArtworkBody,
          ),
          _Section(
            title: context.l10n.creditsHeroiTitle,
            body: context.l10n.creditsHeroiBody,
            link: 'https://api.heroi.cc',
          ),
          _Section(
            title: context.l10n.creditsPreviewTitle(secondarySourceName),
            body: context.l10n.creditsPreviewBody,
            link: 'https://digimoncard.io',
          ),
          _Section(
            title: context.l10n.creditsImagesTitle,
            body: context.l10n.creditsImagesBody,
          ),
          _Section(
            title: context.l10n.creditsCachingTitle,
            body: context.l10n.creditsCachingBody,
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.body, this.link});

  final String title;
  final String body;

  /// Shown as plain text rather than a tappable link: the app opens no
  /// external browser anywhere else, and a dead-looking link is worse than a
  /// readable address.
  final String? link;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.55,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                if (link != null) ...[
                  const SizedBox(height: 10),
                  SelectableText(
                    link!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Short credit line for the bottom of a screen that shows card data.
class AttributionFooter extends StatelessWidget {
  const AttributionFooter({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            context.l10n.creditsFooter(secondarySourceName),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              height: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
