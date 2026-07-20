import 'package:flutter/material.dart';

import '../../../core/responsive.dart';
import '../../../core/widgets/menu_tile.dart';
import '../../../core/widgets/tile_menu.dart';
import 'child_list_page.dart';
import 'word_images_page.dart';

/// Eltern-Bereich (hinter dem Eltern-Schutz). Zentrale Verwaltung.
class ParentHomePage extends StatelessWidget {
  const ParentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tiles = [
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
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('Eltern-Bereich')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.isCompact ? 16 : 24),
          child: TileMenu(children: tiles),
        ),
      ),
    );
  }
}
