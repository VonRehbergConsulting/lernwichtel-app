import 'dart:io';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../db/database.dart';

/// „Meine Fundstücke": Fotos, die Kinder bei der Laut-Jagd geschossen haben und
/// die die Eltern behalten wollten. Kopiert das Foto dauerhaft in den
/// App-Dokumente-Ordner und merkt sich Kind + Laut fürs spätere Wiedersehen.
class FundRepository {
  FundRepository(this._db);

  final AppDatabase _db;

  /// Kopiert das Foto unter [sourcePath] in einen dauerhaften Ordner und legt
  /// einen Fundstück-Eintrag an. Gibt den gespeicherten Datensatz zurück.
  Future<Fundstueck> save({
    required int childId,
    required String letter,
    required String sourcePath,
  }) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'fundstuecke'));
    await dir.create(recursive: true);

    final stamp = DateTime.now().microsecondsSinceEpoch;
    final ext = p.extension(sourcePath).isEmpty
        ? '.jpg'
        : p.extension(sourcePath);
    final dest = p.join(dir.path, 'fund_${childId}_$stamp$ext');
    await File(sourcePath).copy(dest);

    final id = await _db.into(_db.fundstuecke).insert(
          FundstueckeCompanion.insert(
            childId: childId,
            letter: letter.toLowerCase(),
            filePath: dest,
          ),
        );
    return (_db.select(_db.fundstuecke)..where((f) => f.id.equals(id)))
        .getSingle();
  }

  /// Alle Fundstücke eines Kindes, neueste zuerst.
  Future<List<Fundstueck>> forChild(int childId) {
    return (_db.select(_db.fundstuecke)
          ..where((f) => f.childId.equals(childId))
          ..orderBy([(f) => OrderingTerm.desc(f.createdAt)]))
        .get();
  }

  /// Fundstücke eines Kindes zu einem bestimmten Laut/Buchstaben – zum
  /// prominenten Wiederzeigen beim Lernen dieses Lauts. Neueste zuerst.
  Future<List<Fundstueck>> forChildAndLetter(int childId, String letter) {
    final l = letter.toLowerCase();
    return (_db.select(_db.fundstuecke)
          ..where((f) => f.childId.equals(childId) & f.letter.equals(l))
          ..orderBy([(f) => OrderingTerm.desc(f.createdAt)]))
        .get();
  }

  /// Anzahl der Fundstücke eines Kindes (für Einstiegs-Kachel/Badge).
  Future<int> countForChild(int childId) async {
    final rows = await forChild(childId);
    return rows.length;
  }

  /// Löscht Eintrag samt Datei (verwaiste Datei wird ignoriert).
  Future<void> delete(Fundstueck fund) async {
    await (_db.delete(_db.fundstuecke)..where((f) => f.id.equals(fund.id)))
        .go();
    await _deleteFile(fund.filePath);
  }

  /// Entfernt alle Fundstück-Fotos eines Kindes von der Platte. Die DB-Zeilen
  /// selbst verschwinden per Cascade beim Löschen des Kindes – hier räumen wir
  /// die zugehörigen Dateien auf, damit keine Waisen zurückbleiben. Fotos, die
  /// zugleich als Bild eines Wortes dienen, bleiben erhalten (global genutzt).
  Future<void> deleteFilesForChild(int childId) async {
    final items = await forChild(childId);
    for (final f in items) {
      if (await _isUsedAsWordImage(f.filePath)) continue;
      await _deleteFile(f.filePath);
    }
  }

  /// Ob [path] aktuell als Wortbild (ImageAssets) verwendet wird.
  Future<bool> _isUsedAsWordImage(String path) async {
    final rows = await (_db.select(_db.imageAssets)
          ..where((a) => a.filePath.equals(path)))
        .get();
    return rows.isNotEmpty;
  }

  Future<void> _deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
