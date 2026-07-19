import 'dart:math' as math;

import 'package:drift/drift.dart';

import '../db/database.dart';

/// Wort-/Verbindungs-Progression und Freischalt-Zaehler pro Kind
/// (Batch-Lernen). Bewusst getrennt vom [ReadingRepository], das den
/// Leitner-Fortschritt und Wort-/Bilddaten verwaltet.
class ProgressionRepository {
  ProgressionRepository(this._db);

  final AppDatabase _db;

  // Start-/Schrittwerte (Start-Werte = Defaults der DB-Spalten).
  static const wordsStart = 3;
  static const wordsStep = 2;
  static const combosStart = 2;
  static const combosStep = 1;

  /// Immer als Erstes (unabhaengig von der Schwierigkeit).
  static const _ersteWoerter = ['Mama', 'Papa'];

  /// Alle Woerter in Lern-Reihenfolge: [Mama, Papa], dann nach Schwierigkeit
  /// (spaetester benoetigter Buchstabe laut sortOrder), dann Laenge/Alphabet.
  Future<List<Word>> wordProgression() async {
    final graphemes = await (_db.select(_db.graphemes)
          ..where((g) => g.kind.equals('buchstabe')))
        .get();
    final rank = {
      for (final g in graphemes) g.symbol.toLowerCase(): g.sortOrder,
    };
    int schwierigkeit(Word w) {
      var m = 0;
      for (final c in w.word.toLowerCase().split('')) {
        m = math.max(m, rank[c] ?? 999);
      }
      return m;
    }

    final all = await _db.select(_db.words).get();
    final head = <Word>[];
    for (final name in _ersteWoerter) {
      final match = all.where((w) => w.word == name);
      if (match.isNotEmpty) head.add(match.first);
    }
    final tail = all.where((w) => !_ersteWoerter.contains(w.word)).toList()
      ..sort((a, b) {
        final ds = schwierigkeit(a).compareTo(schwierigkeit(b));
        if (ds != 0) return ds;
        final dl = a.word.length.compareTo(b.word.length);
        return dl != 0 ? dl : a.word.compareTo(b.word);
      });
    return [...head, ...tail];
  }

  Future<int> wordsUnlocked(int childId) =>
      _read(childId, (row) => row.wordsUnlocked, wordsStart);

  Future<int> combosUnlocked(int childId) =>
      _read(childId, (row) => row.combosUnlocked, combosStart);

  /// Schaltet ein paar neue Woerter frei (bis maximal [total]).
  Future<int> unlockMore(int childId, int total, {int by = wordsStep}) async {
    final current = await wordsUnlocked(childId);
    final upper = total < wordsStart ? wordsStart : total;
    final next = (current + by).clamp(wordsStart, upper);
    await _write(childId, ReadingProgressCompanion(wordsUnlocked: Value(next)));
    return next;
  }

  /// Schaltet ein paar neue Verbindungen frei (bis maximal [total]).
  Future<int> unlockMoreCombos(int childId, int total,
      {int by = combosStep}) async {
    final current = await combosUnlocked(childId);
    final upper = total < combosStart ? combosStart : total;
    final next = (current + by).clamp(combosStart, upper);
    await _write(childId, ReadingProgressCompanion(combosUnlocked: Value(next)));
    return next;
  }

  Future<int> _read(
    int childId,
    int Function(ReadingProgressData) pick,
    int fallback,
  ) async {
    final row = await (_db.select(_db.readingProgress)
          ..where((p) => p.childId.equals(childId)))
        .getSingleOrNull();
    if (row != null) return pick(row);
    await _db.into(_db.readingProgress).insert(
          ReadingProgressCompanion.insert(childId: Value(childId)),
        );
    return fallback;
  }

  Future<void> _write(int childId, ReadingProgressCompanion values) async {
    // Sicherstellen, dass eine Zeile existiert.
    await wordsUnlocked(childId);
    await (_db.update(_db.readingProgress)
          ..where((p) => p.childId.equals(childId)))
        .write(values);
  }
}
