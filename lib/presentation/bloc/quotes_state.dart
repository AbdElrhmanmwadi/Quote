part of 'quotes_bloc.dart';

@immutable
abstract class QuotesState extends Equatable {}


class QuotesInitialState extends QuotesState {
  @override
  
  List<Object?> get props => [];
}

class QuotesLoadedState extends QuotesState {
  final List<Results> quotes;

  QuotesLoadedState(this.quotes);
  
  @override
  
  List<Object?> get props => [];
}
class QuotesLoadedRandomeState extends QuotesState {
  final List<Results> quotes;

  QuotesLoadedRandomeState(this.quotes);
  
  @override
  
  List<Object?> get props => [];
}

class QuotesErrorState extends QuotesState {
  @override
  
  List<Object?> get props => [];
}
