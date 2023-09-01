import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:quote/core/ApiService.dart';
import 'package:quote/core/SharedPreferences.dart';
import 'package:quote/domain/quote.dart';
import 'package:quote/domain/tag.dart';

part 'quotes_event.dart';
part 'quotes_state.dart';

class QuotesBloc extends Bloc<QuotesEvent, QuotesState> {
  List<Results> quotes = [];
  QuotesBloc() : super(QuotesInitialState()) {
    on<QuotesEvent>((event, emit) async {
      if (event is FetchQuotesEvent) {
        if (event.last == 20) return;
        emit(QuotesInitialState());

        try {
          List<Results>? quotes =
              await ApiServies.getAllQuotesFromPages(event.start!, event.last!);
          List<Tag> listTag = await ApiServies.getAllTag();
          if (quotes.isNotEmpty && event.last != 20) {
            print(1);
            print(event.start!);
            print(event.last!);
            emit(QuotesLoadedState(quotes, listTag));
          } else if (quotes.isEmpty) {
            print(2);
          } else {
            print('3');
            emit(QuotesErrorState());
          }
        } catch (e) {
          print(3);
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
