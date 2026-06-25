part of 'favorites_cubit.dart';

class FavoritesState extends Equatable {
  const FavoritesState({this.ids = const {}});

  final Set<String> ids;

  bool get isEmpty => ids.isEmpty;

  @override
  List<Object?> get props => [ids];
}
