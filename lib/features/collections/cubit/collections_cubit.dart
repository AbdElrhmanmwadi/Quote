import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/preferences_service.dart';
import '../../../data/models/collection.dart';

part 'collections_state.dart';

/// Owns the user's quote collections and persists every change.
class CollectionsCubit extends Cubit<CollectionsState> {
  CollectionsCubit(this._prefs)
      : super(CollectionsState(
            collections: Collection.decode(_prefs.collectionsRaw)));

  final PreferencesService _prefs;

  Future<void> _persist(List<Collection> next) async {
    emit(CollectionsState(collections: next));
    await _prefs.setCollectionsRaw(Collection.encode(next));
  }

  bool exists(String name) =>
      state.collections.any((c) => c.name.toLowerCase() == name.toLowerCase());

  /// Creates an empty collection. No-op if the (case-insensitive) name is taken
  /// or blank.
  Future<void> create(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || exists(trimmed)) return;
    await _persist([...state.collections, Collection(name: trimmed)]);
  }

  Future<void> remove(String name) async {
    await _persist(
        state.collections.where((c) => c.name != name).toList(growable: false));
  }

  Future<void> rename(String oldName, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || exists(trimmed)) return;
    await _persist(state.collections
        .map((c) => c.name == oldName ? c.copyWith(name: trimmed) : c)
        .toList(growable: false));
  }

  /// Adds [quoteId] to the named collection (creating it if needed).
  Future<void> addQuote(String collectionName, String quoteId) async {
    var found = false;
    final next = state.collections.map((c) {
      if (c.name != collectionName) return c;
      found = true;
      if (c.contains(quoteId)) return c;
      return c.copyWith(quoteIds: [...c.quoteIds, quoteId]);
    }).toList();
    if (!found) {
      next.add(Collection(name: collectionName, quoteIds: [quoteId]));
    }
    await _persist(next);
  }

  Future<void> removeQuote(String collectionName, String quoteId) async {
    await _persist(state.collections
        .map((c) => c.name == collectionName
            ? c.copyWith(
                quoteIds:
                    c.quoteIds.where((id) => id != quoteId).toList())
            : c)
        .toList(growable: false));
  }
}
