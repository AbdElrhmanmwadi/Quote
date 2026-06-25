import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/preferences_service.dart';
import '../../../data/models/quote.dart';
import '../../../data/repositories/quote_repository.dart';

part 'feed_event.dart';
part 'feed_state.dart';

/// Drives the infinitely-scrolling quote feed.
///
/// Pagination is filtered by the tags the user selected during onboarding.
/// A `droppable` transformer collapses scroll spam so we never fire overlapping
/// page requests (the old screen guarded this with a manual `isFetching` flag
/// and a `Future.delayed`).
class FeedBloc extends Bloc<FeedEvent, FeedState> {
  FeedBloc(
      {required QuoteRepository repository, required PreferencesService prefs})
      : _repository = repository,
        _prefs = prefs,
        super(const FeedState()) {
    on<FeedRefreshed>(_onRefreshed);
    on<FeedNextPageRequested>(
      _onNextPage,
      transformer: droppable(),
    );
  }

  final QuoteRepository _repository;
  final PreferencesService _prefs;
  static const _pageSize = 12;

  Future<void> _onRefreshed(
      FeedRefreshed event, Emitter<FeedState> emit) async {
    emit(const FeedState(status: FeedStatus.loading));
    try {
      await _repository.ensureLoaded();
      final result = _repository.page(
        page: 1,
        pageSize: _pageSize,
        tagSlugs: _prefs.selectedTags,
      );
      emit(FeedState(
        status: FeedStatus.success,
        quotes: result.quotes,
        page: 1,
        hasReachedMax: result.hasReachedMax,
      ));
    } catch (_) {
      emit(const FeedState(
        status: FeedStatus.failure,
        errorMessage: 'Could not load quotes. Please try again.',
      ));
    }
  }

  Future<void> _onNextPage(
      FeedNextPageRequested event, Emitter<FeedState> emit) async {
    if (state.hasReachedMax || state.status == FeedStatus.loading) return;
    try {
      await _repository.ensureLoaded();
      final nextPage = state.page + 1;
      final result = _repository.page(
        page: nextPage,
        pageSize: _pageSize,
        tagSlugs: _prefs.selectedTags,
      );
      emit(state.copyWith(
        status: FeedStatus.success,
        quotes: [...state.quotes, ...result.quotes],
        page: nextPage,
        hasReachedMax: result.hasReachedMax,
      ));
    } catch (_) {
      // Keep the already-loaded quotes; just stop paginating on error.
      emit(state.copyWith(hasReachedMax: true));
    }
  }
}
