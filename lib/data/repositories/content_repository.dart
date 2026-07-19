import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../db/database.dart';

/// Laedt die Seed-Inhalte (assets/content/lerninhalte.json) in die Datenbank
/// und stellt Lese-Zugriffe auf Grapheme und Woerter bereit.
class ContentRepository {
  ContentRepository(this._db);

  final AppDatabase _db;
  static const _seedAsset = 'assets/content/lerninhalte.json';

  /// Bei jeder inhaltlichen Aenderung der Seed-JSON hochzaehlen -> die App
  /// zieht neue Grapheme/Merksaetze/Woerter beim naechsten Start nach.
  static const _contentVersion = 4;

  /// Cache: Graphem-Key -> kuratierte Beispielwoerter (aus der Seed-JSON).
  Map<String, List<String>>? _exampleCache;

  Future<Map<String, List<String>>> _exampleMap() async {
    if (_exampleCache != null) return _exampleCache!;
    final raw = await rootBundle.loadString(_seedAsset);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final map = <String, List<String>>{};
    for (final section in ['buchstaben', 'lautverbindungen']) {
      for (final e in (json[section] as List).cast<Map<String, dynamic>>()) {
        final key = e['grapheme'] as String;
        map[key] = (e['beispiele'] as List?)?.cast<String>() ?? const [];
      }
    }
    return _exampleCache = map;
  }

  /// Kuratierte Beispielwoerter zu einem Graphem (per stabilem Key). Nutzt die
  /// Seed-Liste statt einer Substring-Suche – so liefert „ch" (ch-ach/ch-ich)
  /// nicht faelschlich sch-/chs-Woerter (Schatz, Fuchs, Sparschwein …).
  Future<List<String>> exampleWords(String graphemeKey) async =>
      (await _exampleMap())[graphemeKey] ?? const [];

  /// Fuellt bzw. aktualisiert Grapheme und Woerter. Bestehende Grapheme werden
  /// per Schluessel abgeglichen (Update statt Neuanlage) -> der Kind-Fortschritt
  /// (haengt an der graphemeId) bleibt erhalten.
  Future<void> ensureSeeded() async {
    if (await _storedContentVersion() == _contentVersion) return;

    final raw = await rootBundle.loadString(_seedAsset);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final buchstaben = (json['buchstaben'] as List).cast<Map<String, dynamic>>();
    final verbindungen =
        (json['lautverbindungen'] as List).cast<Map<String, dynamic>>();

    final existing = {
      for (final g in await _db.select(_db.graphemes).get()) g.graphemeKey: g,
    };
    final woerter = <String>{};

    Future<void> upsert(Map<String, dynamic> e, String kind) async {
      final key = e['grapheme'] as String;
      final symbol = (e['grapheme_anzeige'] as String?) ?? key;
      final sound = Value(e['laut'] as String?);
      final merkhilfe = Value(e['merkhilfe'] as String?);
      final audio = Value('assets/audio/laute/$key.mp3');
      final sortOrder = Value((e['reihenfolge'] as int?) ?? 999);

      if (existing.containsKey(key)) {
        await (_db.update(_db.graphemes)
              ..where((g) => g.graphemeKey.equals(key)))
            .write(GraphemesCompanion(
          symbol: Value(symbol),
          kind: Value(kind),
          sound: sound,
          merkhilfe: merkhilfe,
          audioAsset: audio,
          sortOrder: sortOrder,
        ));
      } else {
        await _db.into(_db.graphemes).insert(GraphemesCompanion.insert(
              symbol: symbol,
              graphemeKey: key,
              kind: kind,
              sound: sound,
              merkhilfe: merkhilfe,
              audioAsset: audio,
              sortOrder: sortOrder,
            ));
      }
      for (final w in (e['beispiele'] as List? ?? const [])) {
        woerter.add(w as String);
      }
    }

    for (final e in buchstaben) {
      await upsert(e, 'buchstabe');
    }
    for (final e in verbindungen) {
      await upsert(e, 'verbindung');
    }

    // Nur neue Woerter ergaenzen (Bild-/Auswahl-Bezuege bleiben erhalten).
    final vorhandeneWoerter =
        (await _db.select(_db.words).get()).map((w) => w.word).toSet();
    for (final w in woerter) {
      if (!vorhandeneWoerter.contains(w)) {
        await _db.into(_db.words).insert(WordsCompanion.insert(word: w));
      }
    }

    await _setContentVersion(_contentVersion);
  }

  static const _contentKey = 'content_version';

  /// Inhalts-Version aus der app_meta-Tabelle (NICHT PRAGMA user_version!).
  Future<int> _storedContentVersion() async {
    final row = await (_db.select(_db.appMeta)
          ..where((m) => m.metaKey.equals(_contentKey)))
        .getSingleOrNull();
    return row?.intValue ?? 0;
  }

  Future<void> _setContentVersion(int v) =>
      _db.into(_db.appMeta).insertOnConflictUpdate(
            AppMetaCompanion.insert(metaKey: _contentKey, intValue: Value(v)),
          );

  Future<List<Grapheme>> graphemesByKind(String kind) {
    return (_db.select(_db.graphemes)
          ..where((g) => g.kind.equals(kind))
          ..orderBy([
            (g) => OrderingTerm(expression: g.sortOrder),
            (g) => OrderingTerm(expression: g.id), // Seed-Reihenfolge als Tiebreak
          ]))
        .get();
  }

  /// Liest die Uebungssaetze direkt aus der Seed-JSON (nach Stufe sortiert).
  /// Saetze brauchen keinen Fortschritt und liegen daher nicht in der DB.
  Future<List<SentenceItem>> loadSentences() async {
    final raw = await rootBundle.loadString(_seedAsset);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final list = (json['saetze'] as List).cast<Map<String, dynamic>>();
    final sentences = list
        .map((e) => SentenceItem(
              text: e['text'] as String,
              level: (e['stufe'] as int?) ?? 1,
            ))
        .toList()
      ..sort((a, b) => a.level.compareTo(b.level));
    return sentences;
  }
}

/// Ein einfacher Uebungssatz mit Schwierigkeitsstufe.
class SentenceItem {
  const SentenceItem({required this.text, required this.level});
  final String text;
  final int level;

  /// Woerter des Satzes (fuer wortweises Antippen/Vorlesen).
  List<String> get words => text.split(RegExp(r'\s+'));
}
