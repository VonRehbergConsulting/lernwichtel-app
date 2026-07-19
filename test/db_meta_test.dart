import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:education_app/data/db/database.dart';
import 'package:flutter_test/flutter_test.dart';

/// Regression: Die Inhalts-Version wird in `app_meta` gespeichert und darf
/// die drift-Schema-Version (PRAGMA user_version) NICHT ueberschreiben –
/// sonst laeuft beim naechsten Start eine Migration erneut und crasht.
void main() {
  Future<int> userVersion(AppDatabase db) async {
    final row = await db.customSelect('PRAGMA user_version').getSingle();
    return row.data.values.first as int;
  }

  test('app_meta-Schreibzugriff aendert user_version nicht', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.customSelect('SELECT 1').get(); // DB oeffnen (Migration laeuft)

    final schema = await userVersion(db);
    expect(schema, greaterThan(0));

    await db.into(db.appMeta).insertOnConflictUpdate(
          AppMetaCompanion.insert(
            metaKey: 'content_version',
            intValue: const Value(3),
          ),
        );

    expect(await userVersion(db), schema); // unveraendert
    await db.close();
  });
}
