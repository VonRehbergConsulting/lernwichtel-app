import 'package:flutter/material.dart';

/// Zeigt ein generiertes Menue-Icon (`assets/images/menu/<id>.webp`). Fehlt die
/// Datei, wird das Emoji als Fallback angezeigt – so laeuft die App auch, bevor
/// die Icon-Pipeline gelaufen ist.
class MenuIcon extends StatelessWidget {
  const MenuIcon({
    super.key,
    required this.id,
    required this.emoji,
    this.size = 72,
  });

  final String id;
  final String emoji;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/menu/$id.webp',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stack) =>
          Text(emoji, style: TextStyle(fontSize: size * 0.85)),
    );
  }
}
