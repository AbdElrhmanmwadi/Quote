import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/util/quote_language.dart';
import '../../../data/repositories/quote_repository.dart';
import '../../../shared/widgets/quote_card.dart';
import '../../../shared/widgets/status_view.dart';
import '../../recommendations/view/recommendations_screen.dart';
import '../../search/quote_search_delegate.dart';
import '../../settings/view/settings_screen.dart';
import '../../streak/streak_cubit.dart';
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
          BlocBuilder<StreakCubit, int>(
            builder: (context, streak) {
              if (streak <= 0) return const SizedBox.shrink();
              final colors = Theme.of(context).colorScheme;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Center(
                  child: Tooltip(
                    message: '$streak-day streak',
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department,
                            size: 20, color: colors.primary),
                        const SizedBox(width: 2),
                        Text('$streak',
                            style: TextStyle(
                                color: colors.primary,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'For You',
            icon: const Icon(Icons.auto_awesome_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => const RecommendationsScreen()),
            ),
          ),
          BlocBuilder<FeedBloc, FeedState>(
            buildWhen: (prev, curr) => prev.language != curr.language,
            builder: (context, state) => PopupMenuButton<QuoteLanguage>(
              tooltip: 'Language',
              icon: Icon(
                Icons.translate,
                color: state.language == QuoteLanguage.all
                    ? null
                    : Theme.of(context).colorScheme.primary,
              ),
              initialValue: state.language,
              onSelected: (language) =>
                  context.read<FeedBloc>().add(FeedLanguageChanged(language)),
              itemBuilder: (context) => [
                for (final language in QuoteLanguage.values)
                  CheckedPopupMenuItem(
                    value: language,
                    checked: language == state.language,
                    child: Text(language.label),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () => showSearch(
              context: context,
              delegate: QuoteSearchDelegate(context.read<QuoteRepository>()),
            ),
          ),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
