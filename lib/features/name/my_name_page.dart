import 'package:flutter/material.dart';

import '../../core/audio/audio_service.dart';
import '../../core/di/service_locator.dart';
import '../../core/widgets/menu_icon.dart';
import '../../data/db/database.dart';
import '../reading/phonics_player.dart';
import '../reading/ui/word_builder.dart';
import '../writing/ui/letter_tracer.dart';

enum _Mode { lesen, schreiben, bauen }

/// „Mein Name": das Kind liest, baut und schreibt seinen eigenen Namen –
/// das motivierendste Wort überhaupt. Freigeschaltet, wenn alle nötigen
/// Buchstaben sitzen.
class MyNamePage extends StatefulWidget {
  const MyNamePage({super.key, required this.child});

  final Child child;

  @override
  State<MyNamePage> createState() => _MyNamePageState();
}

class _MyNamePageState extends State<MyNamePage> {
  final _audio = getIt<AudioService>();
  final _phonics = getIt<PhonicsPlayer>();

  _Mode _mode = _Mode.lesen;

  /// Buchstaben des Namens in Reihenfolge (mit Wiederholungen) – fürs Schreiben.
  late final List<String> _letters = widget.child.name
      .split('')
      .where((c) => RegExp(r'[A-Za-zÄÖÜäöüß]').hasMatch(c))
      .toList();
  int _writeIndex = 0;
  int _buildNonce = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mein Name · ${widget.child.name}')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _modeToggle(),
              const SizedBox(height: 20),
              Expanded(
                child: switch (_mode) {
                  _Mode.lesen => _readView(),
                  _Mode.schreiben => _writeView(),
                  _Mode.bauen => _buildView(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Festes 3-Wege-Pill-Toggle (springt nicht wie der SegmentedButton).
  Widget _modeToggle() {
    final scheme = Theme.of(context).colorScheme;
    Widget tab(_Mode m, String label) {
      final selected = _mode == m;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() {
            _mode = m;
            _writeIndex = 0;
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.all(4),
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? scheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: selected ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          tab(_Mode.lesen, 'Lesen'),
          tab(_Mode.schreiben, 'Schreiben'),
          tab(_Mode.bauen, 'Bauen'),
        ],
      ),
    );
  }

  Widget _readView() {
    return Column(
      children: [
        const Text('Tippe die Buchstaben – oder hör deinen ganzen Namen.',
            style: TextStyle(color: Colors.black54), textAlign: TextAlign.center),
        const SizedBox(height: 24),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            for (final ch in _letters)
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => _phonics.playChar(ch),
                child: Container(
                  width: 64,
                  height: 80,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFB3E5FC),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(ch,
                      style: const TextStyle(
                          fontSize: 44, fontWeight: FontWeight.w700)),
                ),
              ),
          ],
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: () => _audio.speak(widget.child.name),
          icon: const Icon(Icons.volume_up),
          label: const Text('Ganzen Namen hören'),
        ),
      ],
    );
  }

  Widget _writeView() {
    if (_writeIndex >= _letters.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const MenuIcon(id: 'feier_stern', emoji: '🌟', size: 80),
            const SizedBox(height: 12),
            Text('Du hast ${widget.child.name} geschrieben!',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => setState(() => _writeIndex = 0),
              child: const Text('Nochmal'),
            ),
          ],
        ),
      );
    }
    return Column(
      children: [
        Text('Buchstabe ${_writeIndex + 1} von ${_letters.length}',
            style: const TextStyle(fontSize: 16, color: Colors.black54)),
        const SizedBox(height: 8),
        Expanded(
          child: LetterTracer(
            key: ValueKey(_writeIndex),
            glyph: _letters[_writeIndex],
            box: 1,
            onSolved: () {
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) setState(() => _writeIndex++);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildView() {
    return WordBuilder(
      key: ValueKey('name-build-$_buildNonce'),
      target: widget.child.name,
      header: Center(
        child: Text(
          'Bau deinen Namen',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      onSolved: _showBuildSuccess,
    );
  }

  void _showBuildSuccess() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const MenuIcon(id: 'feier_stern', emoji: '🌟', size: 64),
            const SizedBox(height: 12),
            Text('${widget.child.name} – super gebaut!',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() => _buildNonce++);
            },
            child: const Text('Nochmal'),
          ),
        ],
      ),
    );
  }
}
