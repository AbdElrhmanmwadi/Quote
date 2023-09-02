// ignore_for_file: avoid_print

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
  static List<Results>? AllQuote = [];

  QuotesBloc() : super(QuotesInitialState()) {
    on<QuotesEvent>((event, emit) async {
      if (event is FetchQuotesEvent) {
        if (event.page == 20) return;
        if (event.page == 1) {
          // Clear the AllQuote list when fetching the first page.
          AllQuote = [];
        }
        emit(QuotesLoadingState());

        try {
          List<Results>? newQuotes = await ApiServies.getAllQuote(event.page!);
          List<Tag> listTag = await ApiServies.getAllTag();

          if (newQuotes!.isNotEmpty) {
            print('${event.page} start');
            AllQuote!.addAll(newQuotes);
            print(AllQuote!.length);
            var uniqueQuotes = AllQuote!.toSet().toList();
            print(uniqueQuotes.length);

            emit(QuotesLoadedState(uniqueQuotes, listTag));
          } else {
            emit(QuotesErrorState());
          }
        } catch (e) {
          emit(QuotesErrorState());
        }
      } else if (event is FetchQuotesRandomeEvent) {
        emit(QuotesLoadingState());

        try {
          Results? result = await ApiServies.getRandomQuote();

          if (result != null) {
            quotes.add(result);
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
