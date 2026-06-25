import 'package:equatable/equatable.dart';

/// A topic that groups quotes, with how many quotes carry it.
class Tag extends Equatable {
  const Tag({required this.slug, required this.label, required this.count});

  /// Stable identifier used for filtering and persistence (e.g. `wisdom`).
  final String slug;

  /// Human-friendly display label (e.g. `Wisdom`).
  final String label;

  /// Number of quotes carrying this tag.
  final int count;

  @override
  List<Object?> get props => [slug];
}
