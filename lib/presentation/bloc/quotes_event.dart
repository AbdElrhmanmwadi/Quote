part of 'quotes_bloc.dart';

@immutable
abstract class QuotesEvent {}
class FetchQuotesEvent extends QuotesEvent {}
class FetchQuotesRandomeEvent extends QuotesEvent {
}
