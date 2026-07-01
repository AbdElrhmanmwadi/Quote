import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/quote_repository.dart';
import '../../../shared/widgets/status_view.dart';
import '../../tags/view/tag_quotes_screen.dart';

/// Browse every topic (tag) in the dataset, sorted by popularity. Tapping a
/// topic opens all its quotes.
class TopicsScreen extends StatelessWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tags = context.read<QuoteRepository>().tags();
    return Scaffold(
      appBar: AppBar(title: const Text('Topics')),
      body: tags.isEmpty
          ? const StatusView(
              icon: Icons.category_outlined,
              message: 'No topics available yet.',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final tag in tags)
                    ActionChip(
                      avatar: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        child: Text(
                          '${tag.count}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      label: Text(tag.label),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              TagQuotesScreen(slug: tag.slug, label: tag.label),
                        ),
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
