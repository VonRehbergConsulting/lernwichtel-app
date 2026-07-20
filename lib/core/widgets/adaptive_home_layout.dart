import 'package:flutter/material.dart';

import '../responsive.dart';

/// Layout der Disziplin-Startseiten (Lesen/Rechnen): [sidebar] (Lektions-Karte
/// + Banner) oben, darunter das [grid] mit voller Resthöhe. Bewusst **gestapelt**
/// – sowohl das Handy im Hochformat als auch das Tablet im Querformat fahren
/// damit gut; die Abstände fallen auf schmalen Geräten etwas enger aus.
class AdaptiveHomeLayout extends StatelessWidget {
  const AdaptiveHomeLayout({
    super.key,
    required this.sidebar,
    required this.grid,
  });

  /// Inhalt der Kopfzeile (inkl. eigener Abstände zwischen den Elementen).
  final List<Widget> sidebar;
  final Widget grid;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    return Padding(
      padding: EdgeInsets.all(compact ? 12 : 24),
      child: Column(
        children: [
          ...sidebar,
          SizedBox(height: compact ? 12 : 16),
          Expanded(child: grid),
        ],
      ),
    );
  }
}
