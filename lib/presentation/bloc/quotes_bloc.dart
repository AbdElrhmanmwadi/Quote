import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:quote/core/ApiService.dart';
import 'package:quote/core/SharedPreferences.dart';
import 'package:quote/domain/quote.dart';

part 'quotes_event.dart';
part 'quotes_state.dart';

class QuotesBloc extends Bloc<QuotesEvent, QuotesState> {
  List<Results> quotes = [];
  bool _isFavorite = false;
  QuotesBloc() : super(QuotesInitialState()) {
    on<QuotesEvent>((event, emit) async {
      if (event is FetchQuotesEvent) {
        emit(QuotesInitialState());
        try {
          List<Results>? quotes =
              await ApiServies.getQuotesFromSharedPreferences() ??
                  await ApiServies.getAllQuote();
          if (quotes != null) {
            emit(QuotesLoadedState(quotes));
          } else {
            emit(QuotesErrorState());
          }
        } catch (e) {
          emit(QuotesErrorState());
        }
      } 
      if (event is FetchQuotesRandomeEvent) {
        emit(QuotesInitialState());
        try {
          Results? results = await ApiServies.getRandomQuote();

          if (quotes.isNotEmpty) {
            quotes.removeAt(0);
          }
          quotes.add(results);

          if (quotes.isNotEmpty) {
            emit(QuotesLoadedRandomeState(quotes));
          } else {
            emit(QuotesErrorState());
          }
        } catch (e) {
          emit(QuotesErrorState());
        }
      }
    });
  }
}
