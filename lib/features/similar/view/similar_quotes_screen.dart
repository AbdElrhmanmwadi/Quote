import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/quote.dart';
import '../../../data/repositories/quote_repository.dart';
import '../../../shared/widgets/quote_card.dart';
import '../../../shared/widgets/status_view.dart';

/// Shows quotes related to a given one (semantic content + shared tags/author).
class SimilarQuotesScreen extends StatelessWidget {
  const SimilarQuotesScreen({super.key, required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final results = context.read<QuoteRepository>().similar(quote);
    return Scaffold(
      appBar: AppBar(title: const Text('More like this')),
      body: results.isEmpty
          ? const StatusView(
              icon: Icons.search_off,
              message: 'No similar quotes found.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: results.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return _Source(quote: quote);
                return QuoteCard(quote: results[index - 1]);
              },
            ),
    );
  }
}

/// A compact header reminding the user which quote the suggestions relate to.
class _Source extends StatelessWidget {
  const _Source({required this.quote});

  final Quote quote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Because you liked',
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 4),
          Text('"${quote.content}"',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontStyle: FontStyle.italic)),
          const SizedBox(height: 4),
          Text('— ${quote.author}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.primary)),
          const Divider(height: 24),
        ],
      ),
    );
  }
}
