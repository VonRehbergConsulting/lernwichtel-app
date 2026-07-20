import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'responsive.dart';

/// Bevorzugte Ausrichtungen je Geräteklasse – **eine** Quelle der Wahrheit für
/// die App-Start-Ausrichtung, [OrientationLock] und das Vollbild-Malen.
List<DeviceOrientation> preferredOrientationsFor({required bool tablet}) =>
    tablet
    ? const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
    : const [DeviceOrientation.portraitUp];

/// Geräteklasse aus der **physischen** Bildschirmgröße (drehstabil) – nutzbar
/// schon vor dem ersten Frame bzw. ohne `BuildContext`. Liefert bei noch
/// unbekannter Größe (0) `false`.
bool primaryViewIsTablet() {
  final views = WidgetsBinding.instance.platformDispatcher.views;
  if (views.isEmpty) return false;
  final view = views.first;
  final shortest = view.physicalSize.shortestSide / view.devicePixelRatio;
  return shortest >= Breakpoints.tabletShortestSide;
}

/// Sperrt die Bildschirm-Ausrichtung je Geräteklasse:
///
/// - **Handy** → nur **Hochformat**. So hat die Tastatur vertikal Platz und der
///   Inhalt wird nicht mehr im engen Querformat zusammengedrückt.
/// - **Tablet** → nur **Querformat**. Passt zu den zweispaltigen, iPad-first
///   gedachten Layouts (Lektionen, Übungen).
///
/// Die Entscheidung fällt anhand der **kürzesten Bildschirmkante** – die bleibt
/// beim Drehen stabil, sodass keine Rückkopplung entsteht. Das Widget wird hoch
/// im Baum (unter `MaterialApp`) platziert und reicht sein [child] unverändert
/// durch; es rendert selbst nichts.
class OrientationLock extends StatefulWidget {
  const OrientationLock({super.key, required this.child});

  final Widget child;

  @override
  State<OrientationLock> createState() => _OrientationLockState();
}

class _OrientationLockState extends State<OrientationLock> {
  bool? _tablet;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tablet = context.isTablet;
    if (tablet == _tablet) return;
    _tablet = tablet;
    SystemChrome.setPreferredOrientations(
      preferredOrientationsFor(tablet: tablet),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
