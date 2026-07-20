import 'package:flutter/material.dart';

import '../responsive.dart';

/// Anordnung für einfache Auswahl-Menüs (Eltern-Bereich, Kind-Start, Ziffern):
///
/// - **Handy (hoch):** volle **Zeilen** untereinander (breit-flache Zellen –
///   [MenuTile] rendert dann automatisch Icon links, Text rechts). Große, gut
///   treffbare Flächen statt gequetschter Mini-Kacheln.
/// - **Tablet (quer):** klassisches **Raster** mit [crossAxisCount] Spalten.
///
/// Erwartet [MenuTile]s (oder ähnlich zell-adaptive Kacheln) als [children].
class TileMenu extends StatelessWidget {
  const TileMenu({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.rowHeight = 108,
    this.tabletAspectRatio = 1.0,
  });

  final List<Widget> children;

  /// Spaltenzahl im Tablet-Raster.
  final int crossAxisCount;

  /// Höhe einer Zeile im Hochformat.
  final double rowHeight;

  /// Seitenverhältnis der Zellen im Tablet-Raster.
  final double tabletAspectRatio;

  @override
  Widget build(BuildContext context) {
    if (context.isCompact) {
      return ListView.separated(
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => SizedBox(height: rowHeight, child: children[i]),
      );
    }
    return GridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      childAspectRatio: tabletAspectRatio,
      children: children,
    );
  }
}
