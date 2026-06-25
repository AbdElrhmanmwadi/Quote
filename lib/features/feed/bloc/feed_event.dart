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
