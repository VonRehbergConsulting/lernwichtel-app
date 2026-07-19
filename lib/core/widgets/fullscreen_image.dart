import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/slug.dart';

/// Bildschirmfuellendes Bild zu einem Wort. Erscheint erst auf Wunsch,
/// Tippen schliesst es wieder.
///
/// Reihenfolge: hinterlegtes Foto (Datei) -> generiertes Comic-Standardbild
/// (Asset `assets/images/standard/<slug>.webp`) -> Platzhalter mit dem Wort.
class FullscreenImage extends StatelessWidget {
  const FullscreenImage({
    super.key,
    required this.imagePath,
    required this.label,
    required this.onClose,
  });

  final String? imagePath;
  final String label;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final hasCustom = path != null && File(path).existsSync();
    final standardAsset = 'assets/images/standard/${wortSlug(label)}.webp';

    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        child: Stack(
          children: [
            Positioned.fill(
              child: hasCustom
                  ? Image.file(File(path), fit: BoxFit.contain)
                  // Generiertes Standardbild; fehlt es, greift der Platzhalter.
                  : Image.asset(
                      standardAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) =>
                          _placeholder(label),
                    ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black12,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 28),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('🖼️', style: TextStyle(fontSize: 140)),
        const SizedBox(height: 16),
        Text(
          label.toLowerCase(),
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Noch kein Bild hinterlegt',
          style: TextStyle(fontSize: 18, color: Colors.black54),
        ),
      ],
    );
  }
}
