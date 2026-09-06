import 'dart:async';

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
Future<CardFilter?> showFilterSheet(BuildContext context, CardFilter current) {
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

  /// The filter the live result count is running against. It lags [_draft] by
  /// a short debounce so dragging a slider does not fire a count query on
  /// every frame.
  late CardFilter _previewFilter = widget.initial;
  Timer? _previewDebounce;

  /// Sections the user has opened. Everything past the first few starts
  /// collapsed: with 48 keywords and 20-odd attributes, an all-open sheet is
  /// several screens of chips to scroll past.
  final _open = <String>{'Color', 'Card type', 'Level'};

  @override
  void dispose() {
    _previewDebounce?.cancel();
    super.dispose();
  }

  void _edit(CardFilter Function(CardFilter) change) {
    setState(() => _draft = change(_draft));
    _previewDebounce?.cancel();
    _previewDebounce = Timer(const Duration(milliseconds: 220), () {
      if (mounted) setState(() => _previewFilter = _draft);
    });
  }

  /// Adds or removes [value] from a set-valued facet.
  Set<T> _toggled<T>(Set<T> values, T value) {
    final next = Set<T>.of(values);
    if (!next.remove(value)) next.add(value);
    return next;
  }

  void _toggleSection(String title) => setState(() {
    if (!_open.remove(title)) _open.add(title);
  });

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
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              _Section(
                title: 'Color',
                selectedCount: _draft.colors.length,
                expanded: _open.contains('Color'),
                onToggle: () => _toggleSection('Color'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
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
                    if (_draft.colors.length > 1) ...[
                      const SizedBox(height: 12),
                      SegmentedButton<ColorMatchMode>(
                        segments: [
                          for (final mode in ColorMatchMode.values)
                            ButtonSegment(value: mode, label: Text(mode.label)),
                        ],
                        selected: {_draft.colorMatchMode},
                        showSelectedIcon: false,
                        style: const ButtonStyle(
                          visualDensity: VisualDensity.compact,
                          textStyle: WidgetStatePropertyAll(
                            TextStyle(fontSize: 12),
                          ),
                        ),
                        onSelectionChanged: (selection) => _edit(
                          (f) => f.copyWith(colorMatchMode: selection.first),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _Section(
                title: 'Card type',
                selectedCount:
                    _draft.categories.length +
                    (_draft.aceOnly ? 1 : 0) +
                    (_draft.dualOnly ? 1 : 0) +
                    (_draft.tokens == TokenMode.include ? 0 : 1),
                expanded: _open.contains('Card type'),
                onToggle: () => _toggleSection('Card type'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ChipWrap(
                      options: CardCategory.values,
                      labelOf: (category) => category.label,
                      selected: _draft.categories,
                      onToggle: (category) => _edit(
                        (f) => f.copyWith(
                          categories: _toggled(f.categories, category),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'ACE, dual and token cards narrow whichever types are '
                      'selected.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        FilterChip(
                          label: const Text('ACE'),
                          selected: _draft.aceOnly,
                          onSelected: (value) =>
                              _edit((f) => f.copyWith(aceOnly: value)),
                        ),
                        FilterChip(
                          label: const Text('Dual Card'),
                          selected: _draft.dualOnly,
                          onSelected: (value) =>
                              _edit((f) => f.copyWith(dualOnly: value)),
                        ),
                        // Tokens are printed as Digimon, so they have no card
                        // type of their own to sit beside the four above.
                        FilterChip(
                          label: const Text('Token'),
                          selected: _draft.tokens == TokenMode.only,
                          onSelected: (value) => _edit(
                            (f) => f.copyWith(
                              tokens: value
                                  ? TokenMode.only
                                  : TokenMode.include,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _Section(
                title: 'Level',
                selectedCount: _draft.levels.length,
                expanded: _open.contains('Level'),
                onToggle: () => _toggleSection('Level'),
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
                expanded: _open.contains('Play / use cost'),
                onToggle: () => _toggleSection('Play / use cost'),
                onChanged: (range) => _edit((f) => f.copyWith(playCost: range)),
              ),
              _RangeSection(
                title: 'Digivolution cost',
                range: _draft.digivolveCost,
                max: FilterBounds.maxDigivolveCost,
                expanded: _open.contains('Digivolution cost'),
                onToggle: () => _toggleSection('Digivolution cost'),
                onChanged: (range) =>
                    _edit((f) => f.copyWith(digivolveCost: range)),
              ),
              _RangeSection(
                title: 'DP',
                range: _draft.dp,
                max: FilterBounds.maxDp,
                step: FilterBounds.dpStep,
                expanded: _open.contains('DP'),
                onToggle: () => _toggleSection('DP'),
                onChanged: (range) => _edit((f) => f.copyWith(dp: range)),
              ),
              _AsyncChipSection(
                title: 'Keyword',
                searchable: true,
                options: ref.watch(keywordOptionsProvider),
                selected: _draft.keywords,
                expanded: _open.contains('Keyword'),
                onToggle: () => _toggleSection('Keyword'),
                onSelect: (keyword) => _edit(
                  (f) => f.copyWith(keywords: _toggled(f.keywords, keyword)),
                ),
              ),
              _AsyncChipSection(
                title: 'Rarity',
                options: ref.watch(rarityOptionsProvider),
                selected: _draft.rarities,
                expanded: _open.contains('Rarity'),
                onToggle: () => _toggleSection('Rarity'),
                onSelect: (rarity) => _edit(
                  (f) => f.copyWith(rarities: _toggled(f.rarities, rarity)),
                ),
              ),
              _AsyncChipSection(
                title: 'Attribute',
                searchable: true,
                options: ref.watch(attributeOptionsProvider),
                selected: _draft.attributes,
                expanded: _open.contains('Attribute'),
                onToggle: () => _toggleSection('Attribute'),
                onSelect: (attribute) => _edit(
                  (f) =>
                      f.copyWith(attributes: _toggled(f.attributes, attribute)),
                ),
              ),
              _AsyncChipSection(
                title: 'Form',
                searchable: true,
                options: ref.watch(formOptionsProvider),
                selected: _draft.forms,
                expanded: _open.contains('Form'),
                onToggle: () => _toggleSection('Form'),
                onSelect: (form) =>
                    _edit((f) => f.copyWith(forms: _toggled(f.forms, form))),
              ),
              // Traits and expansions have hundreds of options each, so they
              // open a searchable page instead of expanding in place.
              _PickerSection(
                title: 'Trait',
                selected: _draft.traits,
                onOpen: () async {
                  final options = await ref.read(traitOptionsProvider.future);
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
                labelOf: _releaseLabel,
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
              const Divider(height: 28),
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
          filter: _previewFilter,
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
            child: Text(switch (count) {
              AsyncData(:final value) when value == 1 => 'Show 1 card',
              AsyncData(:final value) => 'Show $value cards',
              _ => 'Show results',
            }),
          ),
        ),
      ),
    );
  }
}

/// Counts matches for a filter that has not been applied yet, so the apply
/// button can say how many cards the user is about to see.
///
/// Auto-disposing matters here: dragging a slider produces a new filter, and
/// therefore a new provider, on every frame.
final filterPreviewCountProvider = FutureProvider.autoDispose
    .family<int, CardFilter>(
      (ref, filter) => ref.watch(cardDaoProvider).count(filter),
    );

/// A collapsible facet, with a badge showing how many of its options are on so
/// a collapsed section never hides an active filter.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.child,
    required this.expanded,
    required this.onToggle,
    this.selectedCount = 0,
    this.trailing,
  });

  final String title;
  final Widget child;
  final bool expanded;
  final VoidCallback onToggle;
  final int selectedCount;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (selectedCount > 0) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$selectedCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                ?trailing,
                AnimatedRotation(
                  turns: expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 160),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 22,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 2, 4, 14),
            child: child,
          ),
        const Divider(height: 1),
      ],
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

/// A chip facet whose options come from the card data, optionally with a
/// search box for the long ones.
class _AsyncChipSection extends StatefulWidget {
  const _AsyncChipSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.expanded,
    required this.onToggle,
    required this.onSelect,
    this.searchable = false,
  });

  final String title;
  final AsyncValue<List<String>> options;
  final Set<String> selected;
  final bool expanded;
  final VoidCallback onToggle;
  final void Function(String) onSelect;
  final bool searchable;

  @override
  State<_AsyncChipSection> createState() => _AsyncChipSectionState();
}

class _AsyncChipSectionState extends State<_AsyncChipSection> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _Section(
      title: widget.title,
      selectedCount: widget.selected.length,
      expanded: widget.expanded,
      onToggle: widget.onToggle,
      child: widget.options.when(
        loading: () => const LinearProgressIndicator(),
        error: (error, _) => Text('$error'),
        data: (values) {
          // Selected options stay visible even when the search excludes them,
          // so a filter can always be turned back off.
          final needle = _query.trim().toLowerCase();
          final visible = needle.isEmpty
              ? values
              : values
                    .where(
                      (v) =>
                          v.toLowerCase().contains(needle) ||
                          widget.selected.contains(v),
                    )
                    .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.searchable && values.length > 8) ...[
                TextField(
                  onChanged: (value) => setState(() => _query = value),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search ${widget.title.toLowerCase()}',
                    prefixIcon: const Icon(Icons.search, size: 18),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
              if (visible.isEmpty)
                Text(
                  'Nothing matches "$_query"',
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                )
              else
                _ChipWrap<String>(
                  options: visible,
                  labelOf: (value) => value,
                  selected: widget.selected,
                  onToggle: widget.onSelect,
                ),
            ],
          );
        },
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
          color: selected
              ? swatch.withValues(alpha: 0.18)
              : AppSurfaces.surfaceHigh,
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
    required this.expanded,
    required this.onToggle,
    this.step = 1,
  });

  final String title;
  final RangeFilter range;
  final int max;
  final int step;
  final void Function(RangeFilter) onChanged;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final low = (range.min ?? 0).toDouble();
    final high = (range.max ?? max).toDouble();
    final active = !range.isEmpty;

    return _Section(
      title: title,
      selectedCount: active ? 1 : 0,
      expanded: expanded,
      onToggle: onToggle,
      trailing: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: Text(
          active
              ? (low == high
                    ? '${low.toInt()}'
                    : '${low.toInt()} – ${high.toInt()}')
              : 'Any',
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
            color: active ? scheme.primary : scheme.onSurfaceVariant,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          if (active)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => onChanged(const RangeFilter()),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                ),
                child: const Text('Clear'),
              ),
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
    return Column(
      children: [
        ListTile(
          onTap: onOpen,
          contentPadding: const EdgeInsets.symmetric(horizontal: 4),
          title: Text(
            title,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            selected.isEmpty
                ? 'Any'
                : selected.map((v) => labelOf?.call(v) ?? v).join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: selected.isEmpty
                  ? scheme.onSurfaceVariant
                  : scheme.primary,
              fontWeight: selected.isEmpty ? FontWeight.w400 : FontWeight.w600,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selected.isNotEmpty)
                IconButton(
                  onPressed: onClear,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, size: 18),
                ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}
