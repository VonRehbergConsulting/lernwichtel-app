import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

/// Zentrales Logging fuer alle Bloc-Fehler. In main als `Bloc.observer` gesetzt.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    developer.log(
      'Bloc-Fehler in ${bloc.runtimeType}',
      name: 'bloc',
      error: error,
      stackTrace: stackTrace,
    );
    super.onError(bloc, error, stackTrace);
  }
}
