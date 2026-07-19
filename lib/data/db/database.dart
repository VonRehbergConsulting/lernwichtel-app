import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

/// Ein Kind-Profil. Fortschritt wird pro Kind gespeichert.
@DataClassName('Child')
class Children extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 40)();

  /// Optionaler Avatar: Emoji ODER Dateipfad zu einem Foto.
  TextColumn get avatar => text().nullable()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Buchstaben und Lautverbindungen. Global (fuer alle Kinder gleich).
class Graphemes extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Anzeige-Symbol, z. B. "m", "sch", "ä".
  TextColumn get symbol => text()();

  /// Stabiler Schluessel aus der Seed-JSON, z. B. "m", "ch-ich".
  TextColumn get graphemeKey => text().unique()();

  /// "buchstabe" oder "verbindung".
  TextColumn get kind => text()();

  /// Beschreibung des reinen Lauts (fuer Aufnahme-Referenz).
  TextColumn get sound => text().nullable()();

  /// Asset-Pfad zur Laut-Aufnahme, z. B. "assets/audio/laute/m.mp3".
  TextColumn get audioAsset => text().nullable()();

  /// Kindgerechter Merksatz (v. a. fuer Lautverbindungen), z. B.
  /// "au – wie beim Aua!".
  TextColumn get merkhilfe => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(999))();
}

/// Lernfortschritt eines Kindes je Graphem (Leitner-Boxen).
class GraphemeProgress extends Table {
  IntColumn get childId =>
      integer().references(Children, #id, onDelete: KeyAction.cascade)();
  IntColumn get graphemeId =>
      integer().references(Graphemes, #id, onDelete: KeyAction.cascade)();

  /// "neu" | "lernend" | "sicher".
  TextColumn get status => text().withDefault(const Constant('neu'))();

  /// Leitner-Box (1..3): hoehere Box = seltener wiederholen.
  IntColumn get box => integer().withDefault(const Constant(1))();
  IntColumn get repetitions => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSeen => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {childId, graphemeId};
}

/// Bilder werden profieluebergreifend geteilt.
class ImageAssets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get filePath => text()();
  TextColumn get label => text().nullable()();
}

/// Wortliste (global). Bild optional referenziert (geteilt).
class Words extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// Das Wort selbst. Nicht "text" nennen: kollidiert mit Table.text().
  TextColumn get word => text()();
  IntColumn get imageId => integer()
      .nullable()
      .references(ImageAssets, #id, onDelete: KeyAction.setNull)();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
}

/// Lese-Fortschritt je Kind: wie viele Woerter der Progression freigeschaltet
/// sind (waechst mit den Uebungsrunden).
class ReadingProgress extends Table {
  IntColumn get childId =>
      integer().references(Children, #id, onDelete: KeyAction.cascade)();
  IntColumn get wordsUnlocked => integer().withDefault(const Constant(3))();

  /// Freigeschaltete Lautverbindungen (Batch-Lernen), Start 2.
  IntColumn get combosUnlocked => integer().withDefault(const Constant(2))();

  @override
  Set<Column> get primaryKey => {childId};
}

/// Welche Woerter ein Kind ueben soll (Auswahl pro Kind).
class WordEnabled extends Table {
  IntColumn get childId =>
      integer().references(Children, #id, onDelete: KeyAction.cascade)();
  IntColumn get wordId =>
      integer().references(Words, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {childId, wordId};
}

/// Rechen-Faehigkeit je Kind und Modul (adaptive Schwierigkeit).
class MathSkills extends Table {
  IntColumn get childId =>
      integer().references(Children, #id, onDelete: KeyAction.cascade)();

  /// "ziffern" | "zehner" | "addieren" | "subtrahieren".
  TextColumn get module => text()();
  IntColumn get level => integer().withDefault(const Constant(1))();
  IntColumn get correctStreak => integer().withDefault(const Constant(0))();
  IntColumn get wrongStreak => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {childId, module};
}

/// Protokoll einzelner Rechenversuche (Basis fuer Statistik/Adaptivitaet).
class MathAttempts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId =>
      integer().references(Children, #id, onDelete: KeyAction.cascade)();
  TextColumn get module => text()();
  TextColumn get problem => text()();
  BoolColumn get correct => boolean()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Zahl-Lernfortschritt je Kind (Mengen/Ziffern 1..10) für die geführte
/// Mathe-Lektion (Drei-Perioden). Spiegelt [GraphemeProgress] fürs Lesen.
class NumberProgress extends Table {
  IntColumn get childId =>
      integer().references(Children, #id, onDelete: KeyAction.cascade)();
  IntColumn get value => integer()();
  TextColumn get status => text().withDefault(const Constant('neu'))();
  IntColumn get box => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {childId, value};
}

/// Manuelle Freischaltung eines Lern-Bereichs je Kind (durch Eltern oder beim
/// Anlegen gewaehltes Startniveau). Existiert eine Zeile, gilt der Bereich als
/// freigeschaltet – zusaetzlich zu automatisch aus dem Fortschritt abgeleiteten
/// Freischaltungen. `sectionKey` entspricht der Menue-Icon-ID
/// (z. B. `lese_verbindungen`, `math_addieren`).
class SectionUnlocks extends Table {
  IntColumn get childId =>
      integer().references(Children, #id, onDelete: KeyAction.cascade)();
  TextColumn get sectionKey => text()();

  @override
  Set<Column> get primaryKey => {childId, sectionKey};
}

/// Fotos, die Kinder bei der Laut-Jagd selbst geschossen haben und die die
/// Eltern behalten wollten. Werden spaeter als „Meine Fundstuecke" wieder
/// gezeigt (persoenlicher Bezug zum gelernten Laut).
@DataClassName('Fundstueck')
class Fundstuecke extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get childId =>
      integer().references(Children, #id, onDelete: KeyAction.cascade)();

  /// Kleingeschriebenes Symbol des gejagten Lauts, z. B. "m".
  TextColumn get letter => text()();

  /// Pfad zur gespeicherten Foto-Datei (im App-Dokumente-Ordner).
  TextColumn get filePath => text()();
  DateTimeColumn get createdAt =>
      dateTime().withDefault(currentDateAndTime)();
}

/// Kleiner Schluessel-Wert-Speicher fuer App-Metadaten (z. B. die
/// Inhalts-Version). WICHTIG: NICHT PRAGMA user_version verwenden – das nutzt
/// drift intern fuer die Schema-Version.
class AppMeta extends Table {
  TextColumn get metaKey => text()();
  IntColumn get intValue => integer().nullable()();

  @override
  Set<Column> get primaryKey => {metaKey};
}

@DriftDatabase(
  tables: [
    Children,
    Graphemes,
    GraphemeProgress,
    ImageAssets,
    Words,
    WordEnabled,
    ReadingProgress,
    MathSkills,
    MathAttempts,
    NumberProgress,
    SectionUnlocks,
    Fundstuecke,
    AppMeta,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Nur fuer Tests: DB im Speicher.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        // Bewusst idempotent/selbstheilend: fruehere Versionen haben
        // PRAGMA user_version (drift-Schema-Version) mit der Inhalts-Version
        // ueberschrieben. Deshalb pruefen wir jede Aenderung auf Existenz,
        // statt uns auf `from` zu verlassen.
        onUpgrade: (m, from, to) async {
          if (!await _hasColumn('graphemes', 'merkhilfe')) {
            await m.addColumn(graphemes, graphemes.merkhilfe);
          }
          if (!await _hasTable('reading_progress')) {
            await m.createTable(readingProgress);
          }
          if (!await _hasColumn('reading_progress', 'combos_unlocked')) {
            await m.addColumn(readingProgress, readingProgress.combosUnlocked);
          }
          if (!await _hasTable('app_meta')) {
            await m.createTable(appMeta);
          }
          if (!await _hasTable('section_unlocks')) {
            await m.createTable(sectionUnlocks);
          }
          if (!await _hasTable('number_progress')) {
            await m.createTable(numberProgress);
          }
          if (!await _hasTable('fundstuecke')) {
            await m.createTable(fundstuecke);
          }
        },
        beforeOpen: (details) async {
          // Fremdschluessel in SQLite explizit aktivieren.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<bool> _hasTable(String table) async {
    final rows = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type='table' AND name = ?",
      variables: [Variable<String>(table)],
    ).get();
    return rows.isNotEmpty;
  }

  Future<bool> _hasColumn(String table, String column) async {
    final rows = await customSelect('PRAGMA table_info($table)').get();
    return rows.any((r) => r.read<String>('name') == column);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'education_app.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
