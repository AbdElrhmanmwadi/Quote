part of 'feed_bloc.dart';

sealed class FeedEvent extends Equatable {
  const FeedEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) the feed from the first page.
class FeedRefreshed extends FeedEvent {
  const FeedRefreshed();
}

/// Append the next page of quotes.
class FeedNextPageRequested extends FeedEvent {
  const FeedNextPageRequested();
}

/// Switch the feed's language filter and reload from the first page.
class FeedLanguageChanged extends FeedEvent {
  const FeedLanguageChanged(this.language);

  final QuoteLanguage language;

  @override
  List<Object?> get props => [language];
}
