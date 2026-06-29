import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../models/quote.dart';
import '../models/tag.dart';

/// A page of quotes plus whether more pages exist.
class QuotePage {
  const QuotePage({required this.quotes, required this.hasReachedMax});

  final List<Quote> quotes;
  final bool hasReachedMax;
}

/// Single source of truth for quote data.
///
/// The app is fully offline: quotes are loaded once from the bundled
/// `assets/quotes.json` and cached in memory. This replaces the old
/// `ApiServies` static class, which mixed networking, caching, and global
/// mutable state and depended on the now-defunct `api.quotable.io`.
class QuoteRepository {
  /// Creates a repository that loads quotes from the bundled asset on first use.
  ///
  /// Pass [seed] to inject quotes directly (e.g. in tests) and skip asset
  /// loading entirely, which keeps widget tests off `rootBundle`.
  QuoteRepository({Random? random, List<Quote>? seed})
      : _random = random ?? Random(),
        _quotes = seed ?? const [],
        _loaded = seed != null;

  final Random _random;
  List<Quote> _quotes;
  bool _loaded;

  /// Loads and caches the dataset. Safe to call repeatedly.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/quotes.json');
    final decoded = json.decode(raw) as List<dynamic>;
    _quotes = decoded
        .map((e) => Quote.fromJson(e as Map<String, dynamic>))
        .toList(growable: false);
    _loaded = true;
  }

  /// All available tags, sorted by popularity then name.
  List<Tag> tags() {
    final counts = <String, int>{};
    for (final quote in _quotes) {
      for (final slug in quote.tags) {
        counts[slug] = (counts[slug] ?? 0) + 1;
      }
    }
    final tags = counts.entries
        .map((e) => Tag(slug: e.key, label: _humanize(e.key), count: e.value))
        .toList();
    tags.sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      return byCount != 0 ? byCount : a.label.compareTo(b.label);
    });
    return tags;
  }

  /// Returns a page of quotes, optionally filtered to [tagSlugs] (match ANY).
  ///
  /// [page] is 1-based. Pagination runs over the in-memory list, so it is
  /// instant and deterministic.
  QuotePage page({
    required int page,
    int pageSize = 12,
    List<String> tagSlugs = const [],
  }) {
    final source = tagSlugs.isEmpty
        ? _quotes
        : _quotes
            .where((q) => q.tags.any(tagSlugs.contains))
            .toList(growable: false);

    final start = (page - 1) * pageSize;
    if (start >= source.length) {
      return const QuotePage(quotes: [], hasReachedMax: true);
    }
    final end = min(start + pageSize, source.length);
    return QuotePage(
      quotes: source.sublist(start, end),
      hasReachedMax: end >= source.length,
    );
  }

  /// A random quote, optionally excluding [excludeId] to avoid repeats.
  Quote randomQuote({String? excludeId}) {
    final pool = excludeId == null
        ? _quotes
        : _quotes.where((q) => q.id != excludeId).toList(growable: false);
    final source = pool.isEmpty ? _quotes : pool;
    return source[_random.nextInt(source.length)];
  }

  /// All quotes carrying [slug], in dataset order.
  List<Quote> byTag(String slug) =>
      _quotes.where((q) => q.tags.contains(slug)).toList(growable: false);

  /// Case-insensitive search across quote content and author.
  List<Quote> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _quotes
        .where((quote) =>
            quote.content.toLowerCase().contains(q) ||
            quote.author.toLowerCase().contains(q))
        .toList(growable: false);
  }

  /// Quotes most similar to [quote], best first.
  ///
  /// Scoring is purely offline: +2 per shared tag and +3 for the same author,
  /// which favors topical matches while still surfacing the author's other
  /// work. The quote itself and anything with a zero score are excluded.
  List<Quote> similar(Quote quote, {int limit = 12}) {
    final scored = <({Quote quote, int score})>[];
    for (final other in _quotes) {
      if (other.id == quote.id) continue;
      var score = 0;
      for (final tag in other.tags) {
        if (quote.tags.contains(tag)) score += 2;
      }
      if (other.author == quote.author) score += 3;
      if (score > 0) scored.add((quote: other, score: score));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).map((e) => e.quote).toList(growable: false);
  }

  /// Resolves stored favorite ids back to full quotes, preserving order.
  List<Quote> byIds(List<String> ids) {
    final index = {for (final q in _quotes) q.id: q};
    return ids
        .map((id) => index[id])
        .whereType<Quote>()
        .toList(growable: false);
  }

  static String _humanize(String slug) {
    if (slug.isEmpty) return slug;
    return slug
        .split(RegExp(r'[-_\s]+'))
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
