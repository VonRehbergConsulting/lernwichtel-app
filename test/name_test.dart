import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:education_app/core/utils/name_letters.dart';
import 'package:education_app/data/db/database.dart';
import 'package:education_app/data/repositories/reading_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('nameLetters', () {
    test('eindeutige Buchstaben, klein, ohne Sonderzeichen', () {
      expect(nameLetters('Anna'), {'a', 'n'});
      expect(nameLetters('Li-La'), {'l', 'i', 'a'});
      expect(nameLetters('Mörk'), {'m', 'ö', 'r', 'k'});
      expect(nameLetters('  '), isEmpty);
    });
  });

  group('ReadingRepository (Name)', () {
    late AppDatabase db;
    late ReadingRepository reading;
    late int childId;
    final ids = <String, int>{};

    Future<void> letter(String s, int order) async {
      final g = await db.into(db.graphemes).insertReturning(
            GraphemesCompanion.insert(
              symbol: s,
              graphemeKey: s,
              kind: 'buchstabe',
              sortOrder: Value(order),
            ),
          );
      ids[s] = g.id;
    }

    Future<void> master(List<String> symbols) async {
      for (final s in symbols) {
        await reading.setMastered(
            childId: childId, graphemeId: ids[s]!, mastered: true);
      }
    }

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      reading = ReadingRepository(db);
      await letter('m', 1);
      await letter('a', 2);
      await letter('l', 3);
      await letter('o', 4);
      await letter('t', 11);
      await letter('p', 13);
      final child = await db
          .into(db.children)
          .insertReturning(ChildrenCompanion.insert(name: 'T'));
      childId = child.id;
    });

    tearDown(() => db.close());

    test('ohne Boost: nach m,a,p kommt l (nach sortOrder)', () async {
      await master(['m', 'a', 'p']);
      final g = await reading.nextGraphemeToTeach(childId, 'buchstabe');
      expect(g?.symbol, 'l');
    });

    test('mit Boost ("Tom"): Namensbuchstabe o wird vor l gezogen', () async {
      await master(['m', 'a', 'p']);
      final g = await reading.nextGraphemeToTeach(childId, 'buchstabe',
          boostName: 'Tom');
      expect(g?.symbol, 'o'); // o(4) vor t(11), beide vor l
    });

    test('nameLetterProgress zählt sichere Namensbuchstaben', () async {
      await master(['m']); // von "Tom" (t,o,m) sitzt m
      final p = await reading.nameLetterProgress(childId, 'Tom');
      expect(p.total, 3);
      expect(p.mastered, 1);
    });

    test('nameLetterProgress: alle sicher', () async {
      await master(['t', 'o', 'm']);
      final p = await reading.nameLetterProgress(childId, 'Tom');
      expect(p.mastered, p.total);
      expect(p.total, 3);
    });
  });
}
