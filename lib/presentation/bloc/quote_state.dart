




part of 'quote_bloc.dart';



enum QouteStatus { loading, success, error }

class QuotessState extends Equatable {
  final QouteStatus status;
  final List<Results> quotes;
  final int page;
  final bool hasReachedMax;
  final String errorMessage;

  const QuotessState({
    this.status = QouteStatus.loading,
    this.quotes = const [],
    this.page = 1,
    this.hasReachedMax = false,
    this.errorMessage = "",
  });

  QuotessState copyWith({
    QouteStatus? status,
    List<Results>? quotes,
    int? page,
    bool? hasReachedMax,
    String? errorMessage,
  }) {
    return QuotessState(
      status: status ?? this.status,
      quotes: quotes ?? this.quotes,
      page: page ?? this.page,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, quotes, page, hasReachedMax, errorMessage];
}