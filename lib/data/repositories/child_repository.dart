import 'package:drift/drift.dart';

import '../db/database.dart';
import 'fund_repository.dart';

/// Zugriff auf Kind-Profile.
class ChildRepository {
  ChildRepository(this._db, this._funds);

  final AppDatabase _db;
  final FundRepository _funds;

  /// Live-Stream aller Profile (aktualisiert die UI automatisch).
  Stream<List<Child>> watchAll() {
    return (_db.select(_db.children)
          ..orderBy([(c) => OrderingTerm(expression: c.createdAt)]))
        .watch();
  }

  Future<List<Child>> getAll() {
    return (_db.select(_db.children)
          ..orderBy([(c) => OrderingTerm(expression: c.createdAt)]))
        .get();
  }

  Future<Child> create({required String name, String? avatar}) {
    return _db.into(_db.children).insertReturning(
          ChildrenCompanion.insert(name: name, avatar: Value(avatar)),
        );
  }

  Future<void> rename(int id, String name) {
    return (_db.update(_db.children)..where((c) => c.id.equals(id)))
        .write(ChildrenCompanion(name: Value(name)));
  }

  Future<void> delete(int id) async {
    // Erst die Fotodateien des Kindes aufräumen, dann die Zeile löschen
    // (der Cascade entfernt die zugehörigen Fundstück-Zeilen mit).
    await _funds.deleteFilesForChild(id);
    await (_db.delete(_db.children)..where((c) => c.id.equals(id))).go();
  }
}
