import 'dart:ui';

import 'package:education_app/features/writing/trace_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 4x4-Raster, mittlere 2x2-Zellen sind der "Buchstabe".
  LetterMask centerMask() {
    final on = List<bool>.filled(16, false);
    for (final cell in [5, 6, 9, 10]) {
      on[cell] = true;
    }
    return LetterMask(4, 4, on);
  }

  const size = Size(4, 4); // 1 Einheit pro Zelle -> einfache Zuordnung

  test('volle Abdeckung, wenn alle Soll-Zellen getroffen sind', () {
    final mask = centerMask();
    // Punkte in der Mitte der vier Soll-Zellen (brush=0, exakt).
    final strokes = [
      [
        const Offset(1.5, 1.5),
        const Offset(2.5, 1.5),
        const Offset(1.5, 2.5),
        const Offset(2.5, 2.5),
      ],
    ];
    expect(traceCoverage(mask, strokes, size, brush: 0), 1.0);
  });

  test('keine Abdeckung ohne Striche', () {
    expect(traceCoverage(centerMask(), const [], size), 0.0);
  });

  test('teilweise Abdeckung liegt zwischen 0 und 1', () {
    final mask = centerMask();
    final strokes = [
      [const Offset(1.5, 1.5)], // nur eine der vier Soll-Zellen
    ];
    final cov = traceCoverage(mask, strokes, size, brush: 0);
    expect(cov, closeTo(0.25, 0.001));
  });

  test('Punkte außerhalb der Soll-Fläche zählen nicht', () {
    final mask = centerMask();
    final strokes = [
      [const Offset(0.5, 0.5), const Offset(3.5, 3.5)], // Ecken = leer
    ];
    expect(traceCoverage(mask, strokes, size, brush: 0), 0.0);
  });

  test('Schwellwert wächst mit der Leitner-Box', () {
    expect(coverageThreshold(1), lessThan(coverageThreshold(2)));
    expect(coverageThreshold(2), lessThan(coverageThreshold(3)));
    expect(precisionThreshold(1), lessThan(precisionThreshold(2)));
    expect(precisionThreshold(2), lessThan(precisionThreshold(3)));
    // Box 0/1 gleich tolerant behandelt.
    expect(coverageThreshold(0), coverageThreshold(1));
    expect(precisionThreshold(0), precisionThreshold(1));
  });

  test('Precision: alles auf dem Buchstaben -> 1.0', () {
    final mask = centerMask();
    final strokes = [
      [const Offset(1.5, 1.5), const Offset(2.5, 2.5)],
    ];
    expect(tracePrecision(mask, strokes, size, brush: 0), 1.0);
  });

  test('Precision: die Hälfte daneben -> 0.5', () {
    final mask = centerMask();
    final strokes = [
      [const Offset(1.5, 1.5), const Offset(0.5, 0.5)], // 1x drauf, 1x Ecke
    ];
    expect(tracePrecision(mask, strokes, size, brush: 0), closeTo(0.5, 0.001));
  });

  test('Vollkritzeln wird trotz hoher Abdeckung abgelehnt', () {
    final mask = centerMask();
    // Über das ganze 4x4-Feld gemalt: Abdeckung hoch, Genauigkeit niedrig.
    final scribble = <Offset>[];
    for (var y = 0; y < 4; y++) {
      for (var x = 0; x < 4; x++) {
        scribble.add(Offset(x + 0.5, y + 0.5));
      }
    }
    final strokes = [scribble];
    // Box 1 ist tolerant, aber die Genauigkeit (4 von 16 = 0.25) reißt die
    // Precision-Schwelle (0.35) -> abgelehnt.
    expect(traceAccepted(mask, strokes, size, 1, brush: 0), isFalse);
  });

  // 6x6-Raster: getrennter Punkt (Zeile 0) + Körper (Zeilen 3–5) – wie ein Ä.
  LetterMask twoPartMask() {
    final on = List<bool>.filled(36, false);
    for (final i in [1, 2, 3, 19, 20, 21, 25, 26, 27, 31, 32, 33]) {
      on[i] = true;
    }
    return LetterMask(6, 6, on);
  }

  const size6 = Size(6, 6);

  final body = [
    for (var r = 3; r <= 5; r++)
      for (var c = 1; c <= 3; c++) Offset(c + 0.5, r + 0.5),
  ];
  final dot = [for (var c = 1; c <= 3; c++) Offset(c + 0.5, 0.5)];

  test('Ä-artig: zwei Teile werden erkannt', () {
    expect(letterComponents(twoPartMask()).length, 2);
  });

  test('Ä-artig: nur der Körper reicht NICHT (Punkte fehlen)', () {
    expect(traceAccepted(twoPartMask(), [body], size6, 1, brush: 0), isFalse);
  });

  test('Ä-artig: Körper UND Punkte -> angenommen', () {
    expect(
      traceAccepted(twoPartMask(), [
        [...body, ...dot]
      ], size6, 1, brush: 0),
      isTrue,
    );
  });

  test('halbe Abdeckung (z. B. halbes O) fällt durch', () {
    final mask = centerMask(); // 4 Soll-Zellen
    final strokes = [
      [const Offset(1.5, 1.5), const Offset(2.5, 1.5)], // nur 2 von 4 = 0.5
    ];
    // Genauigkeit ist hoch (alles auf dem Buchstaben), aber die Abdeckung
    // reißt die Box-1-Schwelle (0.60) -> kein Erfolg.
    expect(traceAccepted(mask, strokes, size, 1, brush: 0), isFalse);
  });

  test('sauberes Nachfahren der Soll-Fläche wird angenommen', () {
    final mask = centerMask();
    final strokes = [
      [
        const Offset(1.5, 1.5),
        const Offset(2.5, 1.5),
        const Offset(2.5, 2.5),
        const Offset(1.5, 2.5),
      ],
    ];
    expect(traceAccepted(mask, strokes, size, 1, brush: 0), isTrue);
  });
}
