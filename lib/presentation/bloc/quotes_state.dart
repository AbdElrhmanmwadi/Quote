part of 'quotes_bloc.dart';

@immutable
abstract class QuotesState extends Equatable {}


class QuotesInitialState extends QuotesState {
  @override
  
  List<Object?> get props => [];
}
class QuotesLoadingState extends QuotesState {
  @override
  
  List<Object?> get props => [];
}

class QuotesLoadedState extends QuotesState {
  final List<Results> quotes;
  final List<Tag> tag;

  QuotesLoadedState(this.quotes, this.tag);
  
  @override
  
  List<Object?> get props => [quotes,tag];
}
class QuotesLoadedRandomeState extends QuotesState {
  final List<Results> quotes;

  QuotesLoadedRandomeState(this.quotes);
  
  @override
  
  List<Object?> get props => [quotes];
}

class QuotesErrorState extends QuotesState {
  @override
  
  List<Object?> get props => [];
}
