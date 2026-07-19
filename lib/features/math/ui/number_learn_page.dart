import 'package:flutter/material.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/tile_style.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/number_repository.dart';
import '../model/math_problem.dart';
import 'math_exercise_page.dart';
import 'math_visuals.dart';

const _zahlwort = {
  1: 'eins',
  2: 'zwei',
  3: 'drei',
  4: 'vier',
  5: 'fünf',
  6: 'sechs',
  7: 'sieben',
  8: 'acht',
  9: 'neun',
};

class _Step {
  const _Step(this.zahl, this.obj);
  final int zahl;
  final MathObject obj;
}

/// „Zahlen kennenlernen": geht 1…9 der Reihe nach durch, zeigt je Zahl ein
/// paar Beispiele (Bildobjekte + die Ziffer daneben) und spricht die Zahl.
/// Erst danach folgt das zufällige Abfragen im Üben-Modus.
class NumberLearnPage extends StatefulWidget {
  const NumberLearnPage({super.key, required this.child});
  final Child child;

  @override
  State<NumberLearnPage> createState() => _NumberLearnPageState();
}

class _NumberLearnPageState extends State<NumberLearnPage> {
  final _audio = getIt<AudioService>();
  final _numbers = getIt<NumberRepository>();
  List<_Step> _steps = const [];
  int _index = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Nur bis zur eingeführten Zahl – läuft dem Lektions-Fortschritt nicht
    // voraus. Boden 1, damit vor der ersten Lektion nicht 1–3 erscheinen.
    final introduced = await _numbers.highestIntroduced(widget.child.id);
    final cap = introduced < 1 ? 1 : introduced;
    if (!mounted) return;
    setState(() {
      _steps = [
        for (var n = 1; n <= cap; n++)
          for (var e = 0; e < 2; e++)
            _Step(n, mathObjects[(n + e) % mathObjects.length]),
      ];
      _loading = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _sprich();
    });
  }

  /// Spricht die Zahl und dann ein Beispiel mit korrektem Singular/Plural,
  /// z. B. "eins, ein Ball" oder "zwei, zwei Fische".
  void _sprich() {
    final s = _steps[_index];
    final o = s.obj;
    final text = s.zahl == 1
        ? 'eins, ${o.artikel} ${o.singular}'
        : '${_zahlwort[s.zahl]}, ${_zahlwort[s.zahl]} ${o.plural}';
    _audio.speak(text);
  }

  /// Groesse der Zaehl-Objekte: wenige = gross.
  double _itemSize(int n) =>
      n <= 2 ? 150 : (n <= 4 ? 120 : (n <= 6 ? 92 : 72));

  void _weiter() {
    if (_index < _steps.length - 1) {
      setState(() => _index++);
      _sprich();
    } else {
      _zumUeben();
    }
  }

  void _zurueck() {
    if (_index > 0) {
      setState(() => _index--);
      _sprich();
    }
  }

  void _zumUeben() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            MathExercisePage(child: widget.child, module: MathModule.ziffern),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _steps.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final step = _steps[_index];
    final istLetzte = _index == _steps.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text('Zahlen kennenlernen · ${widget.child.name}'),
        actions: [
          TextButton(
            onPressed: _zumUeben,
            child: const Text('Üben →'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  // Objekte zum Abzählen.
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: ObjectsView(
                        count: step.zahl,
                        slug: step.obj.slug,
                        itemSize: _itemSize(step.zahl),
                      ),
                      ),
                    ),
                  ),
                  // Die Ziffer, antippbar zum erneuten Hören.
                  Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: _sprich,
                        child: Container(
                          width: 200,
                          height: 240,
                          alignment: Alignment.center,
                          decoration: TileStyle.surface(const Color(0xFFFFCC80),
                              radius: 28),
                          child: Text(
                            '${step.zahl}',
                            style: const TextStyle(
                              fontSize: 160,
                              fontWeight: FontWeight.w800,
                              color: TileStyle.ink,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                children: [
                  IconButton.filledTonal(
                    iconSize: 40,
                    onPressed: _index > 0 ? _zurueck : null,
                    icon: const Icon(Icons.chevron_left),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _weiter,
                    icon: Icon(istLetzte ? Icons.check : Icons.chevron_right),
                    label: Text(istLetzte ? 'Fertig – üben!' : 'Weiter'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
