import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/responsive.dart';
import '../../../core/widgets/adaptive_home_layout.dart';
import '../../../core/widgets/locked_hint.dart';
import '../../../core/widgets/menu_tile.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/gate_repository.dart';
import '../../guided/lesson_widgets.dart';
import '../../learning/learning_sections.dart';
import '../model/math_problem.dart';
import 'guided_math_session_page.dart';
import 'math_exercise_page.dart';
import 'ziffern_home_page.dart';

/// Auswahl der vier Rechen-Bereiche. Fortgeschrittene Module sind gesperrt, bis
/// das Vorgaenger-Modul sicher genug ist (oder die Eltern es freischalten).
class MathHomePage extends StatefulWidget {
  const MathHomePage({super.key, required this.child});

  final Child child;

  @override
  State<MathHomePage> createState() => _MathHomePageState();
}

class _MathHomePageState extends State<MathHomePage> {
  final _gate = getIt<GateRepository>();
  Set<String>? _unlocked;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unlocked = await _gate.unlockedFor(widget.child.id);
    if (!mounted) return;
    setState(() => _unlocked = unlocked);
  }

  void _open(MathModule module) {
    final key = 'math_${module.key}';
    if (!(_unlocked ?? const {}).contains(key)) {
      showLockedHint(context, lockedHintFor(key));
      return;
    }
    Navigator.of(context)
        .push(MaterialPageRoute(
          // Ziffern: erst kennenlernen/üben-Auswahl; sonst direkt.
          builder: (_) => module == MathModule.ziffern
              ? ZiffernHomePage(child: widget.child)
              : MathExercisePage(child: widget.child, module: module),
        ))
        .then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    const tiles = [
      (MathModule.ziffern, 'Ziffern', 'Zählen & Zahlen', Color(0xFFFFCC80)),
      (MathModule.zehner, 'Zahlen bis 100', 'Zehner & Einer', Color(0xFF90CAF9)),
      (MathModule.addieren, 'Plus', 'Zusammenzählen', Color(0xFFA5D6A7)),
      (MathModule.subtrahieren, 'Minus', 'Wegnehmen', Color(0xFFF48FB1)),
    ];

    final unlocked = _unlocked;
    final Widget content;
    if (unlocked == null) {
      content = const Center(child: CircularProgressIndicator());
    } else {
      final compact = context.isCompact;
      final lesson = GuidedLessonCard(
        iconId: 'math_lektion',
        subtitle: 'Die nächste Zahl gemeinsam einführen',
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (_) => GuidedMathSessionPage(child: widget.child),
            ))
            .then((_) => _load()),
      );
      final grid = GridView.count(
        // Gleiche Kachelgröße wie auf der Lesen-Seite: Handy 2, Tablet 3.
        crossAxisCount: compact ? 2 : 3,
        mainAxisSpacing: compact ? 12 : 20,
        crossAxisSpacing: compact ? 12 : 20,
        children: [
          for (final (module, label, subtitle, color) in tiles)
            MenuTile(
              iconId: 'math_${module.key}',
              emoji: module.emoji,
              label: label,
              subtitle: subtitle,
              color: color,
              locked: !unlocked.contains('math_${module.key}'),
              onTap: () => _open(module),
            ),
        ],
      );

      content = AdaptiveHomeLayout(sidebar: [lesson], grid: grid);
    }

    return Scaffold(
      appBar: AppBar(title: Text('Rechnen · ${widget.child.name}')),
      body: SafeArea(child: content),
    );
  }
}
