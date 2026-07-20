import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/orientation_lock.dart';
import '../../../core/widgets/menu_icon.dart';
import 'letter_tracer.dart';

/// Öffnet den Nachfahr-Bereich im **Vollbild** – und dreht dabei auf dem Handy
/// ins **Querformat**, damit die Mal-Fläche maximal groß wird. [onSolved]
/// wird für Seiteneffekte des Aufrufers aufgerufen (z. B. „geschrieben" merken).
Future<void> openTracerFullscreen(
  BuildContext context, {
  required String glyph,
  required int box,
  VoidCallback? onSolved,
}) {
  return Navigator.of(context).push(MaterialPageRoute<void>(
    fullscreenDialog: true,
    builder: (_) =>
        TracerFullscreenPage(glyph: glyph, box: box, onSolved: onSolved),
  ));
}

class TracerFullscreenPage extends StatefulWidget {
  const TracerFullscreenPage({
    super.key,
    required this.glyph,
    required this.box,
    this.onSolved,
  });

  final String glyph;
  final int box;
  final VoidCallback? onSolved;

  @override
  State<TracerFullscreenPage> createState() => _TracerFullscreenPageState();
}

class _TracerFullscreenPageState extends State<TracerFullscreenPage> {
  int _nonce = 0;
  bool _done = false;
  bool _isTablet = false;

  @override
  void initState() {
    super.initState();
    _isTablet = primaryViewIsTablet();
    // Vollbild quer für maximale Mal-Fläche (auf dem Tablet ohnehin quer).
    SystemChrome.setPreferredOrientations(preferredOrientationsFor(tablet: true));
  }

  @override
  void dispose() {
    // Geräteklassen-Standard wiederherstellen (OrientationLock feuert nicht neu,
    // da die Geräteklasse gleich bleibt).
    SystemChrome.setPreferredOrientations(
      preferredOrientationsFor(tablet: _isTablet),
    );
    super.dispose();
  }

  void _onSolved() {
    widget.onSolved?.call();
    if (mounted) setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: LetterTracer(
                  key: ValueKey('${widget.glyph}-$_nonce'),
                  glyph: widget.glyph,
                  box: widget.box,
                  onSolved: _onSolved,
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton.filledTonal(
                tooltip: 'Vollbild beenden',
                icon: const Icon(Icons.fullscreen_exit_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            if (_done)
              Positioned(
                left: 0,
                right: 0,
                bottom: 16,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: const [
                        BoxShadow(
                            color: Color(0x22000000),
                            blurRadius: 10,
                            offset: Offset(0, 4)),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const MenuIcon(id: 'feier_stern', emoji: '🌟', size: 28),
                        const SizedBox(width: 8),
                        const Text('Schön geschrieben!',
                            style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () => setState(() {
                            _done = false;
                            _nonce++;
                          }),
                          child: const Text('Nochmal'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Fertig'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
