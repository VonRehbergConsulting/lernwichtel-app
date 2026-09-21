import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/word_image.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/content_repository.dart';
import '../bloc/silben_bloc.dart';

/// Silben klatschen: Wort mit Bild, dazu Silbenbögen. Pro Klatscher wird eine
/// Silbe aufgedeckt (Bogen färbt sich, Silbe wird gesprochen). Schult das
/// Silbenbewusstsein („aus wie vielen Silben besteht ein Wort?").
///
/// TODO(phonologische-bewusstheit): UNFERTIG – diese Seite ist absichtlich
/// eingecheckt, aber noch nicht angeschlossen. Sie ist der erste Baustein
/// einer Stufe VOR dem eigentlichen Lesen (Silben, Reime, Anlaute). Offen:
///
///  1. Erreichbarkeit: kein MenuTile in `reading_home_page.dart` – nichts
///     führt hierher.
///  2. Bereichs-Schlüssel in `learning_sections.dart` (z. B. `lese_silben`)
///     fehlt, damit auch Freischaltung, Eltern-Schalter und Sperrhinweis.
///  3. Menü-Icon: `assets/content/menu_prompts.json` kennt den Schlüssel
///     noch nicht, die Kachel fiele aufs Emoji zurück.
///  4. Reime: Daten und `ContentRepository.loadRhymeGroups()` sind da, eine
///     Oberfläche dazu fehlt komplett.
///  5. Tests für `SilbenBloc` fehlen (andere Blocs haben welche).
///  6. Einsortierung ist noch nicht entschieden: Wird diese Stufe die neue
///     Basis und `lese_buchstaben` rückt dahinter, oder läuft sie als zweite
///     immer offene Kachel daneben? Ersteres greift in die Freischaltkette
///     und in `StartLevelX.unlocks` (Anlege-Assistent) ein.
class SilbenPage extends StatelessWidget {
  const SilbenPage({super.key, required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SilbenBloc(
        content: getIt<ContentRepository>(),
        audio: getIt<AudioService>(),
      )..add(const SilbenStarted()),
      child: Scaffold(
        appBar: AppBar(title: Text('Silben · ${child.name}')),
        body: const SafeArea(child: _Body()),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SilbenBloc, SilbenState>(
      builder: (context, state) {
        switch (state.status) {
          case SilbenStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case SilbenStatus.error:
            return ErrorView(
              onRetry: () =>
                  context.read<SilbenBloc>().add(const SilbenStarted()),
            );
          case SilbenStatus.empty:
            return const Center(
              child: Text('Keine Wörter vorhanden.',
                  style: TextStyle(fontSize: 20)),
            );
          case SilbenStatus.ready:
            // Key = Index: pro Wort startet die Klatsch-Interaktion frisch.
            return _Exercise(key: ValueKey(state.index), state: state);
        }
      },
    );
  }
}

class _Exercise extends StatefulWidget {
  const _Exercise({super.key, required this.state});
  final SilbenState state;

  @override
  State<_Exercise> createState() => _ExerciseState();
}

class _ExerciseState extends State<_Exercise> {
  int _clapped = 0; // wie viele Silben schon geklatscht

  SyllableWord get _word => widget.state.current!;
  bool get _done => _clapped >= _word.count;

  void _clap() {
    if (_done) return;
    HapticFeedback.lightImpact();
    final syllable = _word.syllables[_clapped];
    setState(() => _clapped++);
    context.read<SilbenBloc>().add(SilbenSpeakSyllable(syllable));
  }

  void _reset() => setState(() => _clapped = 0);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SilbenBloc>();
    final state = widget.state;

    return Column(
      children: [
        const SizedBox(height: 8),
        Text('${state.index + 1} / ${state.revealed}',
            style: Theme.of(context).textTheme.labelLarge),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _clap,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F6FB),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: WordImage(word: _word.word),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _SyllableArcs(syllables: _word.syllables, clapped: _clapped),
                const SizedBox(height: 12),
                SizedBox(
                  height: 30,
                  child: _done
                      ? Text(
                          _word.count == 1
                              ? '1 Silbe!'
                              : '${_word.count} Silben!',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w800),
                        )
                      : const Text('Klatsche die Silben mit',
                          style: TextStyle(fontSize: 15, color: Colors.black54)),
                ),
              ],
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: _done ? _reset : _clap,
          icon: Text(_done ? '🔁' : '👏', style: const TextStyle(fontSize: 22)),
          label: Text(_done ? 'Nochmal' : 'Klatschen'),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 56),
            padding: const EdgeInsets.symmetric(horizontal: 32),
          ),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => bloc.add(const SilbenSpeakWord()),
          icon: const Icon(Icons.volume_up),
          label: const Text('Ganzes Wort'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton.filledTonal(
              iconSize: 40,
              onPressed: state.hasPrevious
                  ? () => bloc.add(const PreviousSyllableWordRequested())
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton.filledTonal(
              iconSize: 40,
              onPressed: state.hasNext
                  ? () => bloc.add(const NextSyllableWordRequested())
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        if (state.canRevealMore) ...[
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: () => bloc.add(const MoreSyllableWordsRequested()),
            icon: const Icon(Icons.add),
            label: const Text('Mehr Wörter'),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

/// Das Wort in Silben-Chunks mit Bögen darunter. Geklatschte Silben sind
/// eingefärbt (abwechselnd rot/blau – wie in der Silbenmethode), die übrigen
/// bleiben grau.
class _SyllableArcs extends StatelessWidget {
  const _SyllableArcs({required this.syllables, required this.clapped});
  final List<String> syllables;
  final int clapped;

  static const _red = Color(0xFFD32F2F);
  static const _blue = Color(0xFF1565C0);
  static const _grey = Colors.black26;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < syllables.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _Chunk(
                text: syllables[i],
                color: i < clapped
                    ? (i.isEven ? _red : _blue)
                    : _grey,
                revealed: i < clapped,
              ),
            ),
        ],
      ),
    );
  }
}

class _Chunk extends StatelessWidget {
  const _Chunk({
    required this.text,
    required this.color,
    required this.revealed,
  });
  final String text;
  final Color color;
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    // IntrinsicWidth: die Spalte (und damit der Bogen) ist genau so breit wie
    // die Silbe – nötig, weil das Ganze in einer FittedBox (unbeschränkte
    // Breite) steckt und der Bogen sonst keine endliche Breite hätte.
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.w800,
              color: revealed ? color : Colors.black38,
            ),
          ),
          const SizedBox(height: 4),
          CustomPaint(
            size: const Size(double.infinity, 16),
            painter: _ArcPainter(color),
          ),
        ],
      ),
    );
  }
}

/// Zeichnet einen nach unten offenen Silbenbogen unter einer Silbe.
class _ArcPainter extends CustomPainter {
  const _ArcPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(2, 0)
      ..quadraticBezierTo(size.width / 2, size.height * 2.2, size.width - 2, 0);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color;
}
