import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/storage/preferences_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/quote_repository.dart';
import 'features/favorites/cubit/favorites_cubit.dart';
import 'features/feed/bloc/feed_bloc.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/random/cubit/random_cubit.dart';
import 'features/settings/cubit/theme_cubit.dart';
import 'shell/home_shell.dart';

/// Root widget. Provides app-wide singletons (repository, preferences) and all
/// blocs/cubits above [MaterialApp], so every screen — including pushed routes
/// like Settings — can read them. Routes to onboarding or the home shell.
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
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit(prefs)),
          BlocProvider(create: (_) => FavoritesCubit(prefs)),
          BlocProvider(
            create: (_) => FeedBloc(repository: repository, prefs: prefs)
              ..add(const FeedRefreshed()),
          ),
          BlocProvider(create: (_) => RandomCubit(repository)..shuffle()),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) {
            return MaterialApp(
              title: 'Quotes',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              darkTheme: AppTheme.dark(),
              themeMode: themeMode,
              home: prefs.onboardingComplete
                  ? const HomeShell()
                  : const OnboardingScreen(),
            );
          },
        ),
      ),
    );
  }
}
