import 'package:flutter/material.dart';

import '../../core/util/bidi.dart';
import '../../core/util/quote_language.dart';
import '../../data/models/quote.dart';
import '../../data/repositories/quote_repository.dart';
import '../../shared/widgets/quote_card.dart';
import '../../shared/widgets/status_view.dart';

/// Searches the offline dataset and highlights the matched term.
///
/// Ranking is meaning-aware (see [QuoteRepository.smartSearch]): exact matches
/// first, then semantically related quotes from the offline TF-IDF index — so
/// "overcoming fear" also surfaces quotes about courage. Because the repository
/// is in-memory, results are synchronous and instant — no `FutureBuilder` or
/// network round-trip per keystroke.
class QuoteSearchDelegate extends SearchDelegate<Quote?> {
  QuoteSearchDelegate(this._repository);

  final QuoteRepository _repository;

  /// Language filter for results. A [ValueNotifier] so the results rebuild
  /// immediately when it changes (SearchDelegate has no setState of its own).
  final ValueNotifier<QuoteLanguage> _language =
      ValueNotifier(QuoteLanguage.all);

  @override
  List<Widget> buildActions(BuildContext context) => [
        ValueListenableBuilder<QuoteLanguage>(
          valueListenable: _language,
          builder: (context, language, _) => PopupMenuButton<QuoteLanguage>(
            tooltip: 'Language',
            icon: Icon(
              Icons.translate,
              color: language == QuoteLanguage.all
                  ? null
                  : Theme.of(context).colorScheme.primary,
            ),
            initialValue: language,
            onSelected: (value) => _language.value = value,
            itemBuilder: (context) => [
              for (final option in QuoteLanguage.values)
                CheckedPopupMenuItem(
                  value: option,
                  checked: option == language,
                  child: Text(option.label),
                ),
            ],
          ),
        ),
        if (query.isNotEmpty)
          IconButton(
            tooltip: 'Clear',
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  @override
  Widget buildResults(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    if (query.trim().isEmpty) {
      return const StatusView(
        icon: Icons.search,
        message: 'Search quotes by word or author.',
      );
    }
    return ValueListenableBuilder<QuoteLanguage>(
      valueListenable: _language,
      builder: (context, language, _) {
        final results = _repository
            .smartSearch(query)
            .where((q) => _matchesLanguage(language, q))
            .toList(growable: false);
        if (results.isEmpty) {
          return const StatusView(
            icon: Icons.search_off,
            message: 'No quotes matched your search.',
          );
        }
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final quote = results[index];
            return QuoteCard(
              quote: quote,
              highlighted: _highlight(context, quote.content, query),
            );
          },
        );
      },
    );
  }

  static bool _matchesLanguage(QuoteLanguage language, Quote quote) =>
      switch (language) {
        QuoteLanguage.all => true,
        QuoteLanguage.arabic => isRtl(quote.content),
        QuoteLanguage.english => !isRtl(quote.content),
      };

  TextSpan _highlight(BuildContext context, String content, String term) {
    final base = TextStyle(color: Theme.of(context).colorScheme.onSurface);
    final match = term.trim().toLowerCase();
    if (match.isEmpty) return TextSpan(text: content, style: base);

    final spans = <TextSpan>[];
    final lower = content.toLowerCase();
    var start = 0;
    while (start < content.length) {
      final index = lower.indexOf(match, start);
      if (index < 0) {
        spans.add(TextSpan(text: content.substring(start), style: base));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: content.substring(start, index), style: base));
      }
      final end = index + match.length;
      spans.add(TextSpan(
        text: content.substring(index, end),
        style: base.copyWith(
          fontWeight: FontWeight.w700,
          color: Theme.of(context).colorScheme.primary,
        ),
      ));
      start = end;
    }
    return TextSpan(children: spans);
  }
}
