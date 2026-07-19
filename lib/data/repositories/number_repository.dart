import 'package:drift/drift.dart';

import '../db/database.dart';

/// Zahl-Lernfortschritt (Mengen/Ziffern 1..10) je Kind – für die geführte
/// Mathe-Lektion. Spiegelt die Graphem-Methoden des [ReadingRepository].
class NumberRepository {
  NumberRepository(this._db);

  final AppDatabase _db;

  static const maxNumber = 10;
  static const maxBox = 3;

  Future<Map<int, NumberProgressData>> progressFor(int childId) async {
    final rows = await (_db.select(_db.numberProgress)
          ..where((p) => p.childId.equals(childId)))
        .get();
    return {for (final r in rows) r.value: r};
  }

  /// Höchste bereits *eingeführte* Zahl (Fortschritt ≠ „neu") – Grenze fürs
  /// selbstständige Üben, damit es dem Lektions-Fortschritt nicht vorauseilt.
  Future<int> highestIntroduced(int childId) async {
    final progress = await progressFor(childId);
    var max = 0;
    progress.forEach((value, data) {
      if (data.status != 'neu' && value > max) max = value;
    });
    return max;
  }

  /// Die nächste einzuführende Zahl: die erste in 1..[maxNumber], die noch
  /// nicht "sicher" ist. null, wenn schon alle sitzen.
  Future<int?> nextNumberToTeach(int childId) async {
    final progress = await progressFor(childId);
    for (var n = 1; n <= maxNumber; n++) {
      if (progress[n]?.status != 'sicher') return n;
    }
    return null;
  }

  /// Ein paar andere Zahlen nahe [value] (für die "Zeig mir"-Auswahl).
  List<int> siblingNumbers(int value, {int count = 2}) {
    final all = [
      for (var n = 1; n <= maxNumber; n++)
        if (n != value) n,
    ]..sort((a, b) => (a - value).abs().compareTo((b - value).abs()));
    return all.take(count).toList();
  }

  Future<void> setMastered({
    required int childId,
    required int value,
    required bool mastered,
  }) async {
    await _db.into(_db.numberProgress).insertOnConflictUpdate(
          NumberProgressCompanion.insert(
            childId: childId,
            value: value,
            status: Value(mastered ? 'sicher' : 'neu'),
            box: Value(mastered ? maxBox : 1),
          ),
        );
  }

  Future<void> recordResult({
    required int childId,
    required int value,
    required bool correct,
  }) async {
    final current = await (_db.select(_db.numberProgress)
          ..where((p) => p.childId.equals(childId) & p.value.equals(value)))
        .getSingleOrNull();
    final oldBox = current?.box ?? 1;
    final newBox = correct ? (oldBox + 1).clamp(1, maxBox) : 1;
    final status = correct && newBox >= maxBox
        ? 'sicher'
        : (correct ? 'lernend' : 'neu');
    await _db.into(_db.numberProgress).insertOnConflictUpdate(
          NumberProgressCompanion.insert(
            childId: childId,
            value: value,
            status: Value(status),
            box: Value(newBox),
          ),
        );
  }
}
