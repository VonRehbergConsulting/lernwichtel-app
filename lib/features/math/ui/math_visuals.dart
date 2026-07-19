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
      return const Text('0',
          style: TextStyle(fontSize: 72, fontWeight: FontWeight.w800));
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

/// Zahl als Zehner-Bündel (Zehnerrahmen) + einzelne Einer – mit großen Punkten
/// zum Mit-dem-Finger-Nachzählen.
class TensOnesView extends StatelessWidget {
  const TensOnesView({super.key, required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    final tens = value ~/ 10;
    final ones = value % 10;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 16,
      children: [
        for (var t = 0; t < tens; t++) const _TenFrame(),
        if (ones > 0) _dotRows(ones, _dot),
      ],
    );
  }
}

/// Ein Zehner: voller Zehnerrahmen (2 Reihen × 5) mit großen Punkten.
class _TenFrame extends StatelessWidget {
  const _TenFrame();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0x224FC3F7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: _dotRows(10, _tenDot),
    );
  }
}

/// Große Punkte in Reihen zu je fünf – leicht mit dem Finger nachzuzählen.
Widget _dotRows(int count, Color color, {int perRow = 5}) {
  const dotSize = 30.0;
  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var start = 0; start < count; start += perRow)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = start; i < start + perRow && i < count; i++)
              Container(
                width: dotSize,
                height: dotSize,
                margin: const EdgeInsets.all(5),
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle),
              ),
          ],
        ),
    ],
  );
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
