import 'package:drift/drift.dart';

import '../db/database.dart';

/// Entscheidet, welche Lern-Bereiche fuer ein Kind freigeschaltet sind.
///
/// Ein Bereich ist frei, wenn ER ...
///  * eine Basis-Stufe ist (Buchstaben / Ziffern – immer offen),
///  * automatisch aus dem Fortschritt abgeleitet wird (genug Sicheres gelernt),
///  * oder manuell freigeschaltet wurde (Eltern-Bereich / Startniveau bei der
///    Anlage).
///
/// Die `sectionKey`-Werte entsprechen den Menue-Icon-IDs (z. B.
/// `lese_verbindungen`, `math_addieren`).
class GateRepository {
  GateRepository(this._db);

  final AppDatabase _db;

  /// Immer offen – der Einstieg in jeden der beiden Bereiche.
  static const baseSections = {'lese_buchstaben', 'math_ziffern'};

  /// Sichere Buchstaben, bis Lautverbindungen automatisch aufgehen.
  static const lettersForCombos = 6;

  /// Sichere Lautverbindungen, bis Saetze automatisch aufgehen.
  static const combosForSentences = 3;

  /// Level im Vorgaenger-Modul, ab dem das naechste Rechen-Modul aufgeht.
  static const mathLevelToAdvance = 3;

  /// Alle aktuell freigeschalteten Bereiche eines Kindes.
  Future<Set<String>> unlockedFor(int childId) async {
    return {
      ...baseSections,
      ...await manualUnlocks(childId),
      ...await _autoUnlocks(childId),
    };
  }

  /// Nur die manuell (durch Eltern / Startniveau) freigeschalteten Bereiche.
  Future<Set<String>> manualUnlocks(int childId) async {
    final rows = await (_db.select(_db.sectionUnlocks)
          ..where((u) => u.childId.equals(childId)))
        .get();
    return rows.map((r) => r.sectionKey).toSet();
  }

  /// Nur die automatisch aus dem Fortschritt abgeleiteten Bereiche.
  Future<Set<String>> autoUnlocks(int childId) => _autoUnlocks(childId);

  /// Setzt/entfernt eine manuelle Freischaltung.
  Future<void> setManualUnlock(int childId, String key, bool unlocked) async {
    if (unlocked) {
      await _db.into(_db.sectionUnlocks).insertOnConflictUpdate(
            SectionUnlocksCompanion.insert(childId: childId, sectionKey: key),
          );
    } else {
      await (_db.delete(_db.sectionUnlocks)
            ..where((u) =>
                u.childId.equals(childId) & u.sectionKey.equals(key)))
          .go();
    }
  }

  /// Uebernimmt das beim Anlegen gewaehlte Startniveau (mehrere Bereiche).
  Future<void> applyStartUnlocks(int childId, Set<String> keys) async {
    for (final key in keys) {
      await _db.into(_db.sectionUnlocks).insertOnConflictUpdate(
            SectionUnlocksCompanion.insert(childId: childId, sectionKey: key),
          );
    }
  }

  Future<Set<String>> _autoUnlocks(int childId) async {
    final auto = <String>{};

    // Lesen: sichere Buchstaben/Verbindungen zaehlen.
    final counts = await _masteredCounts(childId);
    if ((counts['buchstabe'] ?? 0) >= lettersForCombos) {
      auto.add('lese_verbindungen');
    }
    if ((counts['verbindung'] ?? 0) >= combosForSentences) {
      auto.add('lese_saetze');
    }

    // Rechnen: Level im Vorgaenger-Modul.
    final levels = await _mathLevels(childId);
    if ((levels['ziffern'] ?? 1) >= mathLevelToAdvance) auto.add('math_zehner');
    if ((levels['zehner'] ?? 1) >= mathLevelToAdvance) auto.add('math_addieren');
    if ((levels['addieren'] ?? 1) >= mathLevelToAdvance) {
      auto.add('math_subtrahieren');
    }
    return auto;
  }

  /// Anzahl "sicherer" Grapheme je Art (`buchstabe` / `verbindung`).
  Future<Map<String, int>> _masteredCounts(int childId) async {
    final rows = await (_db.select(_db.graphemeProgress).join([
      innerJoin(
        _db.graphemes,
        _db.graphemes.id.equalsExp(_db.graphemeProgress.graphemeId),
      ),
    ])
          ..where(_db.graphemeProgress.childId.equals(childId) &
              _db.graphemeProgress.status.equals('sicher')))
        .get();
    final counts = <String, int>{};
    for (final r in rows) {
      final kind = r.readTable(_db.graphemes).kind;
      counts[kind] = (counts[kind] ?? 0) + 1;
    }
    return counts;
  }

  /// Aktuelles Level je Rechen-Modul.
  Future<Map<String, int>> _mathLevels(int childId) async {
    final rows = await (_db.select(_db.mathSkills)
          ..where((s) => s.childId.equals(childId)))
        .get();
    return {for (final r in rows) r.module: r.level};
  }
}
