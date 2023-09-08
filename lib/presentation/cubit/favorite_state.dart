part of 'favorite_cubit.dart';

class FavoriteState extends Equatable {
  final bool Favorite;
  const FavoriteState({required this.Favorite});
 factory FavoriteState.initial(){
    return const FavoriteState(Favorite: false);
  }

  @override
  List<Object> get props => [Favorite];
  FavoriteState copyWith({Favorite}) {
    return FavoriteState(Favorite: Favorite ?? this.Favorite);
  }
}
