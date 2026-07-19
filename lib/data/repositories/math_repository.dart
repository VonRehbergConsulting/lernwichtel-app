import 'package:drift/drift.dart';

import '../db/database.dart';

/// Ergebnis einer verbuchten Antwort inkl. Info, ob das Level sich geaendert hat.
class MathOutcome {
  const MathOutcome(this.skill, {required this.leveledUp, required this.leveledDown});
  final MathSkill skill;
  final bool leveledUp;
  final bool leveledDown;
}

/// Rechen-Fortschritt je Kind und Modul mit adaptiver Schwierigkeit.
///
/// Regel: 3 richtige in Folge -> Level hoch; 2 falsche in Folge -> Level runter.
/// Das Kind kann per "leichter" jederzeit selbst eine Stufe zurueck.
class MathRepository {
  MathRepository(this._db);

  final AppDatabase _db;

  static const maxLevel = 6;
  static const _upThreshold = 3;
  static const _downThreshold = 2;

  Future<MathSkill> skill(int childId, String module) async {
    final existing = await (_db.select(_db.mathSkills)
          ..where((s) => s.childId.equals(childId) & s.module.equals(module)))
        .getSingleOrNull();
    if (existing != null) return existing;
    return _db.into(_db.mathSkills).insertReturning(
          MathSkillsCompanion.insert(childId: childId, module: module),
        );
  }

  Future<MathOutcome> recordAnswer({
    required int childId,
    required String module,
    required String problem,
    required bool correct,
  }) async {
    final s = await skill(childId, module);
    var level = s.level;
    var correctStreak = s.correctStreak;
    var wrongStreak = s.wrongStreak;
    var up = false;
    var down = false;

    if (correct) {
      correctStreak++;
      wrongStreak = 0;
      if (correctStreak >= _upThreshold && level < maxLevel) {
        level++;
        correctStreak = 0;
        up = true;
      }
    } else {
      wrongStreak++;
      correctStreak = 0;
      if (wrongStreak >= _downThreshold && level > 1) {
        level--;
        wrongStreak = 0;
        down = true;
      }
    }

    await _write(childId, module, level, correctStreak, wrongStreak);
    await _db.into(_db.mathAttempts).insert(MathAttemptsCompanion.insert(
          childId: childId,
          module: module,
          problem: problem,
          correct: correct,
        ));

    final updated = s.copyWith(
      level: level,
      correctStreak: correctStreak,
      wrongStreak: wrongStreak,
    );
    return MathOutcome(updated, leveledUp: up, leveledDown: down);
  }

  /// Kind-gesteuertes Herunterstufen ("leichter").
  Future<MathSkill> decreaseLevel(int childId, String module) async {
    final s = await skill(childId, module);
    final level = (s.level - 1).clamp(1, maxLevel);
    await _write(childId, module, level, 0, 0);
    return s.copyWith(level: level, correctStreak: 0, wrongStreak: 0);
  }

  Future<void> _write(
    int childId,
    String module,
    int level,
    int correctStreak,
    int wrongStreak,
  ) {
    return (_db.update(_db.mathSkills)
          ..where((x) => x.childId.equals(childId) & x.module.equals(module)))
        .write(MathSkillsCompanion(
      level: Value(level),
      correctStreak: Value(correctStreak),
      wrongStreak: Value(wrongStreak),
    ));
  }
}
