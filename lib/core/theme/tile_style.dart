import 'package:flutter/material.dart';

/// Gemeinsame Optik für alle Kacheln der App: kräftiger Diagonal-Verlauf
/// (heller oben, satter unten), runde Ecken und ein weicher, farbiger Schatten.
/// So sehen Auswahl-, Buchstaben-, Zahlen- und Lektions-Kacheln einheitlich aus.
class TileStyle {
  /// Warme, dunkle Schrift auf farbigen Kacheln (statt hartem Schwarz).
  static const ink = Color(0xFF3A2E28);

  /// [depth] skaliert den Schatten (1.0 = große Kachel, ~0.6 = kleine Kachel).
  static BoxDecoration surface(
    Color color, {
    bool locked = false,
    double radius = 24,
    double depth = 1.0,
    Border? border,
  }) {
    final base = locked
        ? Color.lerp(color, const Color(0xFFBFB6AC), 0.55)!
        : color;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.lerp(base, Colors.white, 0.40)!,
          Color.lerp(base, Colors.black, 0.17)!,
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: border,
      boxShadow: [
        BoxShadow(
          color: base.withValues(alpha: 0.38),
          blurRadius: 18 * depth,
          spreadRadius: -6 * depth,
          offset: Offset(0, 9 * depth),
        ),
      ],
    );
  }
}
