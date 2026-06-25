part of 'feed_bloc.dart';

enum FeedStatus { initial, loading, success, failure }

class FeedState extends Equatable {
  const FeedState({
    this.status = FeedStatus.initial,
    this.quotes = const [],
    this.page = 0,
    this.hasReachedMax = false,
    this.errorMessage = '',
  });

  final FeedStatus status;
  final List<Quote> quotes;
  final int page;
  final bool hasReachedMax;
  final String errorMessage;

  FeedState copyWith({
    FeedStatus? status,
    List<Quote>? quotes,
    int? page,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return FeedState(
      status: status ?? this.status,
      quotes: quotes ?? this.quotes,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props =>
      [status, quotes, page, hasReachedMax, errorMessage];
}
