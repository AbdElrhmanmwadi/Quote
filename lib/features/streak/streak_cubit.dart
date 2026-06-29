import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/storage/preferences_service.dart';

/// Tracks how many consecutive days the user has opened the app.
///
/// The streak grows by one when the app is opened on the day after the last
/// open, holds steady on same-day reopens, and resets to one after any gap.
/// State is simply the current streak length.
class StreakCubit extends Cubit<int> {
  StreakCubit(this._prefs) : super(_prefs.streakCount) {
    _recordOpen();
  }

  final PreferencesService _prefs;

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<void> _recordOpen() async {
    final today = _dateOnly(DateTime.now());
    final last = _prefs.streakLastOpen;

    int next;
    if (last == null) {
      next = 1;
    } else {
      final lastDay = _dateOnly(last);
      final gap = today.difference(lastDay).inDays;
      if (gap == 0) {
        next = state == 0 ? 1 : state;
      } else if (gap == 1) {
        next = state + 1;
      } else {
        next = 1;
      }
    }

    await _prefs.setStreakCount(next);
    await _prefs.setStreakLastOpen(today);
    emit(next);
  }
}
