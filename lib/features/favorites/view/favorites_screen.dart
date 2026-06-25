import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/quote_repository.dart';
import '../../../shared/widgets/quote_card.dart';
import '../../../shared/widgets/status_view.dart';
import '../cubit/favorites_cubit.dart';

/// Lists the quotes the user has favorited.
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<QuoteRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return const StatusView(
              icon: Icons.favorite_border,
              message: 'Tap the heart on any quote to save it here.',
            );
          }
          final quotes = repository.byIds(state.ids.toList());
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: quotes.length,
            itemBuilder: (context, index) => QuoteCard(quote: quotes[index]),
          );
        },
      ),
    );
  }
}
