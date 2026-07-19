import 'package:flutter/material.dart';

import '../../../core/widgets/menu_tile.dart';
import 'child_list_page.dart';
import 'word_images_page.dart';

/// Eltern-Bereich (hinter dem Eltern-Schutz). Zentrale Verwaltung.
class ParentHomePage extends StatelessWidget {
  const ParentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eltern-Bereich')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              MenuTile(
                iconId: 'parent_kinder',
                emoji: '👪',
                label: 'Kinder',
                subtitle: 'Anlegen · Umbenennen · Löschen · Fortschritt',
                color: const Color(0xFF90CAF9),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ChildListPage()),
                ),
              ),
              MenuTile(
                iconId: 'parent_bilder',
                emoji: '🖼️',
                label: 'Eigene Bilder',
                subtitle: 'Fotos zu Wörtern hinterlegen',
                color: const Color(0xFFA5D6A7),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WordImagesPage()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
