import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/storage/preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/quote_repository.dart';
import 'features/favorites/cubit/favorites_cubit.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'shell/home_shell.dart';

/// Root widget. Provides app-wide singletons (repository, preferences) and the
/// global [FavoritesCubit], then routes to onboarding or the home shell.
class QuoteApp extends StatelessWidget {
  const QuoteApp({super.key, required this.prefs, required this.repository});

  final PreferencesService prefs;
  final QuoteRepository repository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: repository),
        RepositoryProvider.value(value: prefs),
      ],
      child: BlocProvider(
        create: (_) => FavoritesCubit(prefs),
        child: MaterialApp(
          title: 'Quotes',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.system,
          home: prefs.onboardingComplete
              ? const HomeShell()
              : const OnboardingScreen(),
        ),
      ),
    );
  }
}
