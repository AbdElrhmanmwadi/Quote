import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/preferences_service.dart';

/// Holds the active [ThemeMode] and persists changes.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_prefs.themeMode);

  final PreferencesService _prefs;

  Future<void> setMode(ThemeMode mode) async {
    if (mode == state) return;
    emit(mode);
    await _prefs.setThemeMode(mode);
  }
}
