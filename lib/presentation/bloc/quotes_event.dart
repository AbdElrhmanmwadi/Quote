part of 'quotes_bloc.dart';

@immutable
abstract class QuotesEvent extends Equatable {}
class FetchQuotesEvent extends QuotesEvent {
  @override
  
  List<Object?> get props => throw UnimplementedError();
}
class FetchQuotesRandomeEvent extends QuotesEvent {
  @override
  List<Object?> get props => throw UnimplementedError();
}
class ToggleFavoriteEvent extends QuotesEvent {
  final int currentIndex;
  final bool isFavorite;

  ToggleFavoriteEvent(this.currentIndex, this.isFavorite);

  @override
  List<Object> get props => [currentIndex, isFavorite];
}
