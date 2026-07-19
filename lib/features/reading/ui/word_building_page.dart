import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/utils/slug.dart';
import '../../../core/widgets/menu_icon.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/progression_repository.dart';
import '../../../data/repositories/reading_repository.dart';
import '../word_gating.dart';
import 'word_builder.dart';

/// Ob ein Wort sich zum Bauen (bewegliches Alphabet) eignet: nur Buchstaben,
/// überschaubare Länge.
bool isBuildableWord(String word) {
  if (word.length < 3 || word.length > 6) return false;
  return RegExp(r'^[A-Za-zÄÖÜäöüß]+$').hasMatch(word);
}

/// Bewegliches Alphabet: das Kind baut ein Wort aus Lauten zusammen (Schreiben
/// vor Lesen). Zeigt Bild + Wort-Vorlesen und die Bau-Fläche ([WordBuilder]).
class WordBuildingPage extends StatefulWidget {
  const WordBuildingPage({super.key, required this.child});

  final Child child;

  @override
  State<WordBuildingPage> createState() => _WordBuildingPageState();
}

class _WordBuildingPageState extends State<WordBuildingPage> {
  final _progressionRepo = getIt<ProgressionRepository>();
  final _reading = getIt<ReadingRepository>();

  List<Word> _words = const [];
  Map<int, String> _imagePaths = const {};
  int _index = 0;
  int _nonce = 0; // frische Bau-Fläche bei „Nochmal"
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final all = await _progressionRepo.wordProgression();
    // Nur baubare Wörter, die sich vollständig in bekannte Bausteine zerlegen
    // lassen (eingeführte Buchstaben UND Silben) – so eilt das Bauen dem
    // Lektions-Fortschritt nicht voraus (z. B. „Stein" erst mit „st").
    final k = await _reading.readingKnowledge(widget.child.id);
    final words = all
        .where((w) =>
            isBuildableWord(w.word) &&
            unknownGraphemeParts(
                  w.word,
                  knownLetters: k.letters,
                  knownCombos: k.combos,
                  comboVocab: k.vocab,
                ) ==
                0)
        .toList();
    final paths =
        await _reading.imagePathsForWords(words.map((w) => w.id).toList());
    if (!mounted) return;
    setState(() {
      _words = words;
      _imagePaths = paths;
      _loading = false;
    });
  }

  Word? get _word => _words.isEmpty ? null : _words[_index];

  void _next() => setState(() {
        _index = (_index + 1) % _words.length;
        _nonce++;
      });

  void _showSuccess() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MenuIcon(id: 'feier_stern', emoji: '🌟', size: 64),
            const SizedBox(height: 12),
            Text('${_word!.word} – super gebaut!',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _nonce++);
            },
            child: const Text('Nochmal'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _next();
            },
            child: const Text('Nächstes Wort'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final word = _word;
    return Scaffold(
      appBar: AppBar(title: Text('Wörter bauen · ${widget.child.name}')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : word == null
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Noch nichts zum Bauen.\n'
                    'Führt zuerst ein paar Buchstaben mit den Eltern ein –\n'
                    'dann erscheinen hier passende Wörter.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(20),
                child: WordBuilder(
                  key: ValueKey('${word.word}-$_nonce'),
                  target: word.word,
                  onSolved: _showSuccess,
                  header: _WordHeader(
                    word: word.word,
                    imagePath: _imagePaths[word.id],
                  ),
                ),
              ),
      ),
    );
  }
}

/// Bild + „Wort anhören" über der Bau-Fläche.
class _WordHeader extends StatelessWidget {
  const _WordHeader({required this.word, required this.imagePath});

  final String word;
  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final custom = imagePath;
    final Widget img;
    if (custom != null && File(custom).existsSync()) {
      img = Image.file(File(custom), fit: BoxFit.contain);
    } else {
      img = Image.asset(
        'assets/images/standard/${wortSlug(word)}.webp',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stack) =>
            const Text('🖼️', style: TextStyle(fontSize: 120)),
      );
    }
    // Bild füllt den verfügbaren Platz oben, darunter der Hör-Knopf.
    return Column(
      children: [
        Expanded(child: Center(child: img)),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => getIt<AudioService>().speak(word),
          icon: const Icon(Icons.volume_up),
          label: const Text('Wort anhören'),
        ),
      ],
    );
  }
}
