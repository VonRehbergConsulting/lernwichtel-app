import 'dart:math';

import 'package:education_app/features/reading/batch_pool.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final progression = List<int>.generate(20, (i) => i); // 0..19

  test('unter maxPool: alle freigeschalteten sind im Pool', () {
    final pool = buildBatchPool(progression, 5,
        maxPool: 10, newestCount: 3, rnd: Random(1));
    expect(pool.length, 5);
    expect(pool.toSet(), {0, 1, 2, 3, 4});
  });

  test('kappt auf maxPool und enthaelt immer die neuesten', () {
    final pool = buildBatchPool(progression, 15,
        maxPool: 10, newestCount: 3, rnd: Random(2));
    expect(pool.length, 10);
    expect(pool, containsAll([12, 13, 14])); // die 3 neuesten
    expect(pool.every((e) => e < 15), isTrue); // nur Freigeschaltetes
  });

  test('leer, wenn nichts freigeschaltet ist', () {
    expect(
      buildBatchPool(progression, 0, maxPool: 10, newestCount: 3, rnd: Random()),
      isEmpty,
    );
  });

  test('unlocked groesser als Progression wird gekappt', () {
    final pool = buildBatchPool([1, 2], 99,
        maxPool: 10, newestCount: 3, rnd: Random());
    expect(pool.toSet(), {1, 2});
  });
}
