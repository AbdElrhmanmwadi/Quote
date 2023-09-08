import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:quote/core/SharedPreferences.dart';

part 'favorite_state.dart';

class FavoriteCubit extends Cubit<FavoriteState> {
  FavoriteCubit() : super(FavoriteState.initial());

  Future<void> loadFavoriteQuoteStatus(id) async {
    SharedPrefController().getData(key: id);
  }

  void toggleFavorite(id) async {
    SharedPrefController().setData(id, !state.Favorite);

    emit(state.copyWith(Favorite: !state.Favorite));
    print(state.Favorite);
  }
}
