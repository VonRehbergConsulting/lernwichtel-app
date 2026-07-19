import 'package:drift/drift.dart';

import '../../core/utils/name_letters.dart';
import '../db/database.dart';

/// Ein Wort samt (optional) hinterlegtem Bild – fuers Lese-Modul.
class WordWithImage {
  const WordWithImage({required this.word, this.imagePath});
  final Word word;
  final String? imagePath;
}

/// Lese-Fortschritt (Leitner-Boxen) und Wort-/Bilddaten je Kind.
class ReadingRepository {
  ReadingRepository(this._db);

  final AppDatabase _db;

  static const maxBox = 3;

  /// Fortschritt eines Kindes je Graphem (leer, wenn noch nichts geuebt).
  Future<Map<int, GraphemeProgressData>> progressFor(int childId) async {
    final rows = await (_db.select(_db.graphemeProgress)
          ..where((p) => p.childId.equals(childId)))
        .get();
    return {for (final r in rows) r.graphemeId: r};
  }

  /// Lese-Wissen eines Kindes für die Silben-Zerlegung (Fortschritt beachten):
  /// eingeführte Einzelbuchstaben, eingeführte Silben und die Vokabel *aller*
  /// Silben (längenabsteigend, für Längster-Treffer). Damit lässt sich prüfen,
  /// ob ein Wort schon lesbar ist – inkl. Clustern wie „st"/„sch".
  Future<({Set<String> letters, Set<String> combos, List<String> vocab})>
      readingKnowledge(int childId) async {
    final graphemes = await _db.select(_db.graphemes).get();
    final progress = await progressFor(childId);
    final letters = <String>{};
    final combos = <String>{};
    final vocab = <String>[];
    for (final g in graphemes) {
      final sym = g.symbol.toLowerCase();
      final introduced = (progress[g.id]?.status ?? 'neu') != 'neu';
      if (g.kind == 'verbindung') {
        vocab.add(sym);
        if (introduced) combos.add(sym);
      } else if (g.kind == 'buchstabe' && introduced) {
        letters.add(sym);
      }
    }
    vocab.sort((a, b) => b.length.compareTo(a.length));
    return (letters: letters, combos: combos, vocab: vocab);
  }

  /// Setzt/aktualisiert den Status manuell (Eltern-Haekchen).
  Future<void> setMastered({
    required int childId,
    required int graphemeId,
    required bool mastered,
  }) async {
    await _db.into(_db.graphemeProgress).insertOnConflictUpdate(
          GraphemeProgressCompanion.insert(
            childId: childId,
            graphemeId: graphemeId,
            status: Value(mastered ? 'sicher' : 'neu'),
            box: Value(mastered ? maxBox : 1),
          ),
        );
  }

  /// Ergebnis einer Uebung verbuchen: Leitner-Box hoch (richtig) oder
  /// zurueck auf 1 (unsicher). Ab der obersten Box gilt der Laut als "sicher".
  Future<void> recordResult({
    required int childId,
    required int graphemeId,
    required bool correct,
  }) async {
    final current = await (_db.select(_db.graphemeProgress)
          ..where((p) =>
              p.childId.equals(childId) & p.graphemeId.equals(graphemeId)))
        .getSingleOrNull();

    final oldBox = current?.box ?? 1;
    final newBox = correct
        ? (oldBox + 1).clamp(1, maxBox)
        : 1;
    final status = correct && newBox >= maxBox
        ? 'sicher'
        : (correct ? 'lernend' : 'neu');

    await _db.into(_db.graphemeProgress).insertOnConflictUpdate(
          GraphemeProgressCompanion.insert(
            childId: childId,
            graphemeId: graphemeId,
            status: Value(status),
            box: Value(newBox),
            repetitions: Value((current?.repetitions ?? 0) + 1),
            lastSeen: Value(DateTime.now()),
          ),
        );
  }

  /// Der naechste Laut, den die Eltern einfuehren sollten: das erste Graphem
  /// der Art [kind] (nach Lern-Reihenfolge), das noch nicht "sicher" ist.
  /// Gibt null zurueck, wenn schon alle sitzen.
  ///
  /// Ist [boostName] gesetzt, werden – nach den Mama/Papa-Basislauten – die
  /// Buchstaben des eigenen Namens sanft vorgezogen (untereinander weiter nach
  /// Schwierigkeit), damit das Kind zielgerichtet auf seinen Namen hinarbeitet.
  Future<Grapheme?> nextGraphemeToTeach(
    int childId,
    String kind, {
    String? boostName,
  }) async {
    final graphemes = await (_db.select(_db.graphemes)
          ..where((g) => g.kind.equals(kind))
          ..orderBy([
            (g) => OrderingTerm(expression: g.sortOrder),
            (g) => OrderingTerm(expression: g.id),
          ]))
        .get();

    final ordered =
        boostName == null ? graphemes : _boostNameLetters(graphemes, boostName);

    final progress = await progressFor(childId);
    for (final g in ordered) {
      if (progress[g.id]?.status != 'sicher') return g;
    }
    return null;
  }

  /// Sortiert stabil: erst Mama/Papa-Basis (m, a, p), dann Namensbuchstaben,
  /// dann der Rest – innerhalb jeder Gruppe bleibt die Schwierigkeits-
  /// Reihenfolge (sortOrder) erhalten.
  List<Grapheme> _boostNameLetters(List<Grapheme> graphemes, String name) {
    const base = {'m', 'a', 'p'};
    final names = nameLetters(name);
    int rank(Grapheme g) {
      final s = g.symbol.toLowerCase();
      if (base.contains(s)) return 0;
      if (names.contains(s)) return 1;
      return 2;
    }

    final list = [...graphemes];
    list.sort((a, b) {
      final r = rank(a).compareTo(rank(b));
      if (r != 0) return r;
      final s = a.sortOrder.compareTo(b.sortOrder);
      return s != 0 ? s : a.id.compareTo(b.id);
    });
    return list;
  }

  /// Wie viele der Buchstaben des Namens schon "sicher" sind (fuer „Mein Name").
  Future<({int total, int mastered})> nameLetterProgress(
    int childId,
    String name,
  ) async {
    final letters = nameLetters(name);
    if (letters.isEmpty) return (total: 0, mastered: 0);

    final graphemes = await (_db.select(_db.graphemes)
          ..where((g) => g.kind.equals('buchstabe')))
        .get();
    final bySymbol = {for (final g in graphemes) g.symbol.toLowerCase(): g};
    final progress = await progressFor(childId);

    var total = 0;
    var mastered = 0;
    for (final l in letters) {
      final g = bySymbol[l];
      if (g == null) continue; // Buchstabe nicht im Set (sehr selten)
      total++;
      if (progress[g.id]?.status == 'sicher') mastered++;
    }
    return (total: total, mastered: mastered);
  }

  /// Ein paar andere Grapheme derselben Art (fuer die "Zeig mir"-Auswahl),
  /// moeglichst nah an [aroundSortOrder] in der Lern-Reihenfolge – so sind die
  /// Ablenker verwechselbare Nachbarn statt immer der leichtesten Buchstaben.
  Future<List<Grapheme>> siblingGraphemes(
    String kind, {
    required int excludeId,
    required int aroundSortOrder,
    int count = 2,
  }) async {
    final graphemes = await (_db.select(_db.graphemes)
          ..where((g) => g.kind.equals(kind) & g.id.equals(excludeId).not()))
        .get();
    graphemes.sort((a, b) {
      final da = (a.sortOrder - aroundSortOrder).abs();
      final db = (b.sortOrder - aroundSortOrder).abs();
      final c = da.compareTo(db);
      return c != 0 ? c : a.sortOrder.compareTo(b.sortOrder);
    });
    return graphemes.take(count).toList();
  }

  /// Wörter (mit evtl. Foto) zu einer Liste von Wort-Texten – für die
  /// kuratierten Beispiele einer Lautverbindung (exakte Wörter statt
  /// Substring-Suche).
  Future<List<WordWithImage>> wordsByText(List<String> words) async {
    if (words.isEmpty) return const [];
    final rows = await (_db.select(_db.words).join([
      leftOuterJoin(
        _db.imageAssets,
        _db.imageAssets.id.equalsExp(_db.words.imageId),
      ),
    ])
          ..where(_db.words.word.isIn(words)))
        .get();
    return rows
        .map((r) => WordWithImage(
              word: r.readTable(_db.words),
              imagePath: r.readTableOrNull(_db.imageAssets)?.filePath,
            ))
        .toList();
  }

  // ---------------- Eigene Wortbilder (Eltern-Bereich) ----------------

  /// Alle Woerter mit ihrem aktuell hinterlegten Foto (falls vorhanden).
  Future<List<WordWithImage>> allWordsWithImages() async {
    final rows = await (_db.select(_db.words).join([
      leftOuterJoin(
        _db.imageAssets,
        _db.imageAssets.id.equalsExp(_db.words.imageId),
      ),
    ])
          ..orderBy([OrderingTerm(expression: _db.words.word)]))
        .get();
    return rows
        .map((r) => WordWithImage(
              word: r.readTable(_db.words),
              imagePath: r.readTableOrNull(_db.imageAssets)?.filePath,
            ))
        .toList();
  }

  /// Fotopfade fuer eine Menge Wort-IDs (nur wo eines hinterlegt ist).
  Future<Map<int, String>> imagePathsForWords(List<int> ids) async {
    if (ids.isEmpty) return const {};
    final rows = await (_db.select(_db.words).join([
      innerJoin(
        _db.imageAssets,
        _db.imageAssets.id.equalsExp(_db.words.imageId),
      ),
    ])
          ..where(_db.words.id.isIn(ids)))
        .get();
    return {
      for (final r in rows)
        r.readTable(_db.words).id: r.readTable(_db.imageAssets).filePath,
    };
  }

  /// Woerter, die zur Eingabe passen (fuer die Foto-Benennung): exakte und
  /// mit [query] beginnende zuerst, dann sonstige Teiltreffer. Case-insensitiv.
  Future<List<Word>> searchWords(String query, {int limit = 8}) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final rows = await (_db.select(_db.words)
          ..where((w) => w.word.lower().like('%$q%')))
        .get();
    rows.sort((a, b) {
      int rank(Word w) {
        final s = w.word.toLowerCase();
        if (s == q) return 0;
        if (s.startsWith(q)) return 1;
        return 2;
      }

      final r = rank(a).compareTo(rank(b));
      if (r != 0) return r;
      final l = a.word.length.compareTo(b.word.length);
      return l != 0 ? l : a.word.toLowerCase().compareTo(b.word.toLowerCase());
    });
    return rows.take(limit).toList();
  }

  /// Exakter (case-insensitiver) Wort-Treffer oder null.
  Future<Word?> findWordByText(String text) async {
    final t = text.trim().toLowerCase();
    if (t.isEmpty) return null;
    final rows = await (_db.select(_db.words)
          ..where((w) => w.word.lower().equals(t)))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  /// Legt ein neues (eigenes) Wort mit hinterlegtem Foto an und gibt es zurueck.
  /// Solche Woerter tauchen danach in Wort- und Laut-Uebungen auf (sobald ihre
  /// Buchstaben eingefuehrt sind).
  Future<Word> createWordWithImage(String word, String filePath) async {
    final asset = await _db.into(_db.imageAssets).insertReturning(
          ImageAssetsCompanion.insert(filePath: filePath, label: Value(word)),
        );
    return _db.into(_db.words).insertReturning(
          WordsCompanion.insert(
            word: word.trim(),
            imageId: Value(asset.id),
            isCustom: const Value(true),
          ),
        );
  }

  /// Hinterlegt ein Foto (Dateipfad) fuer ein Wort – profooluebergreifend.
  Future<void> setWordImage(int wordId, String filePath, String label) async {
    final asset = await _db.into(_db.imageAssets).insertReturning(
          ImageAssetsCompanion.insert(filePath: filePath, label: Value(label)),
        );
    await (_db.update(_db.words)..where((w) => w.id.equals(wordId)))
        .write(WordsCompanion(imageId: Value(asset.id)));
  }

  /// Entfernt die Verknuepfung zum eigenen Foto (Standardbild greift wieder).
  Future<void> clearWordImage(int wordId) async {
    await (_db.update(_db.words)..where((w) => w.id.equals(wordId)))
        .write(const WordsCompanion(imageId: Value(null)));
  }
}
