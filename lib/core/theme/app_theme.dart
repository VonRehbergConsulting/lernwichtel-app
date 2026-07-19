import 'package:flutter/material.dart';

/// Kindgerechtes, ruhiges Theme – jetzt wärmer und einladender: freundliche
/// runde Schrift (Baloo 2), warme Farbwelt, sanfte Tiefe auf Karten/Kacheln.
/// Bewusst weiterhin wenige Ablenkungen. Die generierten Bilder bleiben Star.
class AppTheme {
  static const _font = 'Baloo2';

  /// Warmes Korall-Orange als Grundton (statt kühlem Blau).
  static const seed = Color(0xFFF07A54);

  /// Warmer, heller Hintergrund – freundlich statt klinisch.
  static const cream = Color(0xFFFFF8EF);

  /// Weiche Kachel-/Karten-Schatten (dezent, ~13 % Schwarz).
  static const _shadow = Color(0x22000000);

  static ThemeData light() => _base(
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
      );

  static ThemeData dark() => _base(
        ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      );

  static ThemeData _base(ColorScheme scheme) {
    final isLight = scheme.brightness == Brightness.light;
    final bg = isLight ? cream : scheme.surface;

    return ThemeData(
      useMaterial3: true,
      fontFamily: _font,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: _font,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: scheme.onSurface,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w800),
        displayMedium: TextStyle(fontWeight: FontWeight.w800),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700),
        headlineSmall: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
      ),
      // Sanfte Tiefe: dezenter Schatten, keine Material-Tönung, runde Ecken.
      cardTheme: CardThemeData(
        elevation: 3,
        shadowColor: _shadow,
        surfaceTintColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(26)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(88, 60),
          textStyle: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(72, 52),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      dialogTheme: DialogThemeData(
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
    );
  }
}
