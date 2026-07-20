import 'package:flutter/widgets.dart';

/// Zentrale Layout-Schwellen. Die App ist iPad-first (Querformat); Handys
/// laufen im Hochformat. Die Ausrichtung wird pro Geräteklasse gesperrt
/// (siehe `OrientationLock`), die Layouts richten sich nach der Breite.
class Breakpoints {
  const Breakpoints._();

  /// Ab dieser kürzesten Kantenlänge (dp) gilt ein Gerät als **Tablet**
  /// (→ Querformat); darunter als **Handy** (→ Hochformat). Die kürzeste Kante
  /// ist bewusst gewählt, weil sie beim Drehen stabil bleibt. 600 dp ist die
  /// gängige Material-Grenze zwischen Handy und Tablet.
  static const tabletShortestSide = 600.0;

  /// Unter dieser **Breite** (dp) wird einspaltig/kompakt gelayoutet – der
  /// Normalfall auf einem Handy im Hochformat.
  static const compactWidth = 600.0;

  /// Sehr schmale Geräte – für die feinste Stufe.
  static const tinyWidth = 360.0;
}

/// Kleines Responsive-Fundament: statt global herunterzuskalieren richten sich
/// die Screens nach Geräteklasse und verfügbarer Breite.
extension Responsive on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  /// Tablet (kürzeste Kante ≥ 600 dp) vs. Handy – unabhängig von der aktuellen
  /// Drehung, daher stabil für die Ausrichtungs-Sperre.
  bool get isTablet =>
      MediaQuery.sizeOf(this).shortestSide >= Breakpoints.tabletShortestSide;

  /// Schmale Bühne (Handy im Hochformat): einspaltig, kompaktere Maße.
  bool get isCompact =>
      MediaQuery.sizeOf(this).width < Breakpoints.compactWidth;

  bool get isTiny => MediaQuery.sizeOf(this).width < Breakpoints.tinyWidth;

  /// Wählt je nach Breite den kompakten oder den Tablet-Wert.
  T responsive<T>({required T tablet, required T compact}) =>
      isCompact ? compact : tablet;
}
