part of 'quotes_bloc.dart';

@immutable
abstract class QuotesEvent extends Equatable {}

class FetchQuotesEvent extends QuotesEvent {
  final int? start,last;

  FetchQuotesEvent( {required this.start,required this.last});
  
  @override
  List<Object?> get props => [];
}

class FetchQuotesRandomeEvent extends QuotesEvent {
  @override
  List<Object?> get props => [];
}
