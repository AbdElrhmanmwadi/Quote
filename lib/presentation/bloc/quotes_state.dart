part of 'quotes_bloc.dart';

@immutable
sealed class QuotesState {}


class QuotesInitialState extends QuotesState {}

class QuotesLoadedState extends QuotesState {
  final List<Results> quotes;

  QuotesLoadedState(this.quotes);
}
class QuotesLoadedRandomeState extends QuotesState {
  final List<Results> quotes;

  QuotesLoadedRandomeState(this.quotes);
}

class QuotesErrorState extends QuotesState {}
