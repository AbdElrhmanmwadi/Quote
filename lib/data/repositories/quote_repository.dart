import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;

import '../../core/nlp/semantic_index.dart';
import '../../core/util/bidi.dart';
import '../../core/util/quote_language.dart';
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
        _loaded = seed != null {
    if (_loaded) _buildIndex();
  }

  final Random _random;
  List<Quote> _quotes;
  bool _loaded;

  /// Offline semantic engine over [_quotes]; rebuilt whenever the dataset loads.
  SemanticIndex? _index;

  /// Loads and caches the dataset. Safe to call repeatedly.
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final quotes = <Quote>[
      ...await _loadAsset('assets/quotes.json'),
      ...await _loadAsset('assets/quotes_ar.json'),
    ];
    _quotes = List.unmodifiable(quotes);
    _loaded = true;
    _buildIndex();
  }

  /// Parses a bundled quote asset. A missing/empty asset yields no quotes so a
  /// dataset issue can never crash startup.
  Future<List<Quote>> _loadAsset(String path) async {
    try {
      final raw = await rootBundle.loadString(path);
      final decoded = json.decode(raw) as List<dynamic>;
      return decoded
          .map((e) => Quote.fromJson(e as Map<String, dynamic>))
          .toList(growable: false);
    } catch (_) {
      return const [];
    }
  }

  /// Builds the TF-IDF semantic index. Each quote is indexed on its content
  /// plus author and (humanized) tags, so all three contribute to relevance.
  void _buildIndex() {
    _index = SemanticIndex.build([
      for (final q in _quotes)
        '${q.content} ${q.author} ${q.source ?? ''} '
            '${q.tags.map(_humanize).join(' ')}',
    ]);
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

  /// Returns a page of quotes, optionally filtered to [tagSlugs] (match ANY)
  /// and/or a [language].
  ///
  /// [page] is 1-based. Pagination runs over the in-memory list, so it is
  /// instant and deterministic.
  QuotePage page({
    required int page,
    int pageSize = 12,
    List<String> tagSlugs = const [],
    QuoteLanguage language = QuoteLanguage.all,
  }) {
    final source = _quotes.where((q) {
      if (!_matchesLanguage(language, q)) return false;
      if (tagSlugs.isNotEmpty && !q.tags.any(tagSlugs.contains)) return false;
      return true;
    }).toList(growable: false);

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

  /// All quotes by [author], in dataset order.
  List<Quote> byAuthor(String author) =>
      _quotes.where((q) => q.author == author).toList(growable: false);

  /// Distinct authors with how many quotes each has, most first then A–Z.
  List<({String author, int count})> authors() {
    final counts = <String, int>{};
    for (final quote in _quotes) {
      counts[quote.author] = (counts[quote.author] ?? 0) + 1;
    }
    final result = counts.entries
        .map((e) => (author: e.key, count: e.value))
        .toList();
    result.sort((a, b) {
      final byCount = b.count.compareTo(a.count);
      return byCount != 0 ? byCount : a.author.compareTo(b.author);
    });
    return result;
  }

  /// Case-insensitive substring search across quote content and author.
  ///
  /// Kept for exact/partial-word matching (e.g. while the user is still typing
  /// a word). For meaning-aware results, prefer [smartSearch].
  List<Quote> search(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return _quotes
        .where((quote) =>
            quote.content.toLowerCase().contains(q) ||
            quote.author.toLowerCase().contains(q))
        .toList(growable: false);
  }

  /// Ranks quotes by semantic relevance to [query] using the offline TF-IDF
  /// index, best first. Returns nothing for a blank query.
  List<Quote> semanticSearch(String query, {int limit = 50}) {
    final index = _index;
    if (index == null || query.trim().isEmpty) return const [];
    return index
        .query(query, limit: limit)
        .map((s) => _quotes[s.index])
        .toList(growable: false);
  }

  /// Meaning-aware search: exact substring matches first (so a term the user
  /// literally typed is never buried), then semantically related quotes that
  /// the substring pass missed. This is the search the UI should call.
  List<Quote> smartSearch(String query, {int limit = 50}) {
    if (query.trim().isEmpty) return const [];
    final results = <Quote>[];
    final seen = <String>{};
    for (final quote in [...search(query), ...semanticSearch(query, limit: limit)]) {
      if (seen.add(quote.id)) results.add(quote);
      if (results.length >= limit) break;
    }
    return results;
  }

  /// Quotes most similar to [quote], best first.
  ///
  /// Scoring blends three fully-offline signals: semantic content similarity
  /// from the TF-IDF index (weighted highest, so quotes that *say* something
  /// alike surface even across authors and tags), plus the original heuristics
  /// of +2 per shared tag and +3 for the same author. The quote itself and
  /// anything scoring zero are excluded.
  List<Quote> similar(Quote quote, {int limit = 12}) {
    final self = _quotes.indexWhere((q) => q.id == quote.id);
    final index = _index;

    final scored = <({Quote quote, double score})>[];
    for (var i = 0; i < _quotes.length; i++) {
      final other = _quotes[i];
      if (other.id == quote.id) continue;

      var score = 0.0;
      if (index != null && self >= 0) {
        score += 5 * index.similarity(self, i);
      }
      for (final tag in other.tags) {
        if (quote.tags.contains(tag)) score += 2;
      }
      if (other.author == quote.author) score += 3;

      if (score > 0) scored.add((quote: other, score: score));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).map((e) => e.quote).toList(growable: false);
  }

  /// Personalized recommendations built from the user's [favoriteIds].
  ///
  /// For every favorite we pull its semantic neighbors and accumulate a
  /// reciprocal-rank score per candidate, so a quote that ranks highly for
  /// several favorites rises to the top. Favorites themselves are excluded.
  /// Fully offline — it reuses the same TF-IDF similarity as [similar].
  List<Quote> recommendations(List<String> favoriteIds, {int limit = 20}) {
    final favSet = favoriteIds.toSet();
    final favorites = byIds(favoriteIds);
    if (favorites.isEmpty) return const [];

    final scores = <String, double>{};
    for (final fav in favorites) {
      final neighbors = similar(fav, limit: 15);
      for (var i = 0; i < neighbors.length; i++) {
        final candidate = neighbors[i];
        if (favSet.contains(candidate.id)) continue;
        scores[candidate.id] = (scores[candidate.id] ?? 0) + 1.0 / (i + 1);
      }
    }

    final byId = {for (final q in _quotes) q.id: q};
    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ranked
        .take(limit)
        .map((e) => byId[e.key])
        .whereType<Quote>()
        .toList(growable: false);
  }

  /// Resolves stored favorite ids back to full quotes, preserving order.
  List<Quote> byIds(List<String> ids) {
    final index = {for (final q in _quotes) q.id: q};
    return ids
        .map((id) => index[id])
        .whereType<Quote>()
        .toList(growable: false);
  }

  /// Whether [quote] belongs to the requested [language], using script
  /// detection on its content (Arabic is right-to-left, English is not).
  static bool _matchesLanguage(QuoteLanguage language, Quote quote) {
    switch (language) {
      case QuoteLanguage.all:
        return true;
      case QuoteLanguage.arabic:
        return isRtl(quote.content);
      case QuoteLanguage.english:
        return !isRtl(quote.content);
    }
  }

  static String _humanize(String slug) {
    if (slug.isEmpty) return slug;
    return slug
        .split(RegExp(r'[-_\s]+'))
        .map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }
}
