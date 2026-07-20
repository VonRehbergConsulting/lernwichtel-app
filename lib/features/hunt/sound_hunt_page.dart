import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/di/service_locator.dart';
import '../../core/widgets/menu_icon.dart';
import '../../data/db/database.dart';
import '../../data/repositories/fund_repository.dart';
import '../../data/repositories/reading_repository.dart';

/// Laut-Schatzsuche (Foto-Brücke).
///
/// Off-Screen gedacht: Kind & Eltern suchen in der Wohnung etwas, das mit dem
/// Laut anfängt, und fotografieren es. Danach **benennen die Eltern das Objekt**
/// (ein Wort). Passt es zu einem vorhandenen Wort, kann das Foto dessen Bild
/// ersetzen; sonst wird ein **neues Wort** angelegt, das ab dann in den Wort-
/// und Laut-Übungen auftaucht. Das Foto bleibt zugleich als „Fundstück".
class SoundHuntPage extends StatefulWidget {
  const SoundHuntPage({
    super.key,
    required this.sound,
    required this.letter,
    required this.childId,
  });

  final String sound;

  /// Anfangs-Laut/-Buchstabe der Jagd (z. B. "m") – für den Fundstück-Bezug.
  final String letter;

  /// Kind, dem das Fundstück-Foto zugeordnet wird.
  final int childId;

  @override
  State<SoundHuntPage> createState() => _SoundHuntPageState();
}

class _SoundHuntPageState extends State<SoundHuntPage> {
  final _picker = ImagePicker();
  final _funds = getIt<FundRepository>();
  final _reading = getIt<ReadingRepository>();
  final _name = TextEditingController();

  XFile? _photo;
  int _found = 0;
  bool _saving = false;

  List<Word> _matches = const [];
  Word? _existing; // exakter Treffer zur aktuellen Eingabe

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    final x = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1280,
    );
    if (x == null || !mounted) return;
    setState(() {
      _photo = x;
      _name.clear();
      _matches = const [];
      _existing = null;
    });
  }

  Future<void> _onNameChanged(String value) async {
    final q = value.trim();
    final matches = await _reading.searchWords(q);
    final existing = await _reading.findWordByText(q);
    if (!mounted || _name.text.trim() != q) return; // veraltete Antwort
    setState(() {
      _matches = matches;
      _existing = existing;
    });
  }

  void _pickSuggestion(Word w) {
    _name.text = w.word;
    _name.selection = TextSelection.collapsed(offset: _name.text.length);
    setState(() {
      _matches = const [];
      _existing = w;
    });
  }

  void _retake() => setState(() {
    _photo = null;
    _name.clear();
    _matches = const [];
    _existing = null;
  });

  /// Kopiert das Foto dauerhaft (Fundstück) und ordnet es optional einem Wort
  /// zu: bestehendes überschreiben ODER neues Wort anlegen.
  Future<void> _save({Word? existing, String? newWord}) async {
    if (_photo == null || _saving) return;
    setState(() => _saving = true);
    try {
      final fund = await _funds.save(
        childId: widget.childId,
        letter: widget.letter,
        sourcePath: _photo!.path,
      );
      String message;
      if (existing != null) {
        await _reading.setWordImage(existing.id, fund.filePath, existing.word);
        message = 'Foto für „${existing.word}" gespeichert.';
      } else if (newWord != null && newWord.trim().isNotEmpty) {
        final w = await _reading.createWordWithImage(
          newWord.trim(),
          fund.filePath,
        );
        message = '„${w.word}" als neues Wort angelegt.';
      } else {
        message = '📸 Im Fundstück-Album gespeichert.';
      }
      if (!mounted) return;
      setState(() {
        _found++;
        _photo = null;
        _name.clear();
        _matches = const [];
        _existing = null;
        _saving = false;
      });
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 2),
            content: Text(message),
          ),
        );
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speichern fehlgeschlagen. Nochmal?')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Laut-Schatzsuche')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _photo == null ? _searchView() : _reviewView(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _searchView() {
    return Column(
      children: [
        const Text(
          'Sucht zusammen etwas, das mit',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFE0B2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '„${widget.sound}"',
            style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'anfängt – und fotografiert es!',
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        const Spacer(),
        if (_found > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'Schon $_found gefunden 🌟',
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
          ),
        FilledButton.icon(
          onPressed: _capture,
          icon: const Icon(Icons.photo_camera),
          label: Text(_found == 0 ? 'Foto machen' : 'Nächstes Foto'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            textStyle: const TextStyle(fontSize: 20),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_found),
          child: Text(_found == 0 ? 'Abbrechen' : 'Fertig'),
        ),
      ],
    );
  }

  Widget _reviewView() {
    final name = _name.text.trim();
    // Scrollbar, damit die Tastatur bei der Namenseingabe nichts verdeckt.
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 280),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(File(_photo!.path), fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _name,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            style: const TextStyle(fontSize: 22),
            decoration: const InputDecoration(
              labelText: 'Wie heißt das?',
              hintText: 'z. B. Ball',
              prefixIcon: Icon(Icons.edit_outlined),
            ),
            onChanged: _onNameChanged,
          ),
          // Vorschläge aus vorhandenen Wörtern.
          if (_matches.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final w in _matches)
                    ActionChip(
                      avatar: const Icon(Icons.image_outlined, size: 18),
                      label: Text(w.word),
                      onPressed: () => _pickSuggestion(w),
                    ),
                ],
              ),
            ),
          if (_existing != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Ersetzt das Bild von „${_existing!.word}".',
                style: const TextStyle(color: Colors.black54),
              ),
            ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saving ? null : _retake,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Nochmal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: (_saving || name.isEmpty)
                      ? null
                      : () => _existing != null
                            ? _save(existing: _existing)
                            : _save(newWord: name),
                  icon: Icon(_existing != null ? Icons.check : Icons.add),
                  label: Text(
                    _existing != null
                        ? 'Für „$name" nehmen'
                        : name.isEmpty
                        ? 'Name eingeben'
                        : '„$name" anlegen',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _saving ? null : () => _save(),
              child: const Text('Ohne Namen nur behalten'),
            ),
          ),
          const SizedBox(height: 4),
          const Center(
            child: MenuIcon(id: 'such_lupe', emoji: '🔎', size: 30),
          ),
        ],
      ),
    );
  }
}
