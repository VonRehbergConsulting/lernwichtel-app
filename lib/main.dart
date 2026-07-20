import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/app_bloc_observer.dart';
import 'core/app_info.dart';
import 'core/di/service_locator.dart';
import 'core/orientation_lock.dart';
import 'core/responsive.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/root_page.dart';

Future<void> main() async {
  // Alle (auch asynchronen) Fehler landen zentral im Log.
  unawaited(runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        developer.log('Flutter-Fehler',
            name: 'flutter',
            error: details.exception,
            stackTrace: details.stack);
      };
      Bloc.observer = const AppBlocObserver();

      // Ausrichtung pro Geraeteklasse: Handy=Hochformat, Tablet=Querformat.
      // Hier nur ein Best-Effort-Startwert aus der physischen Bildschirmgroesse
      // (gegen Flackern beim Start); die endgueltige Sperre uebernimmt reaktiv
      // OrientationLock, sobald eine MediaQuery vorliegt. Ist die Groesse noch
      // unbekannt (0), starten wir tablet-first im Querformat.
      final view = WidgetsBinding.instance.platformDispatcher.views.first;
      final shortestSide =
          view.physicalSize.shortestSide / view.devicePixelRatio;
      // Bei noch unbekannter Groesse (0) tablet-first (Querformat), damit auf
      // Tablets kein kurzes Hochformat aufblitzt.
      final startsAsTablet =
          shortestSide == 0 || shortestSide >= Breakpoints.tabletShortestSide;
      await SystemChrome.setPreferredOrientations(
        preferredOrientationsFor(tablet: startsAsTablet),
      );

      await setupServiceLocator();
      runApp(const EducationApp());
    },
    (error, stack) => developer.log('Unbehandelter Fehler',
        name: 'zone', error: error, stackTrace: stack),
  ));
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
      home: const OrientationLock(child: RootPage()),
    );
  }
}
