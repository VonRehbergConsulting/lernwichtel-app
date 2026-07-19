import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../trace_score.dart';

/// Ein einzelner Strich: Punkte + zugehörige Breite (aus dem Stift-Druck).
class Stroke {
  Stroke(this.color);
  final Color color;
  final List<Offset> points = [];
  final List<double> widths = [];
}

/// Hält die gezeichneten Striche und die aktuelle Zeichenfläche-Größe.
class TracingController extends ChangeNotifier {
  final List<Stroke> strokes = [];
  Size canvasSize = Size.zero;

  bool get isEmpty => strokes.every((s) => s.points.isEmpty);

  void clear() {
    strokes.clear();
    notifyListeners();
  }
}

/// Nachfahr-Fläche: zeigt den blassen Buchstaben als Vorlage und lässt mit
/// Finger ODER Stift darüber malen. Bei aktivem Stift werden Finger-/Handballen-
/// Berührungen ignoriert (Palm-Rejection). Der Stift-Druck steuert die Strichbreite.
class TracingCanvas extends StatefulWidget {
  const TracingCanvas({
    super.key,
    required this.controller,
    required this.glyph,
    this.onStrokeEnd,
  });

  final TracingController controller;
  final String glyph;

  /// Wird gerufen, sobald ein Strich abgesetzt wird (Finger/Stift hoch) – für
  /// die automatische Prüfung.
  final VoidCallback? onStrokeEnd;

  @override
  State<TracingCanvas> createState() => _TracingCanvasState();
}

class _TracingCanvasState extends State<TracingCanvas> {
  bool _stylusSeen = false;

  // Dicker, gleichmäßiger „Edding"-Strich in kräftigem Marker-Blau.
  static const _base = 17.0;
  static const _ink = Color(0xFF3949AB);

  double _width(PointerEvent e) {
    // Finger -> feste Breite; Stift variiert nur leicht (Marker bleibt dick).
    if (e.kind != PointerDeviceKind.stylus || e.pressure <= 0) return _base;
    return _base * (0.85 + 0.3 * e.pressure.clamp(0.0, 1.0));
  }

  bool _ignore(PointerEvent e) =>
      _stylusSeen && e.kind != PointerDeviceKind.stylus;

  void _start(PointerDownEvent e) {
    if (e.kind == PointerDeviceKind.stylus) _stylusSeen = true;
    if (_ignore(e)) return;
    final stroke = Stroke(_ink)
      ..points.add(e.localPosition)
      ..widths.add(_width(e));
    widget.controller.strokes.add(stroke);
    setState(() {});
  }

  void _move(PointerMoveEvent e) {
    if (_ignore(e) || widget.controller.strokes.isEmpty) return;
    widget.controller.strokes.last
      ..points.add(e.localPosition)
      ..widths.add(_width(e));
    setState(() {});
  }

  void _end(PointerEvent e) {
    if (_ignore(e)) return;
    widget.onStrokeEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        widget.controller.canvasSize =
            Size(constraints.maxWidth, constraints.maxHeight);
        return Listener(
          onPointerDown: _start,
          onPointerMove: _move,
          onPointerUp: _end,
          onPointerCancel: _end,
          child: CustomPaint(
            painter: _TracePainter(
              glyph: widget.glyph,
              strokes: widget.controller.strokes,
            ),
            size: Size.infinite,
          ),
        );
      },
    );
  }
}

class _TracePainter extends CustomPainter {
  _TracePainter({required this.glyph, required this.strokes});

  final String glyph;
  final List<Stroke> strokes;

  @override
  void paint(Canvas canvas, Size size) {
    // Blasse Buchstaben-Vorlage, zentriert.
    final tp = TextPainter(
      text: TextSpan(
        text: glyph,
        style: TextStyle(
          fontSize: size.height * kGlyphHeightFactor,
          fontWeight: FontWeight.w700,
          // Warmer Amber-Stencil – freundlicher als blasses Grau.
          color: const Color(0x40F2994A),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
    );

    // Gezeichnete Striche: je Strich ein glatter Pfad mit gleichmäßiger Breite
    // (dicker Marker-Look statt ungleicher Segmente).
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;
      final width = stroke.widths.isEmpty
          ? 17.0
          : stroke.widths.reduce((a, b) => a + b) / stroke.widths.length;
      final paint = Paint()
        ..color = stroke.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      if (stroke.points.length == 1) {
        canvas.drawCircle(
            stroke.points.first, width / 2, Paint()..color = stroke.color);
        continue;
      }
      final path = Path()
        ..moveTo(stroke.points.first.dx, stroke.points.first.dy);
      for (var i = 1; i < stroke.points.length; i++) {
        path.lineTo(stroke.points[i].dx, stroke.points[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_TracePainter old) => true;
}
