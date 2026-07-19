import 'package:flutter/material.dart';

import '../trace_score.dart';
import 'tracing_canvas.dart';

/// Wiederverwendbare Nachfahr-Fläche für genau einen Buchstaben: baut die Prüf-
/// Maske (im Seitenverhältnis der Fläche), prüft automatisch beim Absetzen und
/// meldet über [onSolved], sobald das Nachfahren angenommen wird (Abdeckung +
/// Genauigkeit, adaptiv nach [box]). Zeigt nie einen Fehlerfall – ein „noch
/// nicht" bleibt einfach still.
class LetterTracer extends StatefulWidget {
  const LetterTracer({
    super.key,
    required this.glyph,
    required this.box,
    required this.onSolved,
  });

  final String glyph;

  /// Leitner-Box des Buchstabens -> steuert die Toleranz.
  final int box;

  /// Wird einmal gerufen, sobald das Nachfahren angenommen wird.
  final VoidCallback onSolved;

  @override
  State<LetterTracer> createState() => _LetterTracerState();
}

class _LetterTracerState extends State<LetterTracer> {
  final _controller = TracingController();
  LetterMask? _mask;
  String? _builtKey; // glyph@aspect der fertigen Maske
  String? _buildingKey; // glyph@aspect der laufenden Berechnung
  bool _solved = false;

  @override
  void didUpdateWidget(LetterTracer old) {
    super.didUpdateWidget(old);
    if (old.glyph != widget.glyph) {
      _controller.clear();
      setState(() {
        _mask = null;
        _builtKey = null;
        _solved = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Baut die Maske für die aktuelle Fläche, falls Buchstabe oder
  /// Seitenverhältnis sich geändert haben. Wird aus dem LayoutBuilder gerufen.
  void _ensureMask(Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final aspect = size.width / size.height;
    final key = '${widget.glyph}@${aspect.toStringAsFixed(2)}';
    if (key == _builtKey || key == _buildingKey) return;
    _buildingKey = key;
    buildLetterMask(glyph: widget.glyph, aspect: aspect).then((mask) {
      if (!mounted || _buildingKey != key) return;
      _controller.clear();
      setState(() {
        _mask = mask;
        _builtKey = key;
        _buildingKey = null;
        _solved = false;
      });
    });
  }

  void _clear() {
    _controller.clear();
    setState(() => _solved = false);
  }

  void _onStrokeEnd() {
    if (_solved || _mask == null || _controller.isEmpty) return;
    final strokes = _controller.strokes.map((s) => s.points).toList();
    if (traceAccepted(_mask!, strokes, _controller.canvasSize, widget.box)) {
      setState(() => _solved = true);
      widget.onSolved();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              // Warmer „Papier"-Ton statt klinischem Weiß + weicher Schatten.
              color: const Color(0xFFFFFDF6),
              border: Border.all(color: const Color(0xFFEADDC7), width: 2),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A000000),
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);
                _ensureMask(size);
                if (_mask == null) {
                  return const Center(child: CircularProgressIndicator());
                }
                return TracingCanvas(
                  controller: _controller,
                  glyph: widget.glyph,
                  onStrokeEnd: _onStrokeEnd,
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: OutlinedButton.icon(
            onPressed: _clear,
            icon: const Icon(Icons.refresh),
            label: const Text('Nochmal'),
          ),
        ),
      ],
    );
  }
}
