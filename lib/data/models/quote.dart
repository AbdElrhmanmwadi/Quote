import 'package:equatable/equatable.dart';

/// An immutable quote.
///
/// Replaces the old mutable, deeply-nullable `Results` model. Parsing is
/// defensive: missing fields fall back to safe defaults instead of throwing
/// (the previous `json['tags'].cast<String>()` crashed whenever `tags` was
/// absent, e.g. on random/search payloads).
class Quote extends Equatable {
  const Quote({
    required this.id,
    required this.content,
    required this.author,
    this.tags = const [],
  });

  final String id;
  final String content;
  final String author;
  final List<String> tags;

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      content: (json['content'] ?? json['quote'] ?? '').toString(),
      author: (json['author'] ?? 'Unknown').toString(),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((t) => t.toString())
              .toList(growable: false) ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'content': content,
        'author': author,
        'tags': tags,
      };

  /// Text suitable for sharing to other apps.
  String get shareText => '"$content"\n— $author';

  @override
  List<Object?> get props => [id];
}
