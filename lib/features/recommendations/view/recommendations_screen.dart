import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/quote_repository.dart';
import '../../../shared/widgets/quote_card.dart';
import '../../../shared/widgets/status_view.dart';
import '../../favorites/cubit/favorites_cubit.dart';

/// "For You" — quotes recommended from what the user has favorited.
///
/// Recommendations are computed offline by [QuoteRepository.recommendations]
/// (semantic neighbors of your favorites), so this stays private and needs no
/// network.
class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = context.read<QuoteRepository>();
    return Scaffold(
      appBar: AppBar(title: const Text('For You')),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          final recommendations = repository.recommendations(state.ids.toList());
          if (recommendations.isEmpty) {
            return const StatusView(
              icon: Icons.auto_awesome_outlined,
              message: 'Favorite a few quotes and we’ll suggest more like them.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: recommendations.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return const _Header();
              return QuoteCard(quote: recommendations[index - 1]);
            },
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Row(
        children: [
          Icon(Icons.auto_awesome, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              'Because you liked what you saved',
              style: theme.textTheme.labelLarge
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}
