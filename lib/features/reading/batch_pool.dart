import 'dart:math';

/// Waehlt aus der [progression] (nach Schwierigkeit geordnet) einen zufaelligen
/// Uebungs-Pool: die neuesten [newestCount] freigeschalteten Elemente sind
/// immer dabei, aufgefuellt mit bekannten, maximal [maxPool], dann gemischt.
///
/// Generisch und ohne Seiteneffekte -> gut testbar; wird sowohl fuer Woerter
/// als auch fuer Lautverbindungen genutzt.
List<T> buildBatchPool<T>(
  List<T> progression,
  int unlocked, {
  required int maxPool,
  required int newestCount,
  required Random rnd,
}) {
  final available =
      progression.take(unlocked.clamp(0, progression.length)).toList();
  if (available.isEmpty) return <T>[];

  final poolSize = min(available.length, maxPool);
  final newest = available.reversed.take(newestCount).toList();
  final rest = available.take(available.length - newest.length).toList()
    ..shuffle(rnd);
  return <T>[...newest, ...rest].take(poolSize).toList()..shuffle(rnd);
}
