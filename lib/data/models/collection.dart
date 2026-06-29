import 'dart:convert';

import 'package:equatable/equatable.dart';

/// A user-created, named bucket of saved quotes (by id).
///
/// Collections let the user organize quotes into folders (e.g. "Work",
/// "Stoic") instead of one flat favorites list. Quote ids are stored — the
/// full [Quote] is resolved on demand through the repository.
class Collection extends Equatable {
  const Collection({required this.name, this.quoteIds = const []});

  final String name;
  final List<String> quoteIds;

  int get length => quoteIds.length;
  bool contains(String id) => quoteIds.contains(id);

  Collection copyWith({String? name, List<String>? quoteIds}) => Collection(
        name: name ?? this.name,
        quoteIds: quoteIds ?? this.quoteIds,
      );

  Map<String, dynamic> toJson() => {'name': name, 'quoteIds': quoteIds};

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        name: (json['name'] ?? '').toString(),
        quoteIds: (json['quoteIds'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList(growable: false) ??
            const [],
      );

  /// Encodes a list of collections to a JSON string for persistence.
  static String encode(List<Collection> collections) =>
      jsonEncode(collections.map((c) => c.toJson()).toList());

  /// Decodes the persisted JSON string back into collections. Tolerates null
  /// and malformed payloads by returning an empty list.
  static List<Collection> decode(String? raw) {
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => Collection.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  @override
  List<Object?> get props => [name, quoteIds];
}
