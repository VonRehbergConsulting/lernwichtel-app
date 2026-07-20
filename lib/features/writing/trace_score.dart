import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Höhe des Buchstabens als Anteil der Zeichenfläche. MUSS in der Vorlage
/// (TracingCanvas) und der Prüf-Maske (buildLetterMask) identisch sein, sonst
/// stimmt der Abgleich nicht. Bei 1.0 passt die volle Buchstabenhöhe inkl.
/// Unterlänge (y, p, g, j) in die Fläche – nichts ragt mehr heraus.
const double kGlyphHeightFactor = 1.0;

/// Grobes Raster (cols×rows) der "Buchstaben-Fläche" – die Soll-Form, über die
/// nachgefahren werden soll. `on[r*cols+c]` = gehört diese Zelle zum Buchstaben.
class LetterMask {
  const LetterMask(this.cols, this.rows, this.on);

  final int cols;
  final int rows;
  final List<bool> on;

  bool at(int c, int r) => on[r * cols + c];

  int get onCount {
    var n = 0;
    for (final v in on) {
      if (v) n++;
    }
    return n;
  }
}

/// Menge der Soll-Zellen, die von den Strichen getroffen wurden (mit [brush]
/// Zellen Toleranz – eine dünne Linie füllt die dickere Fläche großzügig).
Set<int> tracedGlyphCells(
  LetterMask mask,
  List<List<Offset>> strokes,
  Size size, {
  int brush = 1,
}) {
  final visitedOn = <int>{};
  if (size.width <= 0 || size.height <= 0) return visitedOn;
  for (final stroke in strokes) {
    for (final p in stroke) {
      final c = (p.dx / size.width * mask.cols).floor();
      final r = (p.dy / size.height * mask.rows).floor();
      for (var dc = -brush; dc <= brush; dc++) {
        for (var dr = -brush; dr <= brush; dr++) {
          final cc = c + dc;
          final rr = r + dr;
          if (cc < 0 || cc >= mask.cols || rr < 0 || rr >= mask.rows) continue;
          if (mask.at(cc, rr)) visitedOn.add(rr * mask.cols + cc);
        }
      }
    }
  }
  return visitedOn;
}

/// Anteil der Soll-Fläche (0..1), der getroffen wurde.
double traceCoverage(
  LetterMask mask,
  List<List<Offset>> strokes,
  Size size, {
  int brush = 1,
}) {
  final total = mask.onCount;
  if (total == 0) return 0;
  return tracedGlyphCells(mask, strokes, size, brush: brush).length / total;
}

/// Zerlegt die Soll-Fläche in zusammenhängende Teile (8er-Nachbarschaft) –
/// z. B. a-Körper + die zwei Ä-Punkte. Winzige Fragmente (< 3 Zellen,
/// Rendering-Rauschen) werden ignoriert. So kann jeder Teil einzeln geprüft
/// werden und die Bestätigung kommt erst, wenn ALLES nachgefahren ist.
List<List<int>> letterComponents(LetterMask mask) {
  final seen = List<bool>.filled(mask.cols * mask.rows, false);
  final comps = <List<int>>[];
  for (var start = 0; start < mask.on.length; start++) {
    if (!mask.on[start] || seen[start]) continue;
    final comp = <int>[];
    final stack = <int>[start];
    seen[start] = true;
    while (stack.isNotEmpty) {
      final cur = stack.removeLast();
      comp.add(cur);
      final cr = cur ~/ mask.cols;
      final cc = cur % mask.cols;
      for (var dr = -1; dr <= 1; dr++) {
        for (var dc = -1; dc <= 1; dc++) {
          if (dr == 0 && dc == 0) continue;
          final nr = cr + dr;
          final nc = cc + dc;
          if (nr < 0 || nr >= mask.rows || nc < 0 || nc >= mask.cols) continue;
          final nidx = nr * mask.cols + nc;
          if (mask.on[nidx] && !seen[nidx]) {
            seen[nidx] = true;
            stack.add(nidx);
          }
        }
      }
    }
    if (comp.length >= 3) comps.add(comp);
  }
  return comps;
}

/// Genauigkeit (0..1): Anteil der gezeichneten Punkte, die auf der Soll-Fläche
/// liegen (mit [brush] Toleranz). Niedrig, wenn quer über das Feld gekritzelt
/// wird – so wird bloßes Vollmalen nicht als Treffer gewertet.
double tracePrecision(
  LetterMask mask,
  List<List<Offset>> strokes,
  Size size, {
  int brush = 1,
}) {
  if (mask.onCount == 0 || size.width <= 0 || size.height <= 0) return 0;

  var onLetter = 0;
  var total = 0;
  for (final stroke in strokes) {
    for (final p in stroke) {
      total++;
      final c = (p.dx / size.width * mask.cols).floor();
      final r = (p.dy / size.height * mask.rows).floor();
      var hit = false;
      for (var dc = -brush; dc <= brush && !hit; dc++) {
        for (var dr = -brush; dr <= brush && !hit; dr++) {
          final cc = c + dc;
          final rr = r + dr;
          if (cc < 0 || cc >= mask.cols || rr < 0 || rr >= mask.rows) continue;
          if (mask.at(cc, rr)) hit = true;
        }
      }
      if (hit) onLetter++;
    }
  }
  return total == 0 ? 0 : onLetter / total;
}

/// Gesamturteil: das Nachfahren gilt, wenn genug der Vorlage abgedeckt wurde
/// UND die Linie überwiegend auf dem Buchstaben blieb. Beide Schwellen wachsen
/// mit der Leitner-Box (neu = sehr tolerant, sicher = streng).
/// Gesamturteil. Die Abdeckung wird mit einem größeren Pinsel gemessen (eine
/// dünne Linie soll die dickere Buchstaben-Fläche großzügig füllen), die
/// Genauigkeit mit einem kleineren (Abweichen soll spürbar zählen). Für Tests
/// lässt sich [brush] setzen und überschreibt beide.
bool traceAccepted(
  LetterMask mask,
  List<List<Offset>> strokes,
  Size size,
  int box, {
  int? brush,
}) {
  final comps = letterComponents(mask);
  if (comps.isEmpty) return false;

  final visited = tracedGlyphCells(mask, strokes, size, brush: brush ?? 2);
  final need = coverageThreshold(box);
  // JEDER Teil (auch die Ä-Punkte) muss ausreichend abgedeckt sein.
  for (final comp in comps) {
    final hit = comp.where(visited.contains).length;
    if (hit / comp.length < need) return false;
  }

  final prec = tracePrecision(mask, strokes, size, brush: brush ?? 1);
  return prec >= precisionThreshold(box);
}

/// Nötige Abdeckung je Leitner-Box: neu (1) sehr tolerant, sicher (3) strenger.
/// So wächst der Anspruch mit dem Lernstand des Buchstabens.
double coverageThreshold(int box) => switch (box) {
      <= 1 => 0.60,
      2 => 0.72,
      _ => 0.82,
    };

/// Nötige Genauigkeit je Leitner-Box (wie viel der Linie auf dem Buchstaben
/// liegen muss). Ebenfalls tolerant für neue Buchstaben.
double precisionThreshold(int box) => switch (box) {
      <= 1 => 0.35,
      2 => 0.50,
      _ => 0.62,
    };

/// Rendert einen Buchstaben in ein Raster IM SELBEN Seitenverhältnis wie die
/// Zeichenfläche ([aspect] = Breite/Höhe) und liest die Soll-Fläche aus den
/// Alpha-Werten. Nur so deckt sich die Maske mit der sichtbaren Vorlage.
Future<LetterMask> buildLetterMask({
  required String glyph,
  required double aspect,
  int rows = 34,
  int scale = 6,
}) async {
  final cols = (rows * aspect).round().clamp(8, 256);
  final w = cols * scale;
  final h = rows * scale;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final tp = TextPainter(
    text: TextSpan(
      text: glyph,
      style: TextStyle(
        fontSize: h * kGlyphHeightFactor,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF000000),
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  tp.paint(canvas, Offset((w - tp.width) / 2, (h - tp.height) / 2));

  final img = await recorder.endRecording().toImage(w, h);
  final data = await img.toByteData();
  img.dispose();

  final on = List<bool>.filled(cols * rows, false);
  if (data == null) return LetterMask(cols, rows, on);

  for (var r = 0; r < rows; r++) {
    for (var c = 0; c < cols; c++) {
      var hit = false;
      for (var yy = 0; yy < scale && !hit; yy++) {
        for (var xx = 0; xx < scale && !hit; xx++) {
          final px = c * scale + xx;
          final py = r * scale + yy;
          final idx = (py * w + px) * 4 + 3; // Alpha-Kanal
          if (data.getUint8(idx) > 40) hit = true;
        }
      }
      on[r * cols + c] = hit;
    }
  }
  return LetterMask(cols, rows, on);
}
