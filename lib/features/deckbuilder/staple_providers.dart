import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers.dart';
import '../../domain/models/staple_list.dart';

/// Every staple list with its cards, in the user's order.
final stapleListsProvider = StreamProvider<List<StapleList>>(
  (ref) => ref.watch(stapleDaoProvider).watchLists(),
);

/// One list, derived from [stapleListsProvider] rather than queried again, so
/// the list screen and the deck builder's source chips never disagree.
final stapleListProvider = Provider.family<StapleList?, int>(
  (ref, listId) => ref
      .watch(stapleListsProvider)
      .valueOrNull
      ?.firstWhereOrNull((list) => list.id == listId),
);
