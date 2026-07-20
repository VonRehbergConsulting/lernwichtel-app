import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/widgets/menu_icon.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/number_repository.dart';
import '../../guided/lesson_widgets.dart';
import '../../writing/ui/letter_tracer.dart';
import '../../writing/ui/tracer_fullscreen.dart';
import '../model/math_problem.dart';
import '../number_words.dart';
import 'math_visuals.dart';

/// Eltern-geführte **Drei-Perioden-Lektion** fürs Rechnen: verknüpft **Menge**
/// (echte Objekte), **Ziffer** und **Zahlwort** – Benennen → Zeig mir → Wie
/// viele? → Schreiben → gemeinsam. Spiegelt die Lese-Lektion.
class GuidedMathSessionPage extends StatefulWidget {
  const GuidedMathSessionPage({super.key, required this.child});

  final Child child;

  @override
  State<GuidedMathSessionPage> createState() => _GuidedMathSessionPageState();
}

class _GuidedMathSessionPageState extends State<GuidedMathSessionPage> {
  final _numbers = getIt<NumberRepository>();
  final _audio = getIt<AudioService>();
  final _rnd = Random();
  final _flow = StepController();

  int? _number;
  List<int> _options = const [];
  MathObject? _object;
  int _box = 1;
  bool _wrote = false;
  bool _loading = true;
  int _step = 0;

  static const _periods = [
    'Vorbereitung',
    'Benennen',
    'Zeig mir',
    'Wie viele?',
    'Schreiben',
    'Gemeinsam',
    'Geschafft',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _flow.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final number = await _numbers.nextNumberToTeach(widget.child.id);
    var options = const <int>[];
    var box = 1;
    if (number != null) {
      options = [number, ..._numbers.siblingNumbers(number)]..shuffle(_rnd);
      final progress = await _numbers.progressFor(widget.child.id);
      box = progress[number]?.box ?? 1;
    }
    if (!mounted) return;
    setState(() {
      _number = number;
      _options = options;
      _object = mathObjects[_rnd.nextInt(mathObjects.length)];
      _box = box;
      _loading = false;
    });
  }

  void _speak(int n) => _audio.speak(zahlwort(n));

  Future<void> _assess(bool secure) async {
    final n = _number!;
    if (secure) {
      await _numbers.setMastered(
          childId: widget.child.id, value: n, mastered: true);
    } else {
      await _numbers.recordResult(
          childId: widget.child.id, value: n, correct: true);
    }
    if (!mounted) return;
    _flow.goTo(6);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_number == null) {
      return _allDone();
    }
    return LessonStepView(
      title: 'Zahlen-Lektion',
      periods: _periods,
      controller: _flow,
      step: _step,
      onStepChanged: (i) => setState(() => _step = i),
      noSwipeSteps: const {4, 5, 6},
      pages: [
        _prepStep(),
        _nameStep(),
        _showMeStep(),
        _countStep(),
        _writeStep(),
        _closeStep(),
        _doneStep(),
      ],
    );
  }

  // -------------------------------------------------------------- Steps

  Widget _prepStep() {
    final n = _number!;
    return StepScaffold(
      hero: _quantityCard(n),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Heute mit ${widget.child.name}:',
              style: const TextStyle(fontSize: 18, color: Colors.black54)),
          const SizedBox(height: 10),
          Center(child: _speakButton('So heißt die Zahl', n)),
          const SizedBox(height: 16),
          LessonTip('Verknüpft immer **Menge, Zahl und Wort**: „Das sind '
              '**$n** – **${zahlwort(n)}**." Zeig dabei auf die Dinge und tippt '
              'sie beim Zählen einzeln an.'),
          const LessonTip('Kurz und ruhig – ein paar Minuten reichen.'),
          const LessonTip('Erst die Menge zum Anfassen, dann die Ziffer. '
              'Nichts auswendig – gemeinsam zählen trägt.'),
        ],
      ),
      primaryLabel: "Los geht's",
      onPrimary: () => _flow.goTo(1),
    );
  }

  Widget _nameStep() {
    final n = _number!;
    return StepScaffold(
      hero: _quantityCard(n),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LessonInstruction(
            '1. Benennen',
            'Zählt gemeinsam die Dinge und sagt dann: „Das sind $n – '
                '${zahlwort(n)}."',
          ),
          const SizedBox(height: 16),
          Center(child: _speakButton('Zahl anhören', n)),
        ],
      ),
      primaryLabel: 'Weiter',
      onPrimary: () => _flow.goTo(2),
      onBack: () => _flow.goTo(0),
    );
  }

  Widget _showMeStep() {
    final n = _number!;
    return StepScaffold(
      hero: Wrap(
        spacing: 16,
        runSpacing: 16,
        alignment: WrapAlignment.center,
        children: [
          for (final o in _options)
            LessonOptionTile(text: '$o', onTap: () => _speak(o)),
        ],
      ),
      body: LessonInstruction(
        '2. Zeig mir',
        'Bitte dein Kind: „Zeig mir die ${zahlwort(n)}." Zum Nachhören '
            'könnt ihr tippen.',
      ),
      primaryLabel: 'Weiter',
      onPrimary: () => _flow.goTo(3),
      onBack: () => _flow.goTo(1),
    );
  }

  Widget _countStep() {
    final n = _number!;
    return StepScaffold(
      hero: Center(
        child: ObjectsView(count: n, slug: _object!.slug, itemSize: 88),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const LessonInstruction(
            '3. Wie viele?',
            'Zeig nur die Menge und frag: „Wie viele sind das?" Dein Kind '
                'zählt – zur Kontrolle könnt ihr die Zahl anhören.',
          ),
          const SizedBox(height: 16),
          Center(child: _speakButton('Zur Kontrolle anhören', n)),
        ],
      ),
      primaryLabel: 'Weiter',
      onPrimary: () => _flow.goTo(4),
      onBack: () => _flow.goTo(2),
    );
  }

  Widget _writeStep() {
    final n = _number!;
    return StepScaffold(
      heroFills: true,
      hero: LetterTracer(
        glyph: '$n',
        box: _box,
        onSolved: () {
          if (mounted) setState(() => _wrote = true);
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LessonInstruction(
            '4. Schreiben',
            'Jetzt schreibt ihr die $n. Fahr sie gemeinsam mit dem Finger '
                'oder Stift nach.',
          ),
          const SizedBox(height: 16),
          Center(
            child: FilledButton.tonalIcon(
              onPressed: () => openTracerFullscreen(
                context,
                glyph: '$n',
                box: _box,
                onSolved: () {
                  if (mounted) setState(() => _wrote = true);
                },
              ),
              icon: const Icon(Icons.fullscreen_rounded),
              label: const Text('Groß malen (quer)'),
            ),
          ),
          if (_wrote) ...[
            const SizedBox(height: 12),
            const LessonWroteBadge(),
          ],
        ],
      ),
      primaryLabel: 'Weiter',
      onPrimary: () => _flow.goTo(5),
      onBack: () => _flow.goTo(3),
    );
  }

  Widget _closeStep() {
    final n = _number!;
    final dinge = '$n ${n == 1 ? _object!.singular : _object!.plural}';
    return StepScaffold(
      hero: Card(
        color: const Color(0xFFFFF3E0),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MenuIcon(id: 'such_lupe', emoji: '🔎', size: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Legt zusammen genau $dinge hin (oder irgendwelche '
                  'Dinge) und zählt sie gemeinsam ab.',
                  style: const TextStyle(fontSize: 17),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const LessonInstruction(
            'Gemeinsam & Rückblick',
            'Legt das Tablet weg und legt es zusammen in echt.',
          ),
          const SizedBox(height: 20),
          Text('Wie sicher war ${widget.child.name} bei der Zahl?',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _assess(false),
            icon: const Icon(Icons.autorenew),
            label: const Text('Noch üben'),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: () => _assess(true),
            icon: const Icon(Icons.check),
            label: const Text('Sitzt sicher!'),
          ),
        ],
      ),
      onBack: () => _flow.goTo(4),
    );
  }

  Widget _doneStep() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const MenuIcon(id: 'feier_stern', emoji: '🌟', size: 80),
          const SizedBox(height: 12),
          const Text('Für heute geschafft!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Kurz und regelmäßig wirkt am besten. Morgen die nächste Zahl.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Fertig'),
          ),
        ],
      ),
    );
  }

  Widget _allDone() {
    return Scaffold(
      appBar: AppBar(title: const Text('Zahlen-Lektion')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MenuIcon(id: 'feier_konfetti', emoji: '🎉', size: 80),
            const SizedBox(height: 12),
            const Text('Die Zahlen bis 10 sitzen!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Ihr könnt jetzt das Rechnen mit Mengen vertiefen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Zurück'),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------- Bausteine

  /// Menge (Objekte) + große Ziffer (gerahmt wie in der Buchstaben-Lektion) +
  /// Zahlwort – das Trio zusammen.
  Widget _quantityCard(int n) {
    return Column(
      children: [
        ObjectsView(count: n, slug: _object!.slug, itemSize: 64),
        const SizedBox(height: 16),
        LessonGlyphCard('$n'),
        const SizedBox(height: 8),
        Text(zahlwort(n),
            style: const TextStyle(fontSize: 22, color: Colors.black54)),
      ],
    );
  }

  Widget _speakButton(String label, int n) {
    return OutlinedButton.icon(
      onPressed: () => _speak(n),
      icon: const Icon(Icons.volume_up),
      label: Text(label),
    );
  }

}
