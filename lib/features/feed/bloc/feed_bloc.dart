import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/preferences_service.dart';
import '../../../core/util/quote_language.dart';
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
        super(FeedState(language: prefs.feedLanguage)) {
    on<FeedRefreshed>(_onRefreshed);
    on<FeedLanguageChanged>(_onLanguageChanged);
    on<FeedNextPageRequested>(
      _onNextPage,
      transformer: droppable(),
    );
  }

  final QuoteRepository _repository;
  final PreferencesService _prefs;
  static const _pageSize = 12;

  /// Onboarding tags describe the English topic taxonomy, so they only apply
  /// when no specific language is chosen. Picking a language is a deliberate
  /// override that shows everything in that language.
  List<String> _tagsFor(QuoteLanguage language) =>
      language == QuoteLanguage.all ? _prefs.selectedTags : const [];

  Future<void> _onRefreshed(
          FeedRefreshed event, Emitter<FeedState> emit) =>
      _loadFirstPage(emit, state.language);

  Future<void> _onLanguageChanged(
      FeedLanguageChanged event, Emitter<FeedState> emit) async {
    if (event.language == state.language) return;
    await _prefs.setFeedLanguage(event.language);
    await _loadFirstPage(emit, event.language);
  }

  /// (Re)loads the feed from page 1 for [language], emitting loading/success/
  /// failure states. Shared by refresh and language-change.
  Future<void> _loadFirstPage(
      Emitter<FeedState> emit, QuoteLanguage language) async {
    emit(FeedState(status: FeedStatus.loading, language: language));
    try {
      await _repository.ensureLoaded();
      final result = _repository.page(
        page: 1,
        pageSize: _pageSize,
        tagSlugs: _tagsFor(language),
        language: language,
      );
      emit(FeedState(
        status: FeedStatus.success,
        quotes: result.quotes,
        page: 1,
        hasReachedMax: result.hasReachedMax,
        language: language,
      ));
    } catch (_) {
      emit(FeedState(
        status: FeedStatus.failure,
        language: language,
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
        tagSlugs: _tagsFor(state.language),
        language: state.language,
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
