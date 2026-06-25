import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/quote_repository.dart';
import '../../../shared/widgets/quote_card.dart';
import '../../../shared/widgets/status_view.dart';
import '../../search/quote_search_delegate.dart';
import '../bloc/feed_bloc.dart';

/// The main, infinitely-scrolling quote feed.
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 300) {
      context.read<FeedBloc>().add(const FeedNextPageRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotes'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: QuoteSearchDelegate(context.read<QuoteRepository>()),
            ),
          ),
        ],
      ),
      body: BlocBuilder<FeedBloc, FeedState>(
        builder: (context, state) {
          switch (state.status) {
            case FeedStatus.initial:
            case FeedStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case FeedStatus.failure:
              return StatusView(
                icon: Icons.error_outline,
                message: state.errorMessage,
                onRetry: () =>
                    context.read<FeedBloc>().add(const FeedRefreshed()),
              );
            case FeedStatus.success:
              if (state.quotes.isEmpty) {
                return const StatusView(
                  icon: Icons.inbox_outlined,
                  message: 'No quotes to show yet.',
                );
              }
              return RefreshIndicator(
                onRefresh: () async =>
                    context.read<FeedBloc>().add(const FeedRefreshed()),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: state.hasReachedMax
                      ? state.quotes.length
                      : state.quotes.length + 1,
                  itemBuilder: (context, index) {
                    if (index >= state.quotes.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return QuoteCard(quote: state.quotes[index]);
                  },
                ),
              );
          }
        },
      ),
    );
  }
}
