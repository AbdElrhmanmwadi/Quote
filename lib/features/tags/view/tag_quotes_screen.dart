import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/quote_repository.dart';
import '../../../shared/widgets/quote_card.dart';
import '../../../shared/widgets/status_view.dart';

/// Lists every quote carrying a given tag. Opened by tapping a tag chip.
class TagQuotesScreen extends StatelessWidget {
  const TagQuotesScreen({super.key, required this.slug, required this.label});

  final String slug;
  final String label;

  @override
  Widget build(BuildContext context) {
    final quotes = context.read<QuoteRepository>().byTag(slug);
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: quotes.isEmpty
          ? const StatusView(
              icon: Icons.inbox_outlined,
              message: 'No quotes for this topic.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: quotes.length,
              itemBuilder: (context, index) => QuoteCard(quote: quotes[index]),
            ),
    );
  }
}
