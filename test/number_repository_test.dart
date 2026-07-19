import 'package:drift/native.dart';
import 'package:education_app/data/db/database.dart';
import 'package:education_app/data/repositories/number_repository.dart';
import 'package:education_app/features/math/number_words.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NumberRepository', () {
    late AppDatabase db;
    late NumberRepository repo;
    late int childId;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = NumberRepository(db);
      final child = await db
          .into(db.children)
          .insertReturning(ChildrenCompanion.insert(name: 'T'));
      childId = child.id;
    });

    tearDown(() => db.close());

    test('frisches Kind: erste Zahl ist 1', () async {
      expect(await repo.nextNumberToTeach(childId), 1);
    });

    test('nach "sicher" kommt die nächste', () async {
      await repo.setMastered(childId: childId, value: 1, mastered: true);
      await repo.setMastered(childId: childId, value: 2, mastered: true);
      expect(await repo.nextNumberToTeach(childId), 3);
    });

    test('alle sicher -> null', () async {
      for (var n = 1; n <= NumberRepository.maxNumber; n++) {
        await repo.setMastered(childId: childId, value: n, mastered: true);
      }
      expect(await repo.nextNumberToTeach(childId), isNull);
    });

    test('highestIntroduced: 0 bei frischem Kind', () async {
      expect(await repo.highestIntroduced(childId), 0);
    });

    test('highestIntroduced: höchste nicht-neue Zahl', () async {
      // "sicher" und "lernend" zählen als eingeführt, "neu" nicht.
      await repo.setMastered(childId: childId, value: 1, mastered: true);
      await repo.recordResult(childId: childId, value: 2, correct: true);
      await repo.setMastered(childId: childId, value: 5, mastered: false);
      expect(await repo.highestIntroduced(childId), 2);
    });

    test('Geschwister-Zahlen: nah, ohne Ziel, im Bereich', () async {
      final sibs = repo.siblingNumbers(5, count: 2);
      expect(sibs.length, 2);
      expect(sibs.contains(5), isFalse);
      expect(sibs, containsAll(<int>[4, 6]));
    });

    test('Geschwister am Rand bleiben im gültigen Bereich', () async {
      expect(repo.siblingNumbers(1), everyElement(greaterThanOrEqualTo(1)));
      expect(repo.siblingNumbers(10),
          everyElement(lessThanOrEqualTo(NumberRepository.maxNumber)));
    });
  });

  group('zahlwort', () {
    test('bekannte Zahlen', () {
      expect(zahlwort(0), 'null');
      expect(zahlwort(1), 'eins');
      expect(zahlwort(3), 'drei');
      expect(zahlwort(10), 'zehn');
    });

    test('außerhalb -> Ziffernschreibweise', () {
      expect(zahlwort(42), '42');
    });
  });
}
