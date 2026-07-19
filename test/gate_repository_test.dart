import 'package:drift/native.dart';
import 'package:education_app/data/db/database.dart';
import 'package:education_app/data/repositories/gate_repository.dart';
import 'package:education_app/data/repositories/reading_repository.dart';
import 'package:education_app/data/repositories/math_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late GateRepository gate;
  late ReadingRepository reading;
  late MathRepository math;
  late int childId;

  Future<int> letter(String s, String kind) async {
    final g = await db.into(db.graphemes).insertReturning(
          GraphemesCompanion.insert(symbol: s, graphemeKey: s, kind: kind),
        );
    return g.id;
  }

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    gate = GateRepository(db);
    reading = ReadingRepository(db);
    math = MathRepository(db);
    final child = await db
        .into(db.children)
        .insertReturning(ChildrenCompanion.insert(name: 'T'));
    childId = child.id;
  });

  tearDown(() => db.close());

  test('frisches Kind: nur Basis-Bereiche offen', () async {
    final unlocked = await gate.unlockedFor(childId);
    expect(unlocked, GateRepository.baseSections);
    expect(unlocked.contains('lese_verbindungen'), isFalse);
    expect(unlocked.contains('math_zehner'), isFalse);
  });

  test('manuelle Freischaltung greift und laesst sich zuruecknehmen', () async {
    await gate.setManualUnlock(childId, 'lese_verbindungen', true);
    expect((await gate.unlockedFor(childId)).contains('lese_verbindungen'),
        isTrue);
    await gate.setManualUnlock(childId, 'lese_verbindungen', false);
    expect((await gate.unlockedFor(childId)).contains('lese_verbindungen'),
        isFalse);
  });

  test('genug sichere Buchstaben oeffnen Lautverbindungen automatisch',
      () async {
    for (var i = 0; i < GateRepository.lettersForCombos; i++) {
      final id = await letter('l$i', 'buchstabe');
      await reading.setMastered(
          childId: childId, graphemeId: id, mastered: true);
    }
    final unlocked = await gate.unlockedFor(childId);
    expect(unlocked.contains('lese_verbindungen'), isTrue);
    expect(unlocked.contains('lese_saetze'), isFalse);
  });

  test('Ziffern-Level oeffnet Zahlen bis 100 automatisch', () async {
    // Level bis zur Schwelle hochspielen (je 3 richtige = +1 Level).
    for (var i = 0; i < 3 * (GateRepository.mathLevelToAdvance - 1); i++) {
      await math.recordAnswer(
        childId: childId,
        module: 'ziffern',
        problem: '1',
        correct: true,
      );
    }
    final unlocked = await gate.unlockedFor(childId);
    expect(unlocked.contains('math_zehner'), isTrue);
    expect(unlocked.contains('math_addieren'), isFalse);
  });
}
