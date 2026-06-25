import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/observer/app_bloc_observer.dart';
import 'core/storage/preferences_service.dart';
import 'data/repositories/quote_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();

  final prefs = await PreferencesService.create();
  final repository = QuoteRepository();
  await repository.ensureLoaded();

  runApp(QuoteApp(prefs: prefs, repository: repository));
}
