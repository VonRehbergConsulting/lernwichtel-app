import 'package:flutter/material.dart';

const _dot = Color(0xFFFF8A65);
const _tenDot = Color(0xFF4FC3F7);

/// Ein einzelnes Zaehl-Objekt (generiertes Wortbild). Fehlt das Bild, greift
/// ein Emoji-Fallback.
class ObjectTile extends StatelessWidget {
  const ObjectTile({super.key, required this.slug, this.size = 56});
  final String slug;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/images/standard/$slug.webp',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) =>
            Text('🍎', style: TextStyle(fontSize: size * 0.8)),
      ),
    );
  }
}

/// Eine Menge gleicher Zaehl-Objekte zum Abzählen.
class ObjectsView extends StatelessWidget {
  const ObjectsView({
    super.key,
    required this.count,
    required this.slug,
    this.itemSize = 60,
  });
  final int count;
  final String slug;
  final double itemSize;

  @override
  Widget build(BuildContext context) {
    if (count == 0) {
      return const Text(
        '0',
        style: TextStyle(fontSize: 72, fontWeight: FontWeight.w800),
      );
    }
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (var i = 0; i < count; i++) ObjectTile(slug: slug, size: itemSize),
      ],
    );
  }
}

/// Zahl als **Zehner-Stangen** (Montessori-Prinzip): jede volle Zehnerstange ist
/// eine senkrechte Spalte aus 10 Perlen (5 + 5 mit kleiner Lücke, damit man sie
/// auf einen Blick als „zehn" erkennt); die Einer bilden eine kürzere Spalte
/// daneben. Die Spalten stehen wie auf einer Grundlinie nebeneinander – das
/// bleibt bis 100 kompakt (≈ quadratisch statt einer langen Punktewand) und ist
/// gut mit dem Finger abzuzählen.
class TensOnesView extends StatelessWidget {
  const TensOnesView({super.key, required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    final tens = value ~/ 10;
    final ones = value % 10;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (var t = 0; t < tens; t++)
          const _BeadRod(count: 10, color: _tenDot),
        if (ones > 0) _BeadRod(count: ones, color: _dot),
      ],
    );
  }
}

/// Eine senkrechte Perlen-Spalte (Stange). Nach der fünften Perle eine kleine
/// Lücke, damit auch zehn Perlen leicht zu zählen sind.
class _BeadRod extends StatelessWidget {
  const _BeadRod({required this.count, required this.color});
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const bead = 26.0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++) ...[
            if (i == 5) const SizedBox(height: 10),
            Container(
              width: bead,
              height: bead,
              margin: const EdgeInsets.symmetric(vertical: 3),
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
        ],
      ),
    );
  }
}

/// Objekt-Reihe für kleine Operanden (Plus/Minus anschaulich).
class OperandObjects extends StatelessWidget {
  const OperandObjects({super.key, required this.count, required this.slug});
  final int count;
  final String slug;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 5,
      runSpacing: 5,
      children: [
        for (var i = 0; i < count; i++) ObjectTile(slug: slug, size: 34),
      ],
    );
  }
}
