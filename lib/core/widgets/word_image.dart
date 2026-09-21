import 'package:flutter/material.dart';

import '../utils/slug.dart';

/// Inline-Bild zu einem Wort: das generierte Comic-Standardbild
/// (`assets/images/standard/<slug>.webp`). Fehlt die Datei, erscheint ein
/// neutraler Platzhalter mit dem Wort – kein Absturz.
///
/// Anders als [FullscreenImage] ist dies ein normales, einbettbares Bild
/// (z. B. als Karte in den Silben-/Reim-Übungen).
class WordImage extends StatelessWidget {
  const WordImage({
    super.key,
    required this.word,
    this.fit = BoxFit.contain,
    this.showLabel = false,
  });

  final String word;
  final BoxFit fit;

  /// Zeigt das Wort klein unter dem Platzhalter (nur wenn das Bild fehlt).
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/standard/${wortSlug(word)}.webp',
      fit: fit,
      errorBuilder: (context, error, stack) => _Placeholder(word: word),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.word});
  final String word;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🖼️', style: TextStyle(fontSize: 96)),
          Text(
            word.toLowerCase(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
