import 'package:drift/drift.dart';

import '../db/database.dart';

/// Kleine App-Einstellungen/Flags im vorhandenen `app_meta`-Schlüssel-Wert-
/// Speicher (offline, ohne zusätzliche Abhängigkeit).
class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  static const _welcomeKey = 'welcome_seen';

  /// Ob der Willkommens-Screen schon gezeigt wurde (erster Start).
  Future<bool> welcomeSeen() async {
    final row = await (_db.select(_db.appMeta)
          ..where((m) => m.metaKey.equals(_welcomeKey)))
        .getSingleOrNull();
    return (row?.intValue ?? 0) == 1;
  }

  Future<void> markWelcomeSeen() =>
      _db.into(_db.appMeta).insertOnConflictUpdate(
            AppMetaCompanion.insert(
              metaKey: _welcomeKey,
              intValue: const Value(1),
            ),
          );
}
