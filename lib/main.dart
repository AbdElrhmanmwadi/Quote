import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app.dart';
import 'core/observer/app_bloc_observer.dart';
import 'core/services/notification_service.dart';
import 'core/services/widget_service.dart';
import 'core/storage/preferences_service.dart';
import 'data/repositories/quote_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();

  final prefs = await PreferencesService.create();
  final repository = QuoteRepository();
  await repository.ensureLoaded();

  final notifications = NotificationService(repository);
  final widgets = WidgetService(repository);

  // Re-arm the daily reminder and refresh the home-screen widget on launch.
  // Both are best-effort and must never block or crash startup.
  unawaitedSafe(() async {
    await notifications.init();
    if (prefs.notificationsEnabled) {
      await notifications.scheduleDaily(
        prefs.notificationHour,
        prefs.notificationMinute,
      );
    }
  });
  unawaitedSafe(widgets.refresh);

  runApp(QuoteApp(
    prefs: prefs,
    repository: repository,
    notifications: notifications,
    widgets: widgets,
  ));
}

/// Runs a fire-and-forget async task, swallowing any error so a failing
/// best-effort side task can never take down the app.
void unawaitedSafe(Future<void> Function() task) {
  Future(() async {
    try {
      await task();
    } catch (_) {
      // best-effort
    }
  });
}
