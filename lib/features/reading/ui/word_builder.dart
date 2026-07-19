import 'package:flutter/material.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/tile_style.dart';
import '../phonics_player.dart';

/// Ein Buchstabe in der Buchstaben-Kiste.
class _Tile {
  _Tile(this.char);
  final String char;
  bool used = false;
}

/// Bewegliches Alphabet: das Kind baut [target] aus Lauten zusammen. Jeder
/// gelegte Buchstabe spricht seinen Anlaut; bei komplettem, richtigem Wort wird
/// [onSolved] gerufen (und das Wort vorgelesen). Zeigt nie einen Fehlerfall.
///
/// Zum Neustart (anderes Wort / „nochmal") das Widget per Key neu aufbauen.
class WordBuilder extends StatefulWidget {
  const WordBuilder({
    super.key,
    required this.target,
    required this.onSolved,
    this.header,
  });

  final String target;
  final VoidCallback onSolved;

  /// Optionaler Kopf (Bild oder Beschriftung) über den Slots.
  final Widget? header;

  @override
  State<WordBuilder> createState() => _WordBuilderState();
}

class _WordBuilderState extends State<WordBuilder> {
  final _audio = getIt<AudioService>();
  final _phonics = getIt<PhonicsPlayer>();

  late final List<_Tile> _bank =
      widget.target.split('').map(_Tile.new).toList()..shuffle();
  final List<int> _placed = [];
  bool _solved = false;

  void _place(int bankIndex) {
    if (_solved || _bank[bankIndex].used) return;
    setState(() {
      _bank[bankIndex].used = true;
      _placed.add(bankIndex);
    });
    _phonics.playChar(_bank[bankIndex].char);
    if (_placed.length == _bank.length) {
      final assembled = _placed.map((i) => _bank[i].char).join();
      if (assembled.toLowerCase() == widget.target.toLowerCase()) {
        setState(() => _solved = true);
        _audio.speak(widget.target);
        widget.onSolved();
      }
    }
  }

  void _backspace() {
    if (_solved || _placed.isEmpty) return;
    setState(() {
      final i = _placed.removeLast();
      _bank[i].used = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Bild/Kopf füllt den Platz oben, Platzhalter darunter, Buchstaben unten.
    return Column(
      children: [
        Expanded(child: widget.header ?? const SizedBox()),
        const SizedBox(height: 12),
        _slots(),
        const SizedBox(height: 20),
        _bankRow(),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _placed.isEmpty ? null : _backspace,
            icon: const Icon(Icons.backspace_outlined),
            label: const Text('Zurück'),
          ),
        ),
      ],
    );
  }

  Widget _slots() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < widget.target.length; i++)
          Container(
            width: 52,
            height: 64,
            alignment: Alignment.center,
            decoration: i < _placed.length
                ? TileStyle.surface(const Color(0xFFA5D6A7),
                    radius: 14, depth: 0.5)
                : BoxDecoration(
                    color: const Color(0x14000000),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.black12, width: 2),
                  ),
            child: Text(
              i < _placed.length ? _bank[_placed[i]].char : '',
              style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: TileStyle.ink),
            ),
          ),
      ],
    );
  }

  Widget _bankRow() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        for (var i = 0; i < _bank.length; i++)
          Opacity(
            opacity: _bank[i].used ? 0.25 : 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () => _place(i),
              child: Container(
                width: 60,
                height: 72,
                alignment: Alignment.center,
                decoration: TileStyle.surface(const Color(0xFFFFCC80),
                    radius: 16, depth: 0.55),
                child: Text(_bank[i].char,
                    style: const TextStyle(
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: TileStyle.ink)),
              ),
            ),
          ),
      ],
    );
  }
}
