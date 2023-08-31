part of 'quotes_bloc.dart';

@immutable
abstract class QuotesEvent extends Equatable {}

class FetchQuotesEvent extends QuotesEvent {
  @override
  List<Object?> get props => [];
}

class FetchQuotesRandomeEvent extends QuotesEvent {
  @override
  List<Object?> get props => [];
}


