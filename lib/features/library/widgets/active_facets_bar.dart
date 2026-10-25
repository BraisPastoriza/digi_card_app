import 'package:flutter/material.dart';

import '../../../domain/models/card_filter.dart';
import '../../../l10n/l10n.dart';
import '../facets.dart';

/// The facets [filter] has on, one chip each, with a chip to clear them all.
/// Takes no room when nothing is on.
class ActiveFacetsBar extends StatelessWidget {
  const ActiveFacetsBar({
    super.key,
    required this.filter,
    required this.onRemoveFacet,
    required this.onClearFacets,
  });

  final CardFilter filter;

  /// Takes one facet off, given the filter left without it.
  final void Function(CardFilter) onRemoveFacet;

  final VoidCallback onClearFacets;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final facets = activeFacets(filter, context.l10n);
    if (facets.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        children: [
          // Tapping a chip — anywhere on it, not only the cross — takes that
          // facet off, which is where the hand goes when a search turns out
          // too narrow.
          for (final facet in facets)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InputChip(
                label: Text(facet.label),
                visualDensity: VisualDensity.compact,
                labelStyle: TextStyle(
                  fontSize: 12,
                  color: scheme.primary,
                  fontWeight: FontWeight.w600,
                ),
                backgroundColor: scheme.primaryContainer,
                side: BorderSide(color: scheme.primary.withValues(alpha: 0.4)),
                onPressed: () => onRemoveFacet(facet.removed),
                onDeleted: () => onRemoveFacet(facet.removed),
                deleteIcon: Icon(Icons.close, size: 14, color: scheme.primary),
                tooltip: context.l10n.searchRemoveFacet(facet.label),
              ),
            ),
          ActionChip(
            label: Text(context.l10n.searchClearAll),
            visualDensity: VisualDensity.compact,
            labelStyle: const TextStyle(fontSize: 12),
            avatar: const Icon(Icons.close, size: 14),
            onPressed: onClearFacets,
          ),
        ],
      ),
    );
  }
}
