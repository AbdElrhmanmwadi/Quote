part of 'quote_bloc.dart';

sealed class QuoteEvent extends Equatable {
  const QuoteEvent();


  @override
  List<Object> get props => [];
}
class GetPostsEvent extends QuoteEvent{
  // final int page;

 // GetPostsEvent(this.page);
   @override
  List<Object> get props => [];

}
