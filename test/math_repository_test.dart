import 'package:drift/native.dart';
import 'package:education_app/data/db/database.dart';
import 'package:education_app/data/repositories/math_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late MathRepository repo;
  late int childId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = MathRepository(db);
    final child = await db
        .into(db.children)
        .insertReturning(ChildrenCompanion.insert(name: 'Test'));
    childId = child.id;
  });

  tearDown(() => db.close());

  test('3 richtige in Folge -> Level hoch', () async {
    for (var i = 0; i < 3; i++) {
      final o = await repo.recordAnswer(
          childId: childId, module: 'ziffern', problem: '3', correct: true);
      expect(o.leveledUp, i == 2); // erst beim 3. Mal
    }
    expect((await repo.skill(childId, 'ziffern')).level, 2);
  });

  test('2 falsche in Folge -> Level runter (nicht unter 1)', () async {
    for (var i = 0; i < 3; i++) {
      await repo.recordAnswer(
          childId: childId, module: 'plus', problem: '1+1', correct: true);
    }
    expect((await repo.skill(childId, 'plus')).level, 2);

    for (var i = 0; i < 2; i++) {
      await repo.recordAnswer(
          childId: childId, module: 'plus', problem: '1+1', correct: false);
    }
    expect((await repo.skill(childId, 'plus')).level, 1);

    // Weiter falsch -> bleibt bei 1.
    for (var i = 0; i < 2; i++) {
      await repo.recordAnswer(
          childId: childId, module: 'plus', problem: '1+1', correct: false);
    }
    expect((await repo.skill(childId, 'plus')).level, 1);
  });

  test('richtig setzt die Falsch-Serie zurueck', () async {
    await repo.recordAnswer(
        childId: childId, module: 'minus', problem: 'x', correct: false);
    await repo.recordAnswer(
        childId: childId, module: 'minus', problem: 'x', correct: true);
    // Eine weitere falsche allein senkt noch nicht (Serie war unterbrochen).
    final o = await repo.recordAnswer(
        childId: childId, module: 'minus', problem: 'x', correct: false);
    expect(o.leveledDown, isFalse);
  });

  test('leichter senkt das Level nicht unter 1', () async {
    final s = await repo.decreaseLevel(childId, 'minus');
    expect(s.level, 1);
  });

  test('jede Antwort wird protokolliert', () async {
    await repo.recordAnswer(
        childId: childId, module: 'ziffern', problem: '2', correct: true);
    final attempts = await db.select(db.mathAttempts).get();
    expect(attempts, hasLength(1));
    expect(attempts.first.correct, isTrue);
  });
}
