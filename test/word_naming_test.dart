import 'package:drift/native.dart';
import 'package:education_app/data/db/database.dart';
import 'package:education_app/data/repositories/reading_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Wort-Benennung (Foto → Wort)', () {
    late AppDatabase db;
    late ReadingRepository repo;

    setUp(() async {
      db = AppDatabase.forTesting(NativeDatabase.memory());
      repo = ReadingRepository(db);
      for (final w in ['Ball', 'Banane', 'Apfel']) {
        await db.into(db.words).insert(WordsCompanion.insert(word: w));
      }
    });

    tearDown(() => db.close());

    test('searchWords: Präfix-Treffer zuerst, case-insensitiv', () async {
      final res = await repo.searchWords('ba');
      expect(res.map((w) => w.word), containsAllInOrder(['Ball', 'Banane']));
      expect(res.map((w) => w.word), isNot(contains('Apfel')));
    });

    test('findWordByText: exakter Treffer unabhängig von Groß/Klein', () async {
      expect((await repo.findWordByText('ball'))?.word, 'Ball');
      expect(await repo.findWordByText('gibtsnicht'), isNull);
    });

    test('createWordWithImage: neues eigenes Wort mit Bild', () async {
      final w = await repo.createWordWithImage('Wolke', '/fotos/wolke.jpg');
      expect(w.word, 'Wolke');
      expect(w.isCustom, isTrue);
      expect(w.imageId, isNotNull);
      // taucht danach in Suche und exaktem Treffer auf
      expect((await repo.findWordByText('wolke'))?.id, w.id);
      final paths = await repo.imagePathsForWords([w.id]);
      expect(paths[w.id], '/fotos/wolke.jpg');
    });

    test('setWordImage: überschreibt das Bild eines vorhandenen Wortes',
        () async {
      final ball = await repo.findWordByText('Ball');
      await repo.setWordImage(ball!.id, '/fotos/ball.jpg', 'Ball');
      final paths = await repo.imagePathsForWords([ball.id]);
      expect(paths[ball.id], '/fotos/ball.jpg');
    });
  });
}
