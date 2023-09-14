import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/ApiService.dart';
import '../../model/quote.dart';

part 'quote_event.dart';
part 'quote_state.dart';

class QuoteBloc extends Bloc<QuoteEvent, QuotessState> {
  List<Results> quotes = [];
  bool rotateIcon = false;

  QuoteBloc() : super(QuotessState()) {
    on<QuoteEvent>(
      (event, emit) async {
        if (event is GetPostsEvent) {
          if (state.hasReachedMax) return;
          try {
            if (state.status == QouteStatus.loading) {
              final List<Results>? quotes =
                  await ApiServies.getAllQuote(state.page);

              return quotes == null || quotes.isEmpty
                  ? emit(state.copyWith(
                      status: QouteStatus.success, hasReachedMax: true))
                  : emit(state.copyWith(
                      status: QouteStatus.success,
                      quotes: quotes,
                      hasReachedMax: false));
            } else {
              final List<Results>? quotes =
                  await ApiServies.getAllQuote(state.page + 1);

              if (quotes == null || quotes.isEmpty || state.page == 20) {
                emit(state.copyWith(hasReachedMax: true));
              } else {
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
                errorMessage: "No Internet Connection"));
          }
        }
        if (event is FetchQuotessRandomeEvent) {
          emit(QuotesLoadinggState());
          rotateIcon = !rotateIcon;

          try {
            Results? result = await ApiServies.getRandomQuote();
            if (quotes.isNotEmpty) {
              quotes.removeAt(0);
            }
            quotes.add(result);
            if (quotes.isNotEmpty) {
              emit(QuotesLoadedRandomeeState(quotes));
            } else {
              emit(QuotesErrorrState());
            }
          } catch (e) {
            emit(QuotesErrorrState());
          }
        }
      },
    );
  
  }
}
