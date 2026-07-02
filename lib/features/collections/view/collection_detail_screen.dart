import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/collection.dart';
import '../../../data/repositories/quote_repository.dart';
import '../../../shared/widgets/quote_card.dart';
import '../../../shared/widgets/status_view.dart';
import '../cubit/collections_cubit.dart';

/// Shows every quote inside a single collection. Stays live as the user adds or
/// removes quotes elsewhere by reading the collection back from the cubit.
class CollectionDetailScreen extends StatelessWidget {
  const CollectionDetailScreen({super.key, required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<QuoteRepository>();
    return BlocBuilder<CollectionsCubit, CollectionsState>(
      builder: (context, state) {
        final collection = state.collections.firstWhere(
          (c) => c.name == name,
          orElse: () => Collection(name: name),
        );
        final quotes = repository.byIds(collection.quoteIds);
        return Scaffold(
          appBar: AppBar(title: Text(name)),
          body: quotes.isEmpty
              ? const StatusView(
                  icon: Icons.collections_bookmark_outlined,
                  message: 'This collection is empty.\n\n'
                      'Open any quote, tap the ⋯ (More) button under it, '
                      'then choose “Add to collection”.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: quotes.length,
                  itemBuilder: (context, index) =>
                      QuoteCard(quote: quotes[index]),
                ),
        );
      },
    );
  }
}
