import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../../data/repositories/quote_repository.dart';

/// Wraps `flutter_local_notifications` to deliver one "Quote of the day"
/// notification per day at a user-chosen time.
///
/// Everything is best-effort: on platforms without notification support (or if
/// the user denies permission) the calls degrade quietly so the rest of the app
/// is unaffected.
class NotificationService {
  NotificationService(this._repository);

  final QuoteRepository _repository;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'daily_quote';
  static const _channelName = 'Daily quote';
  static const _notificationId = 1001;

  bool _initialized = false;

  /// Initializes the timezone database and the plugin. Safe to call repeatedly.
  Future<void> init() async {
    if (_initialized) return;
    tzdata.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
    } catch (_) {
      // Keep the default location; scheduling still works, just in UTC.
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);
    await _plugin.initialize(settings);
    _initialized = true;
  }

  /// Asks the OS for permission to post notifications (Android 13+).
  /// Returns true if granted (or not required).
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return true;
    final granted = await android.requestNotificationsPermission();
    return granted ?? true;
  }

  /// Schedules a daily reminder at [hour]:[minute] carrying a random quote.
  Future<void> scheduleDaily(int hour, int minute) async {
    await init();
    await cancel();
    await _repository.ensureLoaded();
    final quote = _repository.randomQuote();

    await _plugin.zonedSchedule(
      _notificationId,
      'Quote of the day',
      quote.shareText,
      _nextInstanceOf(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'A fresh quote every day',
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(quote.shareText),
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Cancels the scheduled daily reminder, if any.
  Future<void> cancel() async {
    await init();
    await _plugin.cancel(_notificationId);
  }

  tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
