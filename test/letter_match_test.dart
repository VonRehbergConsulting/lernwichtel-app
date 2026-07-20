import 'dart:math';

import 'package:education_app/features/reading/ui/letter_match_page.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Matching-Runde: Ziel enthalten, richtige Anzahl, ohne Dubletten', () {
    final pool = [1, 2, 3, 4, 5];
    final round = pickMatchRound(pool, 3, rnd: Random(1));
    expect(round.length, 3);
    expect(round.contains(3), isTrue);
    expect(round.toSet().length, round.length); // keine Dubletten
    expect(round.every(pool.contains), isTrue);
  });

  test('kleiner Pool: nicht mehr Optionen als vorhanden', () {
    final round = pickMatchRound([1, 2], 1, rnd: Random(1));
    expect(round.length, 2); // Ziel + nur 1 möglicher Ablenker
    expect(round.contains(1), isTrue);
  });
}
