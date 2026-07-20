import 'package:flutter/material.dart';

import '../../../core/responsive.dart';
import '../../../core/widgets/menu_tile.dart';
import '../../../core/widgets/tile_menu.dart';
import '../../../data/db/database.dart';
import '../../math/ui/math_home_page.dart';
import '../../reading/ui/reading_home_page.dart';

/// Startseite eines Kindes: Auswahl der Disziplin (Lesen, Rechnen). Die
/// eltern-geführte Lektion und „Mein Name" sitzen jeweils innerhalb der
/// Disziplin – so wird zuerst entschieden, was heute dran ist.
class ChildHomePage extends StatelessWidget {
  const ChildHomePage({super.key, required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hallo ${child.name}!'), centerTitle: true),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.isCompact ? 16 : 24),
          child: TileMenu(
            children: [
              MenuTile(
                label: 'Lesen',
                iconId: 'module_lesen',
                emoji: '📖',
                color: Colors.orange.shade200,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReadingHomePage(child: child),
                  ),
                ),
              ),
              MenuTile(
                label: 'Rechnen',
                iconId: 'module_rechnen',
                emoji: '🔢',
                color: Colors.green.shade200,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MathHomePage(child: child),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
