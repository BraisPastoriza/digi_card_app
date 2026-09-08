import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../core/router/navigation.dart';
import '../../core/theme/app_theme.dart';
import '../../data/db/daos/release_dao.dart';
import '../../domain/models/card_enums.dart';
import '../../domain/models/card_release.dart';
import '../../shared/widgets/common.dart';
import 'attribution_screen.dart';
import 'library_providers.dart';
import 'widgets/release_tile.dart';

/// Entry point of the library: every expansion, shown as its own box art and
/// grouped by product line.
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with TickerProviderStateMixin {
  /// The main card pools open by default; the accessory products stay
  /// collapsed so 93 expansions do not arrive as one long scroll.
  final _expanded = <ReleaseGroup>{
    ReleaseGroup.booster,
    ReleaseGroup.ex,
    ReleaseGroup.promo,
  };

  @override
  Widget build(BuildContext context) {
    final sections = ref.watch(releaseSectionsProvider);
    final cardArt = ref.watch(releaseCardArtProvider).valueOrNull ?? const {};

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(releaseSectionsProvider),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              // Floating and snapping, with the search bar riding along in the
              // header: the expansion list is long, and having to scroll all
              // the way back to the top to look something up is the kind of
              // thing that makes people give up on searching.
              floating: true,
              snap: true,
              title: const Text('Library'),
              actions: [
                IconButton(
                  onPressed: () => _showDatabaseInfo(context),
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'Card database',
                ),
              ],
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(56),
                child: _SearchBarButton(),
              ),
            ),
            ...sections.when(
              loading: () => const [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              error: (error, _) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: 'Could not load expansions',
                    message: '$error',
                  ),
                ),
              ],
              data: (sections) => [
                for (final section in sections) ...[
                  SliverToBoxAdapter(
                    child: _GroupHeader(
                      section: section,
                      expanded: _expanded.contains(section.group),
                      onTap: () => setState(() {
                        if (!_expanded.remove(section.group)) {
                          _expanded.add(section.group);
                        }
                      }),
                    ),
                  ),
                  if (_expanded.contains(section.group))
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 240,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              // The tile is entirely artwork, so its height
                              // follows its width and cannot overflow when the
                              // column count changes.
                              childAspectRatio: releaseArtRatio,
                            ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final release = section.releases[index];
                          return ReleaseTile(
                            release: release,
                            cardImage: cardArt[release.id],
                            onTap: () => context.pushOnce(
                              '/library/release/${release.id}',
                            ),
                          );
                        }, childCount: section.releases.length),
                      ),
                    ),
                ],
                SliverToBoxAdapter(
                  child: AttributionFooter(
                    onTap: () => context.pushOnce('/library/credits'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDatabaseInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => const _DatabaseInfoSheet(),
    );
  }
}

/// Read-only bar that hands off to the full search screen, so the library list
/// itself never has to manage a keyboard.
class _SearchBarButton extends StatelessWidget {
  const _SearchBarButton();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: InkWell(
        onTap: () => context.pushOnce('/library/search'),
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
              Icon(Icons.search, size: 20, color: scheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search cards, effects, traits',
                  style: TextStyle(
                    fontSize: 15,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
              Icon(Icons.tune, size: 18, color: scheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.section,
    required this.expanded,
    required this.onTap,
  });

  final ReleaseSection section;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: SectionHeader(
        section.group.label,
        subtitle:
            '${section.releases.length} sets · ${section.cardCount} cards',
        trailing: AnimatedRotation(
          turns: expanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 180),
          child: Icon(
            Icons.keyboard_arrow_down,
            color: scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Shows when the card data was last downloaded and offers a refresh, which
/// is how a player picks up a newly released set.
class _DatabaseInfoSheet extends ConsumerWidget {
  const _DatabaseInfoSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final state = ref.watch(syncStateProvider);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Card database',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            state.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => Text('$error'),
              data: (row) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow('Cards stored', '${row?.cardCount ?? 0}'),
                  _InfoRow('Data published', row?.bulkUpdatedAt ?? 'unknown'),
                  _InfoRow(
                    'Last downloaded',
                    row?.syncedAt == null
                        ? 'never'
                        : _formatDate(row!.syncedAt!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Card data comes from the Heroicc API, plus $secondarySourceName '
              'for sets Heroicc has not published yet. Refreshing re-downloads '
              'the full card list, which is how new sets show up.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.pushOnce('/library/credits');
              },
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: const Text('Data sources & credits'),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Dropping readiness sends the router back to the sync
                  // screen, which reuses the same progress UI as first run.
                  ref.read(resyncRequestedProvider.notifier).state = true;
                  ref.read(libraryReadyProvider.notifier).requireSync();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Check for updates'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
