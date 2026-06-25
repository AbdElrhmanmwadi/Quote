import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/quote.dart';
import '../../../data/repositories/quote_repository.dart';
import '../../../shared/widgets/quote_card.dart';
import '../../../shared/widgets/status_view.dart';
import '../cubit/favorites_cubit.dart';

enum _FavSort { recent, author }

/// Lists favorited quotes with in-place search and sorting.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  String _query = '';
  _FavSort _sort = _FavSort.recent;

  List<Quote> _visible(List<Quote> source) {
    final q = _query.trim().toLowerCase();
    final filtered = q.isEmpty
        ? List<Quote>.from(source)
        : source
            .where((quote) =>
                quote.content.toLowerCase().contains(q) ||
                quote.author.toLowerCase().contains(q))
            .toList();
    if (_sort == _FavSort.author) {
      filtered.sort(
          (a, b) => a.author.toLowerCase().compareTo(b.author.toLowerCase()));
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final repository = context.read<QuoteRepository>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          PopupMenuButton<_FavSort>(
            tooltip: 'Sort',
            icon: const Icon(Icons.sort),
            initialValue: _sort,
            onSelected: (value) => setState(() => _sort = value),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: _FavSort.recent,
                child: Text('Recently added'),
              ),
              PopupMenuItem(
                value: _FavSort.author,
                child: Text('Author (A–Z)'),
              ),
            ],
          ),
        ],
      ),
      body: BlocBuilder<FavoritesCubit, FavoritesState>(
        builder: (context, state) {
          if (state.isEmpty) {
            return const StatusView(
              icon: Icons.favorite_border,
              message: 'Tap the heart on any quote to save it here.',
            );
          }
          // Most-recently-added first (ids are appended on toggle).
          final saved = repository.byIds(state.ids.toList().reversed.toList());
          final quotes = _visible(saved);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: SearchBar(
                  hintText: 'Search favorites',
                  leading: const Icon(Icons.search),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
              Expanded(
                child: quotes.isEmpty
                    ? const StatusView(
                        icon: Icons.search_off,
                        message: 'No favorites match your search.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: quotes.length,
                        itemBuilder: (context, index) =>
                            QuoteCard(quote: quotes[index]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
