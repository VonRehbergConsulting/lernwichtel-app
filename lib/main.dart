import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/app_bloc_observer.dart';
import 'core/app_info.dart';
import 'core/di/service_locator.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/root_page.dart';

Future<void> main() async {
  // Alle (auch asynchronen) Fehler landen zentral im Log.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        developer.log('Flutter-Fehler',
            name: 'flutter',
            error: details.exception,
            stackTrace: details.stack);
      };
      Bloc.observer = const AppBlocObserver();

      // Tablet-App: Querformat ist die primaere Ausrichtung.
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);

      await setupServiceLocator();
      runApp(const EducationApp());
    },
    (error, stack) => developer.log('Unbehandelter Fehler',
        name: 'zone', error: error, stackTrace: stack),
  );
}

class EducationApp extends StatelessWidget {
  const EducationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      // Bewusst immer hell/farbenfroh – unabhaengig vom Dark Mode des Geraets.
      themeMode: ThemeMode.light,
      home: const RootPage(),
    );
  }
}
