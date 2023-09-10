part of 'favorite_cubit.dart';

class FavoriteState extends Equatable {
  final bool favorite;
  const FavoriteState({required this.favorite});
 factory FavoriteState.initial(){
    return const FavoriteState(favorite: false);
  }

  @override
  List<Object> get props => [favorite];
  FavoriteState copyWith({favorite}) {
    return FavoriteState(favorite: favorite ?? this.favorite);
  }
}
