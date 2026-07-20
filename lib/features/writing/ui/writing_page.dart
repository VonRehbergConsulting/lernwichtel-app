import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/widgets/menu_icon.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/repositories/reading_repository.dart';
import 'letter_tracer.dart';
import 'tracer_fullscreen.dart';

/// Schreib-Modul: Buchstaben mit Finger oder Stift nachfahren. Die App prüft
/// automatisch beim Absetzen und meldet nur den Erfolg (adaptiv nach Lernstand).
class WritingPage extends StatefulWidget {
  const WritingPage({super.key, required this.child});

  final Child child;

  @override
  State<WritingPage> createState() => _WritingPageState();
}

class _WritingPageState extends State<WritingPage> {
  final _content = getIt<ContentRepository>();
  final _reading = getIt<ReadingRepository>();

  List<Grapheme> _letters = const [];
  Grapheme? _selected;
  int _box = 1;
  int _nonce = 0; // erzwingt eine frische Fläche bei "Nochmal"
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await _content.graphemesByKind('buchstabe');
    final progress = await _reading.progressFor(widget.child.id);
    // Nur schon eingeführte Buchstaben (Fortschritt ≠ „neu"); solange zu wenige
    // sitzen, sanfter Einstieg mit den ersten vieren (wie beim Matching).
    final known = all
        .where((g) => (progress[g.id]?.status ?? 'neu') != 'neu')
        .toList();
    final letters = known.length >= 3 ? known : all.take(4).toList();
    final next =
        await _reading.nextGraphemeToTeach(widget.child.id, 'buchstabe');
    if (!mounted) return;
    setState(() {
      _letters = letters;
      _loading = false;
    });
    if (letters.isNotEmpty) {
      // „Nächster einzuführender" nur wählen, wenn er auch im Pool ist.
      final start = (next != null && letters.any((g) => g.id == next.id))
          ? next
          : letters.first;
      await _select(start);
    }
  }

  Future<void> _select(Grapheme g) async {
    final progress = await _reading.progressFor(widget.child.id);
    if (!mounted) return;
    setState(() {
      _selected = g;
      _box = progress[g.id]?.box ?? 1;
    });
  }

  void _next() {
    if (_selected == null || _letters.isEmpty) return;
    final i = _letters.indexWhere((g) => g.id == _selected!.id);
    _select(_letters[(i + 1) % _letters.length]);
  }

  void _showSuccess() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MenuIcon(id: 'feier_stern', emoji: '🌟', size: 64),
            SizedBox(height: 12),
            Text('Schön geschrieben!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _nonce++); // frische Fläche
            },
            child: const Text('Nochmal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _next();
            },
            child: const Text('Nächster Buchstabe'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    return Scaffold(
      appBar: AppBar(
        title: Text('Schreiben · ${widget.child.name}'),
        actions: [
          IconButton(
            tooltip: 'Groß malen (quer)',
            icon: const Icon(Icons.fullscreen_rounded),
            onPressed: selected == null
                ? null
                : () => openTracerFullscreen(
                      context,
                      glyph: selected.symbol,
                      box: _box,
                    ),
          ),
        ],
      ),
      body: SafeArea(
        child: (_loading || selected == null)
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _letterSelector(),
                    const SizedBox(height: 8),
                    const _Hint(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: LetterTracer(
                        key: ValueKey('${selected.symbol}-$_nonce'),
                        glyph: selected.symbol,
                        box: _box,
                        onSolved: _showSuccess,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _letterSelector() {
    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final g in _letters)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(g.symbol, style: const TextStyle(fontSize: 20)),
                selected: _selected?.id == g.id,
                onSelected: (_) => _select(g),
              ),
            ),
        ],
      ),
    );
  }
}

/// Freundlicher Hinweis über der Nachfahr-Fläche.
class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MenuIcon(id: 'lese_schreiben', emoji: '✏️', size: 26),
        SizedBox(width: 8),
        Text('Fahr den Buchstaben mit dem Finger oder Stift nach.',
            style: TextStyle(fontSize: 15, color: Colors.black54)),
      ],
    );
  }
}
