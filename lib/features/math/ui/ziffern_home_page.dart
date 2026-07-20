import 'package:flutter/material.dart';

import '../../../core/responsive.dart';
import '../../../core/widgets/menu_tile.dart';
import '../../../core/widgets/tile_menu.dart';
import '../../../data/db/database.dart';
import '../model/math_problem.dart';
import 'math_exercise_page.dart';
import 'number_learn_page.dart';

/// Einstieg in die Ziffern: erst „kennenlernen", dann „üben".
class ZiffernHomePage extends StatelessWidget {
  const ZiffernHomePage({super.key, required this.child});
  final Child child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Ziffern · ${child.name}')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(context.isCompact ? 16 : 24),
          child: TileMenu(
            tabletAspectRatio: 1.1,
            children: [
              MenuTile(
                iconId: 'ziffern_kennenlernen',
                emoji: '👀',
                label: 'Kennenlernen',
                subtitle: 'Zahlen 1 bis 9',
                color: const Color(0xFFFFE082),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NumberLearnPage(child: child),
                  ),
                ),
              ),
              MenuTile(
                iconId: 'ziffern_ueben',
                emoji: '✏️',
                label: 'Üben',
                subtitle: 'Welche Zahl ist das?',
                color: const Color(0xFFA5D6A7),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => MathExercisePage(
                      child: child,
                      module: MathModule.ziffern,
                    ),
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
