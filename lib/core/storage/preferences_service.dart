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

  bool get onboardingComplete => _prefs.getBool(_kOnboardingComplete) ?? false;
  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(_kOnboardingComplete, value);

  /// Tag slugs the user picked during onboarding (empty == "all topics").
  List<String> get selectedTags => _prefs.getStringList(_kSelectedTags) ?? const [];
  Future<void> setSelectedTags(List<String> slugs) =>
      _prefs.setStringList(_kSelectedTags, slugs);

  /// Ids of quotes the user marked as favorite.
  List<String> get favoriteIds => _prefs.getStringList(_kFavoriteIds) ?? const [];
  Future<void> setFavoriteIds(List<String> ids) =>
      _prefs.setStringList(_kFavoriteIds, ids);

  DateTime? get lastDailyQuoteDate {
    final raw = _prefs.getString(_kLastDailyQuoteDate);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> setLastDailyQuoteDate(DateTime date) =>
      _prefs.setString(_kLastDailyQuoteDate, date.toIso8601String());
}
