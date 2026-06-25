part of 'random_cubit.dart';

enum RandomStatus { initial, loading, success, failure }

class RandomState extends Equatable {
  const RandomState({this.status = RandomStatus.initial, this.quote});

  final RandomStatus status;
  final Quote? quote;

  RandomState copyWith({RandomStatus? status, Quote? quote}) {
    return RandomState(
      status: status ?? this.status,
      quote: quote ?? this.quote,
    );
  }

  @override
  List<Object?> get props => [status, quote];
}
