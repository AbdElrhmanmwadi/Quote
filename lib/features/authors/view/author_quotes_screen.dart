import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/util/bidi.dart';
import '../../../data/repositories/quote_repository.dart';
import '../../../shared/widgets/quote_card.dart';
import '../../../shared/widgets/status_view.dart';

/// Lists every quote by a given author. Opened by tapping an author's name.
class AuthorQuotesScreen extends StatelessWidget {
  const AuthorQuotesScreen({super.key, required this.author});

  final String author;

  @override
  Widget build(BuildContext context) {
    final quotes = context.read<QuoteRepository>().byAuthor(author);
    return Scaffold(
      // Match the author name's own script direction (Arabic name → RTL title).
      appBar: AppBar(
        title: Directionality(
          textDirection: directionOf(author),
          child: Text(author),
        ),
      ),
      body: quotes.isEmpty
          ? const StatusView(
              icon: Icons.person_outline,
              message: 'No quotes by this author.',
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: quotes.length,
              itemBuilder: (context, index) => QuoteCard(quote: quotes[index]),
            ),
    );
  }
}
