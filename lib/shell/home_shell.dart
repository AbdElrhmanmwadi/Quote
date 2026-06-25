import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/storage/preferences_service.dart';
import '../data/repositories/quote_repository.dart';
import '../features/favorites/view/favorites_screen.dart';
import '../features/feed/view/feed_screen.dart';
import '../features/random/view/random_screen.dart';
import '../shared/widgets/daily_quote_dialog.dart';

/// Top-level shell hosting the three main destinations behind a Material 3
/// [NavigationBar]. Each tab keeps its state via [IndexedStack].
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      DailyQuote.maybeShow(
        context,
        repository: context.read<QuoteRepository>(),
        prefs: context.read<PreferencesService>(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          FeedScreen(),
          RandomScreen(),
          FavoritesScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.format_quote_outlined),
            selectedIcon: Icon(Icons.format_quote),
            label: 'Quotes',
          ),
          NavigationDestination(
            icon: Icon(Icons.shuffle_outlined),
            selectedIcon: Icon(Icons.shuffle),
            label: 'Random',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
