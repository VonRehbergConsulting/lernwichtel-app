import 'package:flutter/material.dart';

import '../../../core/widgets/menu_tile.dart';
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
          padding: const EdgeInsets.all(24),
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            children: [
              MenuTile(
                iconId: 'ziffern_kennenlernen',
                emoji: '👀',
                label: 'Kennenlernen',
                subtitle: 'Zahlen 1 bis 9',
                color: const Color(0xFFFFE082),
                iconSize: 96,
                labelSize: 24,
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
                iconSize: 96,
                labelSize: 24,
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
