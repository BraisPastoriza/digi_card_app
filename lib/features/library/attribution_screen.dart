import 'package:flutter/material.dart';

import '../../core/router/navigation.dart';
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
        title: const Text('Data & credits'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: const [
          _Section(
            title: 'Card artwork and card text',
            body:
                'All card images, card text and related imagery are the '
                'intellectual property of © Akiyoshi Hongo, Toei Animation and '
                '© BANDAI. Their copyrights, trademarks and related rights '
                'apply.\n\n'
                'DigiCard App is a fan-made tool. It is not affiliated with, '
                'endorsed by, or connected to Bandai Namco Entertainment or '
                'Toei Animation.',
          ),
          _Section(
            title: 'Card data — Heroicc',
            body:
                'The card database, expansion list and rulings come from the '
                'Heroicc API.\n\n'
                'DigiCard App is not affiliated with, endorsed by, or '
                'connected to Heroicc. Original content provided by Heroicc — '
                'that is, the parts not owned by Akiyoshi Hongo, Toei '
                'Animation or BANDAI — is used under the Creative Commons '
                'Attribution-NonCommercial-ShareAlike 4.0 International '
                'licence (CC BY-NC-SA 4.0).',
            link: 'https://api.heroi.cc',
          ),
          _Section(
            title: 'Preview sets — $secondarySourceName',
            body:
                'A set the Heroicc API has not published yet is filled in from '
                'the digimoncard.io public API so its cards can be searched '
                'and built with early. Those sets are marked PREVIEW wherever '
                'they appear.\n\n'
                'DigiCard App is not affiliated with, endorsed by, or '
                'connected to digimoncard.io. Preview data is '
                'community-maintained and still changing: expect gaps and '
                'corrections, and check anything that matters against the '
                'printed card.',
            link: 'https://digimoncard.io',
          ),
          _Section(
            title: 'How this app treats card images',
            body:
                'Card images are shown and exported whole. The app does not '
                'crop or cover the copyright line or the artist name, and adds '
                'no watermark, stamp or logo of its own to a card image.',
          ),
          _Section(
            title: 'Caching',
            body:
                'The full card list is downloaded once and kept on your '
                'device, so browsing and deck building make no further '
                'requests. Both APIs ask callers to cache rather than re-fetch, '
                'and to identify themselves; this app sends its own '
                'User-Agent on every request.',
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
            'Card images and text © Akiyoshi Hongo, Toei Animation, © BANDAI. '
            'Card data from Heroicc and $secondarySourceName. '
            'DigiCard App is a fan project, not affiliated with any of them.',
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
