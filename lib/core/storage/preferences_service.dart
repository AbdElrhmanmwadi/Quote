import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

/// Thin, strongly-typed wrapper around [SharedPreferences].
///
/// Replaces the previous singleton that exposed a generic, bool-only API.
/// Every persisted value now has a named, intention-revealing accessor, which
/// keeps storage keys in one place and avoids stringly-typed access scattered
/// across the app.
class PreferencesService {
  PreferencesService(this._prefs);

  final SharedPreferences _prefs;

  /// Loads the underlying [SharedPreferences] instance. Call once at startup.
  static Future<PreferencesService> create() async {
    return PreferencesService(await SharedPreferences.getInstance());
  }

  static const _kOnboardingComplete = 'onboarding_complete';
  static const _kSelectedTags = 'selected_tags';
  static const _kFavoriteIds = 'favorite_ids';
  static const _kLastDailyQuoteDate = 'last_daily_quote_date';
  static const _kThemeMode = 'theme_mode';
  static const _kCollections = 'collections';
  static const _kNotificationsEnabled = 'notifications_enabled';
  static const _kNotificationHour = 'notification_hour';
  static const _kNotificationMinute = 'notification_minute';
  static const _kStreakCount = 'streak_count';
  static const _kStreakLastOpen = 'streak_last_open';

  bool get onboardingComplete => _prefs.getBool(_kOnboardingComplete) ?? false;
  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_kOnboardingComplete, value);

  /// Tag slugs the user picked during onboarding (empty == "all topics").
  List<String> get selectedTags =>
      _prefs.getStringList(_kSelectedTags) ?? const [];
  Future<void> setSelectedTags(List<String> slugs) =>
      _prefs.setStringList(_kSelectedTags, slugs);

  /// Ids of quotes the user marked as favorite.
  List<String> get favoriteIds =>
      _prefs.getStringList(_kFavoriteIds) ?? const [];
  Future<void> setFavoriteIds(List<String> ids) =>
      _prefs.setStringList(_kFavoriteIds, ids);

  DateTime? get lastDailyQuoteDate {
    final raw = _prefs.getString(_kLastDailyQuoteDate);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> setLastDailyQuoteDate(DateTime date) =>
      _prefs.setString(_kLastDailyQuoteDate, date.toIso8601String());

  ThemeMode get themeMode {
    switch (_prefs.getString(_kThemeMode)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(_kThemeMode, mode.name);

  // --- Collections -----------------------------------------------------------

  /// Raw JSON-encoded collections payload (a map of name -> list of quote ids).
  /// Stored as a string so the typed [Collection] model owns (de)serialization.
  String? get collectionsRaw => _prefs.getString(_kCollections);
  Future<void> setCollectionsRaw(String json) =>
      _prefs.setString(_kCollections, json);

  // --- Daily notification ----------------------------------------------------

  bool get notificationsEnabled =>
      _prefs.getBool(_kNotificationsEnabled) ?? false;
  Future<void> setNotificationsEnabled(bool value) =>
      _prefs.setBool(_kNotificationsEnabled, value);

  /// Hour/minute (24h) the daily reminder fires. Defaults to 09:00.
  int get notificationHour => _prefs.getInt(_kNotificationHour) ?? 9;
  int get notificationMinute => _prefs.getInt(_kNotificationMinute) ?? 0;
  Future<void> setNotificationTime(int hour, int minute) async {
    await _prefs.setInt(_kNotificationHour, hour);
    await _prefs.setInt(_kNotificationMinute, minute);
  }

  // --- Reading streak --------------------------------------------------------

  int get streakCount => _prefs.getInt(_kStreakCount) ?? 0;
  Future<void> setStreakCount(int value) =>
      _prefs.setInt(_kStreakCount, value);

  DateTime? get streakLastOpen {
    final raw = _prefs.getString(_kStreakLastOpen);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> setStreakLastOpen(DateTime date) =>
      _prefs.setString(_kStreakLastOpen, date.toIso8601String());
}
