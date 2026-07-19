import 'dart:math';

import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/repositories/reading_repository.dart';
import '../../guided/lesson_widgets.dart';
import '../phonics_player.dart';

/// Baut eine Matching-Runde: Ziel + [distractors] Ablenker aus [pool], gemischt.
List<T> pickMatchRound<T>(
  List<T> pool,
  T target, {
  int distractors = 2,
  Random? rnd,
}) {
  final r = rnd ?? Random();
  final others = pool.where((e) => e != target).toList()..shuffle(r);
  return [target, ...others.take(distractors)]..shuffle(r);
}

/// „Groß & klein": Zu einem großen Buchstaben den passenden kleinen finden.
/// Verknüpft die beiden Schreibweisen spielerisch (die App bleibt sonst klein).
class LetterMatchPage extends StatefulWidget {
  const LetterMatchPage({super.key, required this.child});

  final Child child;

  @override
  State<LetterMatchPage> createState() => _LetterMatchPageState();
}

class _LetterMatchPageState extends State<LetterMatchPage> {
  final _content = getIt<ContentRepository>();
  final _reading = getIt<ReadingRepository>();
  final _phonics = getIt<PhonicsPlayer>();
  final _rnd = Random();

  List<Grapheme> _pool = const [];
  Grapheme? _target;
  List<Grapheme> _options = const [];
  int? _wrongId;
  int _solved = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final graphemes = await _content.graphemesByKind('buchstabe');
    final progress = await _reading.progressFor(widget.child.id);
    // Bevorzugt schon eingeführte Buchstaben; sonst die ersten paar.
    final known = graphemes
        .where((g) => (progress[g.id]?.status ?? 'neu') != 'neu')
        .toList();
    final pool = known.length >= 3 ? known : graphemes.take(4).toList();
    if (!mounted) return;
    setState(() {
      _pool = pool;
      _loading = false;
    });
    if (pool.isNotEmpty) _nextRound();
  }

  void _nextRound() {
    if (_pool.isEmpty) return;
    final target = _pool[_rnd.nextInt(_pool.length)];
    setState(() {
      _target = target;
      _options = pickMatchRound(_pool, target, rnd: _rnd);
      _wrongId = null;
    });
  }

  void _onTap(Grapheme g) {
    final target = _target;
    if (target == null) return;
    if (g.id == target.id) {
      _phonics.playChar(g.symbol);
      setState(() => _solved++);
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(const SnackBar(
          duration: Duration(milliseconds: 900),
          content: Text('🌟 Richtig!'),
        ));
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) _nextRound();
      });
    } else {
      setState(() => _wrongId = g.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final target = _target;
    return Scaffold(
      appBar: AppBar(title: Text('Groß & klein · ${widget.child.name}')),
      body: SafeArea(
        child: (_loading || target == null)
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text('Welcher kleine Buchstabe passt?',
                        style: TextStyle(fontSize: 18, color: Colors.black54)),
                    const SizedBox(height: 16),
                    LessonGlyphCard(target.symbol.toUpperCase()),
                    const Spacer(),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final g in _options)
                          Opacity(
                            opacity: _wrongId == g.id ? 0.3 : 1,
                            child: LessonOptionTile(
                              text: g.symbol,
                              onTap: () => _onTap(g),
                            ),
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text('Schon $_solved geschafft',
                        style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
      ),
    );
  }
}
