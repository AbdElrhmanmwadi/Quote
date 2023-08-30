import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:quote/core/ApiService.dart';
import 'package:quote/domain/quote.dart';

part 'quotes_event.dart';
part 'quotes_state.dart';

class QuotesBloc extends Bloc<QuotesEvent, QuotesState> {
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
    });
  }
}
