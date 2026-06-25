import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

/// Logs bloc lifecycle and errors during development.
///
/// Uses `dart:developer` logging instead of `print`, so output is structured
/// and automatically stripped from release builds.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    developer.log('$change', name: bloc.runtimeType.toString());
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    developer.log(
      'error',
      name: bloc.runtimeType.toString(),
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
