import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:education_app/data/db/database.dart';
import 'package:education_app/data/repositories/progression_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AppDatabase db;
  late ProgressionRepository repo;
  late int childId;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = ProgressionRepository(db);

    Future<void> letter(String s, int order) => db.into(db.graphemes).insert(
          GraphemesCompanion.insert(
            symbol: s,
            graphemeKey: s,
            kind: 'buchstabe',
            sortOrder: Value(order),
          ),
        );
    await letter('m', 1);
    await letter('a', 2);
    await letter('o', 4);
    await letter('p', 13);

    for (final w in ['Mama', 'Papa', 'Oma', 'Ma']) {
      await db.into(db.words).insert(WordsCompanion.insert(word: w));
    }

    final child = await db
        .into(db.children)
        .insertReturning(ChildrenCompanion.insert(name: 'T'));
    childId = child.id;
  });

  tearDown(() => db.close());

  test('Mama und Papa stehen ganz vorne', () async {
    final prog = await repo.wordProgression();
    expect(prog[0].word, 'Mama');
    expect(prog[1].word, 'Papa');
  });

  test('danach nach Schwierigkeit (Ma vor Oma)', () async {
    final prog = await repo.wordProgression();
    final tail = prog.skip(2).map((w) => w.word).toList();
    expect(tail.indexOf('Ma'), lessThan(tail.indexOf('Oma')));
  });

  test('Woerter: Default 3, unlockMore +2', () async {
    expect(await repo.wordsUnlocked(childId), ProgressionRepository.wordsStart);
    expect(await repo.unlockMore(childId, 10), 5);
    expect(await repo.wordsUnlocked(childId), 5);
  });

  test('Verbindungen: Default 2, unlockMoreCombos +1', () async {
    expect(
        await repo.combosUnlocked(childId), ProgressionRepository.combosStart);
    expect(await repo.unlockMoreCombos(childId, 10), 3);
  });

  test('unlockMore ueberschreitet total nicht', () async {
    final n = await repo.unlockMore(childId, 4); // Start 3, +2 -> auf 4 gekappt
    expect(n, 4);
  });
}
