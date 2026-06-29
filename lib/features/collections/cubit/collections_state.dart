part of 'collections_cubit.dart';

class CollectionsState extends Equatable {
  const CollectionsState({this.collections = const []});

  final List<Collection> collections;

  bool get isEmpty => collections.isEmpty;

  @override
  List<Object?> get props => [collections];
}
