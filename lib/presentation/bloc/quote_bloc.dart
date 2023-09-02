import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../core/ApiService.dart';
import '../../domain/quote.dart';

part 'quote_event.dart';
part 'quote_state.dart';

class QuoteBloc extends Bloc<QuoteEvent, QuotessState> {
  QuoteBloc() : super(QuotessState()) {
    on<QuoteEvent>((event, emit) async {
      if (event is GetPostsEvent) {
        if (state.hasReachedMax) return;
        try {
          if (state.status == QouteStatus.loading) {
            final List<Results>? quotes =
                await ApiServies.getAllQuote(state.page);
            print(1);
            return quotes == null || quotes.isEmpty
                ? emit(state.copyWith(
                    status: QouteStatus.success, hasReachedMax: true))
                : emit(state.copyWith(
                    status: QouteStatus.success,
                    quotes: quotes,
                    hasReachedMax: false));
          } else {
            print(2);
            final List<Results>? quotes =
                await ApiServies.getAllQuote(state.page + 1);
            if (quotes == null || quotes.isEmpty) {
              emit(state.copyWith(hasReachedMax: true));
            } else {
              print(3);
              emit(state.copyWith(
                status: QouteStatus.success,
                quotes: List.of(state.quotes)..addAll(quotes),
                page: state.page + 1,
                hasReachedMax: false,
              ));
            }
          }
        } catch (e) {
          emit(state.copyWith(
              status: QouteStatus.error,
              errorMessage: "Failed to fetch quotes"));
        }
      }
      
    },
   // transformer: droppable(),
    );
    
  }
  
}
