import 'package:flutter/material.dart';

import '../../../core/theme/tile_style.dart';

/// Grosser Ziffern-Nummernblock (0–9, Löschen, Prüfen). Beim Eintippen üben
/// die Kinder gleich das Erkennen der Ziffern mit.
class NumberPad extends StatelessWidget {
  const NumberPad({
    super.key,
    required this.enabled,
    required this.onDigit,
    required this.onBackspace,
    required this.onSubmit,
  });

  final bool enabled;
  final void Function(int digit) onDigit;
  final VoidCallback onBackspace;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final row in const [
            [1, 2, 3],
            [4, 5, 6],
            [7, 8, 9],
          ])
            Row(
              children: [
                for (final d in row) _key(context, label: '$d', onTap: () => onDigit(d)),
              ],
            ),
          Row(
            children: [
              _key(
                context,
                icon: Icons.backspace_outlined,
                color: const Color(0xFFFFCC80),
                onTap: onBackspace,
              ),
              _key(context, label: '0', onTap: () => onDigit(0)),
              _key(
                context,
                icon: Icons.check,
                color: const Color(0xFFA5D6A7),
                onTap: onSubmit,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _key(
    BuildContext context, {
    String? label,
    IconData? icon,
    Color? color,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: AspectRatio(
          aspectRatio: 1.4,
          child: DecoratedBox(
            decoration: enabled
                ? TileStyle.surface(color ?? scheme.primaryContainer,
                    radius: 18, depth: 0.45)
                : BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(18),
                  ),
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: enabled ? onTap : null,
                child: Center(
                  child: icon != null
                      ? Icon(icon, size: 34, color: TileStyle.ink)
                      : Text(
                          label!,
                          style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                            color: TileStyle.ink,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
