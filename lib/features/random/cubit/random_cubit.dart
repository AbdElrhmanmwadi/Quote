import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/quote.dart';
import '../../../data/repositories/quote_repository.dart';

part 'random_state.dart';

/// Serves a single random quote and can shuffle to a new one.
///
/// Replaces the old random flow, which spun up a second `QuoteBloc` outside DI
/// and mutated a shared growing list. Here the state is just the current quote.
class RandomCubit extends Cubit<RandomState> {
  RandomCubit(this._repository) : super(const RandomState());

  final QuoteRepository _repository;

  Future<void> shuffle() async {
    emit(state.copyWith(status: RandomStatus.loading));
    try {
      await _repository.ensureLoaded();
      final quote = _repository.randomQuote(excludeId: state.quote?.id);
      emit(RandomState(status: RandomStatus.success, quote: quote));
    } catch (_) {
      emit(state.copyWith(status: RandomStatus.failure));
    }
  }
}
