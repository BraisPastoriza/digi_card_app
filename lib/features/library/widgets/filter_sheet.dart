import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/digimon_colors.dart';
import '../../../domain/models/card_enums.dart';
import '../../../domain/models/card_filter.dart';
import '../library_providers.dart';
import 'multi_select_page.dart';

/// Real bounds of the numeric fields, taken from the published card data.
/// Sliders use these so their whole travel is useful.
abstract final class FilterBounds {
  static const maxCost = 20;
  static const maxDigivolveCost = 9;
  static const maxDp = 17000;
  static const dpStep = 1000;
  static const levels = [2, 3, 4, 5, 6, 7];
}

/// Opens the filter sheet and returns the filter the user applied, or null if
/// they dismissed it.
Future<CardFilter?> showFilterSheet(
  BuildContext context,
  CardFilter current,
) {
  return showModalBottomSheet<CardFilter>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => FractionallySizedBox(
      heightFactor: 0.92,
      child: FilterSheet(initial: current),
    ),
  );
}

class FilterSheet extends ConsumerStatefulWidget {
  const FilterSheet({super.key, required this.initial});

  final CardFilter initial;

  @override
  ConsumerState<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends ConsumerState<FilterSheet> {
  late CardFilter _draft = widget.initial;

  void _edit(CardFilter Function(CardFilter) change) =>
      setState(() => _draft = change(_draft));

  /// Adds or removes [value] from a set-valued facet.
  Set<T> _toggled<T>(Set<T> values, T value) {
    final next = Set<T>.of(values);
    if (!next.remove(value)) next.add(value);
    return next;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 12, 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Filters',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
              ),
              TextButton(
                onPressed: _draft.activeFacetCount == 0
                    ? null
                    : () => _edit((f) => f.clearedFacets()),
                child: const Text('Reset'),
              ),
            ],
          ),
        ),
        const Divider(),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _Section(
                title: 'Color',
                trailing: SegmentedButton<ColorMatchMode>(
                  segments: [
                    for (final mode in ColorMatchMode.values)
                      ButtonSegment(value: mode, label: Text(mode.label)),
                  ],
                  selected: {_draft.colorMatchMode},
                  showSelectedIcon: false,
                  style: const ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11)),
                  ),
                  onSelectionChanged: (selection) =>
                      _edit((f) => f.copyWith(colorMatchMode: selection.first)),
                ),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final color in CardColor.values)
                      _ColorChip(
                        color: color,
                        selected: _draft.colors.contains(color),
                        onTap: () => _edit(
                          (f) =>
                              f.copyWith(colors: _toggled(f.colors, color)),
                        ),
                      ),
                  ],
                ),
              ),
              _Section(
                title: 'Card type',
                child: _ChipWrap(
                  options: CardCategory.values,
                  labelOf: (category) => category.label,
                  selected: _draft.categories,
                  onToggle: (category) => _edit(
                    (f) => f.copyWith(
                      categories: _toggled(f.categories, category),
                    ),
                  ),
                ),
              ),
              _Section(
                title: 'Level',
                child: _ChipWrap(
                  options: FilterBounds.levels,
                  labelOf: (level) => 'Lv.$level',
                  selected: _draft.levels,
                  onToggle: (level) => _edit(
                    (f) => f.copyWith(levels: _toggled(f.levels, level)),
                  ),
                ),
              ),
              _RangeSection(
                title: 'Play / use cost',
                range: _draft.playCost,
                max: FilterBounds.maxCost,
                onChanged: (range) => _edit((f) => f.copyWith(playCost: range)),
              ),
              _RangeSection(
                title: 'Digivolution cost',
                range: _draft.digivolveCost,
                max: FilterBounds.maxDigivolveCost,
                onChanged: (range) =>
                    _edit((f) => f.copyWith(digivolveCost: range)),
              ),
              _RangeSection(
                title: 'DP',
                range: _draft.dp,
                max: FilterBounds.maxDp,
                step: FilterBounds.dpStep,
                onChanged: (range) => _edit((f) => f.copyWith(dp: range)),
              ),
              _AsyncChipSection(
                title: 'Keyword',
                options: ref.watch(keywordOptionsProvider),
                selected: _draft.keywords,
                onToggle: (keyword) => _edit(
                  (f) => f.copyWith(keywords: _toggled(f.keywords, keyword)),
                ),
              ),
              _AsyncChipSection(
                title: 'Rarity',
                options: ref.watch(rarityOptionsProvider),
                selected: _draft.rarities,
                onToggle: (rarity) => _edit(
                  (f) => f.copyWith(rarities: _toggled(f.rarities, rarity)),
                ),
              ),
              _AsyncChipSection(
                title: 'Attribute',
                options: ref.watch(attributeOptionsProvider),
                selected: _draft.attributes,
                onToggle: (attribute) => _edit(
                  (f) => f.copyWith(
                    attributes: _toggled(f.attributes, attribute),
                  ),
                ),
              ),
              _AsyncChipSection(
                title: 'Form',
                options: ref.watch(formOptionsProvider),
                selected: _draft.forms,
                onToggle: (form) =>
                    _edit((f) => f.copyWith(forms: _toggled(f.forms, form))),
              ),
              // Traits and expansions have hundreds of options each, so they
              // get a searchable page instead of a wall of chips.
              _PickerSection(
                title: 'Trait',
                selected: _draft.traits,
                onOpen: () async {
                  final options = await ref.read(
                    traitOptionsProvider.future,
                  );
                  if (!context.mounted) return;
                  final picked = await showMultiSelect(
                    context,
                    title: 'Traits',
                    options: [
                      for (final trait in options)
                        MultiSelectOption(value: trait, label: trait),
                    ],
                    selected: _draft.traits,
                  );
                  if (picked != null) _edit((f) => f.copyWith(traits: picked));
                },
                onClear: () => _edit((f) => f.copyWith(traits: const {})),
              ),
              _PickerSection(
                title: 'Expansion',
                selected: _draft.releaseIds,
                labelOf: (id) => _releaseLabel(id),
                onOpen: () async {
                  final sections = await ref.read(
                    releaseSectionsProvider.future,
                  );
                  if (!context.mounted) return;
                  final picked = await showMultiSelect(
                    context,
                    title: 'Expansions',
                    options: [
                      for (final section in sections)
                        for (final release in section.releases)
                          MultiSelectOption(
                            value: release.id,
                            label: release.displayName,
                            detail: release.setCode ?? section.group.label,
                          ),
                    ],
                    selected: _draft.releaseIds,
                  );
                  if (picked != null) {
                    _edit((f) => f.copyWith(releaseIds: picked));
                  }
                },
                onClear: () => _edit((f) => f.copyWith(releaseIds: const {})),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _draft.includeAlternateArts,
                onChanged: (value) =>
                    _edit((f) => f.copyWith(includeAlternateArts: value)),
                title: const Text('Show alternate arts'),
                subtitle: Text(
                  'List every printing instead of one card per number',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                value: _draft.restrictedOnly,
                onChanged: (value) =>
                    _edit((f) => f.copyWith(restrictedOnly: value)),
                title: const Text('Restricted cards only'),
                subtitle: Text(
                  'Cards limited or banned by the official list',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
              ),
            ],
          ),
        ),
        _ApplyBar(
          filter: _draft,
          onApply: () => Navigator.of(context).pop(_draft),
        ),
      ],
    );
  }

  String _releaseLabel(String id) {
    final sections = ref.read(releaseSectionsProvider).valueOrNull;
    if (sections == null) return id;
    for (final section in sections) {
      for (final release in section.releases) {
        if (release.id == id) return release.setCode ?? release.displayName;
      }
    }
    return id;
  }
}

/// Live result count so the user can tell whether a filter is too narrow
/// before leaving the sheet.
class _ApplyBar extends ConsumerWidget {
  const _ApplyBar({required this.filter, required this.onApply});

  final CardFilter filter;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(filterPreviewCountProvider(filter));
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: const BoxDecoration(
        color: AppSurfaces.surfaceHigh,
        border: Border(top: BorderSide(color: AppSurfaces.outline)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onApply,
            child: Text(
              switch (count) {
                AsyncData(:final value) when value == 1 => 'Show 1 card',
                AsyncData(:final value) => 'Show $value cards',
                AsyncError() => 'Show results',
                _ => 'Show results',
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Counts matches for a filter that has not been applied yet, so the apply
/// button can say how many cards the user is about to see.
final filterPreviewCountProvider = FutureProvider.family<int, CardFilter>(
  (ref, filter) => ref.watch(cardDaoProvider).count(filter),
);

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _ChipWrap<T> extends StatelessWidget {
  const _ChipWrap({
    required this.options,
    required this.labelOf,
    required this.selected,
    required this.onToggle,
  });

  final List<T> options;
  final String Function(T) labelOf;
  final Set<T> selected;
  final void Function(T) onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          FilterChip(
            label: Text(labelOf(option)),
            selected: selected.contains(option),
            onSelected: (_) => onToggle(option),
          ),
      ],
    );
  }
}

class _AsyncChipSection extends StatelessWidget {
  const _AsyncChipSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final String title;
  final AsyncValue<List<String>> options;
  final Set<String> selected;
  final void Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    return _Section(
      title: title,
      child: options.when(
        loading: () => const SizedBox(
          height: 32,
          child: Center(child: LinearProgressIndicator()),
        ),
        error: (error, _) => Text('$error'),
        data: (values) => _ChipWrap<String>(
          options: values,
          labelOf: (value) => value,
          selected: selected,
          onToggle: onToggle,
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final CardColor color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final swatch = DigimonColors.of(color);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? swatch.withValues(alpha: 0.18) : AppSurfaces.surfaceHigh,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? swatch : AppSurfaces.outline,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: swatch, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
            Text(
              color.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? swatch : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeSection extends StatelessWidget {
  const _RangeSection({
    required this.title,
    required this.range,
    required this.max,
    required this.onChanged,
    this.step = 1,
  });

  final String title;
  final RangeFilter range;
  final int max;
  final int step;
  final void Function(RangeFilter) onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final low = (range.min ?? 0).toDouble();
    final high = (range.max ?? max).toDouble();
    final active = !range.isEmpty;

    return _Section(
      title: title,
      trailing: active
          ? TextButton(
              onPressed: () => onChanged(const RangeFilter()),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Any'),
            )
          : Text(
              'Any',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (active)
            Text(
              low == high
                  ? '${low.toInt()}'
                  : '${low.toInt()} – ${high.toInt()}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: scheme.primary,
              ),
            ),
          RangeSlider(
            values: RangeValues(low, high),
            min: 0,
            max: max.toDouble(),
            divisions: max ~/ step,
            labels: RangeLabels('${low.toInt()}', '${high.toInt()}'),
            onChanged: (values) {
              // Sliding back to the full span means "no constraint", so the
              // facet clears itself rather than staying on as a no-op.
              final min = values.start.round();
              final maxValue = values.end.round();
              onChanged(
                min == 0 && maxValue == max
                    ? const RangeFilter()
                    : RangeFilter(min: min, max: maxValue),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PickerSection extends StatelessWidget {
  const _PickerSection({
    required this.title,
    required this.selected,
    required this.onOpen,
    required this.onClear,
    this.labelOf,
  });

  final String title;
  final Set<String> selected;
  final Future<void> Function() onOpen;
  final VoidCallback onClear;
  final String Function(String)? labelOf;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Section(
      title: title,
      trailing: selected.isEmpty
          ? null
          : TextButton(
              onPressed: onClear,
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
              child: const Text('Clear'),
            ),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          decoration: BoxDecoration(
            color: AppSurfaces.surfaceHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppSurfaces.outline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected.isEmpty
                      ? 'Any'
                      : selected.map((v) => labelOf?.call(v) ?? v).join(', '),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: selected.isEmpty ? scheme.onSurfaceVariant : null,
                    fontWeight: selected.isEmpty
                        ? FontWeight.w400
                        : FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
