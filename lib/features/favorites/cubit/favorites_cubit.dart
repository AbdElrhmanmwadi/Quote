import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/preferences_service.dart';

part 'favorites_state.dart';

/// Manages the set of favorited quote ids and persists it.
///
/// The old `FavoriteCubit` ignored the quote id and flipped a single shared
/// bool, so every card shared one favorite state and nothing was ever stored.
/// This version keeps a real, per-id [Set] and writes it back to preferences on
/// every change.
class FavoritesCubit extends Cubit<FavoritesState> {
  FavoritesCubit(this._prefs)
      : super(FavoritesState(ids: _prefs.favoriteIds.toSet()));

  final PreferencesService _prefs;

  bool isFavorite(String id) => state.ids.contains(id);

  Future<void> toggle(String id) async {
    final next = Set<String>.from(state.ids);
    if (!next.add(id)) {
      next.remove(id);
    }
    emit(FavoritesState(ids: next));
    await _prefs.setFavoriteIds(next.toList());
  }
}
