import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/audio/audio_service.dart';
import '../../core/di/service_locator.dart';
import '../../core/widgets/menu_icon.dart';
import '../../data/db/database.dart';
import '../../data/repositories/reading_repository.dart';
import '../hunt/fundstuecke_strip.dart';
import '../hunt/sound_hunt_page.dart';
import '../writing/ui/letter_tracer.dart';
import 'lesson_widgets.dart';

/// Eltern-geführte **Drei-Perioden-Lektion** (Montessori) für einen Anlaut.
///
/// Die App ist hier Werkzeug der Eltern: Sie liefert den korrekten Laut und
/// führt Schritt für Schritt an – Benennen → Zeig mir → Was ist das? – und
/// endet mit einer gemeinsamen Off-Screen-Aufgabe und einem kurzen Rückblick,
/// bei dem die Eltern einschätzen, ob der Laut sitzt.
class GuidedSessionPage extends StatefulWidget {
  const GuidedSessionPage({super.key, required this.child});

  final Child child;

  @override
  State<GuidedSessionPage> createState() => _GuidedSessionPageState();
}

class _GuidedSessionPageState extends State<GuidedSessionPage> {
  final _reading = getIt<ReadingRepository>();
  final _audio = getIt<AudioService>();
  final _rnd = Random();
  final _flow = StepController();

  Grapheme? _letter;
  List<Grapheme> _options = const [];
  int _box = 1;
  bool _wrote = false;
  bool _loading = true;
  int _step = 0;

  static const _periods = [
    'Vorbereitung',
    'Benennen',
    'Zeig mir',
    'Was ist das?',
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
    final letter = await _reading.nextGraphemeToTeach(
      widget.child.id,
      'buchstabe',
      boostName: widget.child.name,
    );
    final options = <Grapheme>[];
    if (letter != null) {
      final sibs = await _reading.siblingGraphemes(
        'buchstabe',
        excludeId: letter.id,
        aroundSortOrder: letter.sortOrder,
        count: 2,
      );
      options
        ..add(letter)
        ..addAll(sibs);
      options.shuffle(_rnd);
    }
    var box = 1;
    if (letter != null) {
      final progress = await _reading.progressFor(widget.child.id);
      box = progress[letter.id]?.box ?? 1;
    }
    if (!mounted) return;
    setState(() {
      _letter = letter;
      _options = options;
      _box = box;
      _loading = false;
    });
  }

  void _playLetter(Grapheme g) =>
      _audio.playGrapheme(key: g.graphemeKey, fallbackText: g.symbol);

  /// Der zu sprechende Laut des aktuellen Buchstabens (aus den Seed-Daten),
  /// z. B. „ooo" oder „t (kurz, ohne 'e')". Fällt auf das Symbol zurück.
  String get _laut {
    final s = _letter?.sound?.trim() ?? '';
    return s.isNotEmpty ? s : (_letter?.symbol ?? '');
  }

  /// Kurzform ohne Klammer-Hinweis – fürs knappe Zitieren im Anweisungstext.
  String get _lautKurz {
    final s = _laut;
    final i = s.indexOf(' (');
    return i > 0 ? s.substring(0, i).trim() : s;
  }

  Future<void> _assess(bool secure) async {
    final letter = _letter!;
    if (secure) {
      await _reading.setMastered(
        childId: widget.child.id,
        graphemeId: letter.id,
        mastered: true,
      );
    } else {
      // Ermutigend weiterzählen (Leitner-Box hoch), aber noch nicht "sicher".
      await _reading.recordResult(
        childId: widget.child.id,
        graphemeId: letter.id,
        correct: true,
      );
    }
    if (!mounted) return;
    _flow.goTo(6);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_letter == null) {
      return _allDone();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Lektion · ${_periods[_step]}'),
      ),
      body: SafeArea(
        child: StepPageView(
          controller: _flow,
          step: _step,
          onStepChanged: (i) => setState(() => _step = i),
          // Schreiben (4), Rückblick (5, bewusste Bewertung) und Abschluss (6)
          // nicht wischbar – sonst könnte man zurückwischen und doppelt bewerten.
          noSwipeSteps: const {4, 5, 6},
          pages: [
            _prepStep(),
            _nameStep(),
            _showMeStep(),
            _recallStep(),
            _writeStep(),
            _closeStep(),
            _doneStep(),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------- Steps

  Widget _prepStep() {
    return StepScaffold(
      content: ListView(
        children: [
          Text('Heute mit ${widget.child.name}:',
              style: const TextStyle(fontSize: 18, color: Colors.black54)),
          const SizedBox(height: 8),
          _letterCard(),
          FundstueckeStrip(
              childId: widget.child.id, letter: _letter!.symbol),
          const SizedBox(height: 8),
          Center(child: _soundButton('So klingt der Laut')),
          const SizedBox(height: 20),
          LessonTip('Sprich den **Laut** „$_laut" – nicht den Buchstaben-'
              'Namen. Genau dafür ist der Hör-Knopf da: hör ihn dir einmal an '
              'und mach ihn nach.'),
          const LessonTip('Haltet es kurz und ruhig – ein paar Minuten nebeneinander '
              'reichen völlig.'),
          const LessonTip('Kein Zeitdruck, keine Belohnung nötig. Neugier trägt.'),
        ],
      ),
      primaryLabel: "Los geht's",
      onPrimary: () => _flow.goTo(1),
    );
  }

  Widget _nameStep() {
    return StepScaffold(
      content: Column(
        children: [
          LessonInstruction(
            '1. Benennen',
            'Zeig auf den Buchstaben und sag ruhig: „Das ist $_lautKurz."',
          ),
          const SizedBox(height: 16),
          _letterCard(),
          const SizedBox(height: 12),
          _soundButton('Laut anhören'),
        ],
      ),
      primaryLabel: 'Weiter',
      onPrimary: () => _flow.goTo(2),
      onBack: () => _flow.goTo(0),
    );
  }

  Widget _showMeStep() {
    return StepScaffold(
      content: Column(
        children: [
          LessonInstruction(
            '2. Zeig mir',
            'Bitte dein Kind: „Zeig mir $_lautKurz." Tippen könnt ihr zum '
                'Nachhören – zeigen darf es aber auch einfach mit dem Finger.',
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              for (final g in _options)
                LessonOptionTile(
                    text: g.symbol, onTap: () => _playLetter(g)),
            ],
          ),
        ],
      ),
      primaryLabel: 'Weiter',
      onPrimary: () => _flow.goTo(3),
      onBack: () => _flow.goTo(1),
    );
  }

  Widget _recallStep() {
    return StepScaffold(
      content: Column(
        children: [
          const LessonInstruction(
            '3. Was ist das?',
            'Zeig nur diesen Buchstaben und frag: „Was ist das?" '
                'Dein Kind sagt den Laut – zum Prüfen könnt ihr ihn anhören.',
          ),
          const SizedBox(height: 16),
          _letterCard(),
          FundstueckeStrip(
              childId: widget.child.id, letter: _letter!.symbol),
          const SizedBox(height: 12),
          _soundButton('Zur Kontrolle anhören'),
        ],
      ),
      primaryLabel: 'Weiter',
      onPrimary: () => _flow.goTo(4),
      onBack: () => _flow.goTo(2),
    );
  }

  Widget _writeStep() {
    return StepScaffold(
      content: Column(
        children: [
          const LessonInstruction(
            '4. Schreiben',
            'Jetzt schreibt ihr den Buchstaben. Fahr ihn gemeinsam mit dem '
                'Finger oder Stift nach.',
          ),
          const SizedBox(height: 12),
          Expanded(
            child: LetterTracer(
              glyph: _letter!.symbol,
              box: _box,
              onSolved: () {
                if (mounted) setState(() => _wrote = true);
              },
            ),
          ),
          if (_wrote) const LessonWroteBadge(),
        ],
      ),
      primaryLabel: 'Weiter',
      onPrimary: () => _flow.goTo(5),
      onBack: () => _flow.goTo(3),
    );
  }

  Widget _closeStep() {
    return StepScaffold(
      content: ListView(
        children: [
          const LessonInstruction(
            'Gemeinsam & Rückblick',
            'Legt das Tablet jetzt weg und geht zusammen auf die Suche:',
          ),
          const SizedBox(height: 12),
          Card(
            color: const Color(0xFFFFF3E0),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  MenuIcon(id: 'such_lupe', emoji: '🔎', size: 40),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Findet zusammen ein paar Dinge in der Wohnung, die mit '
                      'diesem Laut anfangen. Sprecht den Laut dabei laut mit.',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (_) => SoundHuntPage(
                  sound: _lautKurz,
                  letter: _letter!.symbol,
                  childId: widget.child.id,
                ),
              )),
              icon: const Icon(Icons.photo_camera),
              label: const Text('Auf Foto-Schatzsuche gehen'),
            ),
          ),
          const SizedBox(height: 24),
          Text('Wie sicher war ${widget.child.name} beim Laut?',
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
              'Kurz und regelmäßig wirkt am besten. Morgen ein Stück weiter.',
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
      appBar: AppBar(title: const Text('Lektion')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MenuIcon(id: 'feier_konfetti', emoji: '🎉', size: 80),
            const SizedBox(height: 12),
            const Text('Alle Buchstaben-Laute sitzen!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Ihr könnt jetzt Lautverbindungen und das Zusammenlesen '
                'vertiefen.',
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

  Widget _letterCard() => LessonGlyphCard(_letter!.symbol);

  Widget _soundButton(String label) {
    return OutlinedButton.icon(
      onPressed: () => _playLetter(_letter!),
      icon: const Icon(Icons.volume_up),
      label: Text(label),
    );
  }

}

