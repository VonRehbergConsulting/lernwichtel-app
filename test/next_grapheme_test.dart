import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:education_app/data/db/database.dart';
import 'package:education_app/data/repositories/reading_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    reading = ReadingRepository(db);
    await letter('m', 1);
    await letter('a', 2);
    await letter('p', 3);
    final child = await db
        .into(db.children)
        .insertReturning(ChildrenCompanion.insert(name: 'T'));
    childId = child.id;
  });

  tearDown(() => db.close());

  test('frisches Kind: erster Buchstabe nach Reihenfolge (m)', () async {
    final g = await reading.nextGraphemeToTeach(childId, 'buchstabe');
    expect(g?.symbol, 'm');
  });

  test('nach "sicher" kommt der naechste', () async {
    await reading.setMastered(
        childId: childId, graphemeId: ids['m']!, mastered: true);
    final g = await reading.nextGraphemeToTeach(childId, 'buchstabe');
    expect(g?.symbol, 'a');
  });

  test('alle sicher -> null', () async {
    for (final id in ids.values) {
      await reading.setMastered(
          childId: childId, graphemeId: id, mastered: true);
    }
    expect(await reading.nextGraphemeToTeach(childId, 'buchstabe'), isNull);
  });

  test('Geschwister-Grapheme fuer die Auswahl (ohne Ziel)', () async {
    final sibs = await reading.siblingGraphemes('buchstabe',
        excludeId: ids['m']!, aroundSortOrder: 1);
    expect(sibs.length, 2);
    expect(sibs.any((g) => g.id == ids['m']), isFalse);
  });
}
