import 'dart:math';

import 'package:education_app/features/math/model/math_problem.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Ziffern Level 1: Bereich 1..3, keine 0', () {
    final r = Random(1);
    for (var i = 0; i < 300; i++) {
      final p = generateProblem(MathModule.ziffern, 1, r);
      expect(p.answer, inInclusiveRange(1, 3));
    }
  });

  test('Plus niedrige Stufe: Operanden >= 1, Summe <= 5, korrektes Ergebnis',
      () {
    final r = Random(2);
    for (var i = 0; i < 500; i++) {
      final p = generateProblem(MathModule.addieren, 1, r);
      expect(p.a! >= 1, isTrue, reason: 'a=${p.a}');
      expect(p.b! >= 1, isTrue, reason: 'b=${p.b}');
      expect(p.a! + p.b!, lessThanOrEqualTo(5));
      expect(p.answer, p.a! + p.b!);
    }
  });

  test('Minus: nie negativ, Operanden >= 1 auf niedriger Stufe', () {
    final r = Random(3);
    for (var i = 0; i < 500; i++) {
      final p = generateProblem(MathModule.subtrahieren, 1, r);
      expect(p.a! >= 1, isTrue);
      expect(p.b! >= 1, isTrue);
      expect(p.b! <= p.a!, isTrue);
      expect(p.answer >= 0, isTrue);
    }
  });

  test('Ziffern mit maxNumber-Cap: nie ueber die eingefuehrte Zahl hinaus', () {
    final r = Random(7);
    for (final cap in [3, 5, 8]) {
      for (var i = 0; i < 300; i++) {
        // Auch auf hohen Stufen darf die Ziffer den Cap nicht ueberschreiten.
        final p = generateProblem(MathModule.ziffern, 4, r, maxNumber: cap);
        expect(p.answer, inInclusiveRange(1, cap),
            reason: 'cap=$cap, answer=${p.answer}');
      }
    }
  });

  test('Zaehl-Objekt ist ein gueltiger Slug', () {
    final slugs = mathObjects.map((o) => o.slug).toSet();
    for (var i = 0; i < 50; i++) {
      final p = generateProblem(MathModule.ziffern, 1, Random(i));
      expect(slugs, contains(p.object));
    }
  });
}
