// Reproduzierbarer Generator fuer die Buchstaben-/Verbindungs-Laute.
//
// Nutzt espeak-ng (deutsche Stimme) und gibt den Laut per IPA/Phonem exakt vor
// -> es wird der reine LAUT gesprochen, nicht der Buchstabenname. Erzeugt je
// Graphem eine Datei assets/audio/laute/<key>.wav.
//
// Voraussetzung: espeak-ng installiert (macOS: `brew install espeak-ng`).
//
// Aufruf (aus dem Projektwurzelverzeichnis):
//   fvm dart run tool/generate_laute.dart
//
// Optionen: --force (auch vorhandene neu), --only=m,sch, --speed=150
//
// Die IPA-Zuordnung ist mit `espeak-ng -v de -q --ipa "<input>"` textuell
// geprueft. Klingt ein Laut daneben, einfach hier den Eintrag anpassen (oder
// spaeter im Profil durch eine eigene Aufnahme ersetzen).

import 'dart:convert';
import 'dart:io';

/// Graphem-Schluessel -> espeak-Eingabe.
/// Vokale: Buchstabe (ergibt den langen Vokal). Konsonanten/Verbindungen:
/// Phonem in [[ ]] (Kirshenbaum). Stimmhafte/Plosive mit @ = kurzes Schwa,
/// damit sie hoerbar und nicht auslautverhaertet sind.
const _phon = <String, String>{
  // Vokale (bei niedrigem Tempo ein langer, gehaltener Vokal)
  'a': 'a', 'e': 'e', 'i': 'i', 'o': 'o', 'u': 'u',
  'ae': 'ä', 'oe': 'ö', 'ue': 'ü', 'y': 'ü',
  // Dauerlaute: Phonem wiederholt -> deutlich laenger gehalten.
  'm': '[[mmmm]]', 'l': '[[llll]]', 's': '[[ssss]]', 'n': '[[nnnn]]',
  'r': '[[rrrr]]', 'f': '[[ffff]]', 'w': '[[vvvv]]', 'j': '[[jjjj]]',
  'v': '[[ffff]]', 'ss': '[[ssss]]', 'sch': '[[SSSS]]',
  'ch-ach': '[[xxxx]]', 'ch-ich': '[[CCCC]]', 'ng': '[[NNNN]]',
  // Hauchlaut + Plosive (kurz + kurzes Schwa, damit hoerbar/stimmhaft).
  'h': '[[h@]]', 't': '[[t@]]', 'b': '[[b@]]', 'p': '[[p@]]', 'd': '[[d@]]',
  'k': '[[k@]]', 'g': '[[g@]]', 'c': '[[k@]]',
  // Affrikaten / Cluster.
  'z': '[[ts]]', 'tz': '[[ts]]', 'pf': '[[pf@]]', 'qu': '[[kv@]]',
  'q': '[[kv@]]', 'x': '[[ks]]', 'sp': '[[Sp@]]', 'st': '[[St@]]',
  'ck': '[[k@]]',
  // Diphthonge / langes ie.
  'ei': '[[aI]]', 'au': '[[aU]]', 'eu': '[[OI]]', 'aeu': '[[OI]]',
  'ie': '[[i:]]',
};

Future<void> main(List<String> args) async {
  final opts = _parseArgs(args);

  if (await Process.run('which', ['espeak-ng']).then((r) => r.exitCode != 0)) {
    stderr.writeln('FEHLER: espeak-ng nicht gefunden. '
        'Installieren mit: brew install espeak-ng');
    exit(1);
  }

  final seedFile = File('assets/content/lerninhalte.json');
  if (!seedFile.existsSync()) {
    stderr.writeln('FEHLER: assets/content/lerninhalte.json nicht gefunden. '
        'Bitte aus dem Projektwurzelverzeichnis starten.');
    exit(1);
  }
  final seed = jsonDecode(await seedFile.readAsString()) as Map<String, dynamic>;

  final keys = <String>[];
  for (final k in ['buchstaben', 'lautverbindungen']) {
    for (final e in (seed[k] as List? ?? const [])) {
      keys.add((e as Map)['grapheme'] as String);
    }
  }

  final outDir = Directory('assets/audio/laute')..createSync(recursive: true);
  var created = 0;
  var skipped = 0;
  final missing = <String>[];

  for (final key in keys) {
    if (opts.only.isNotEmpty && !opts.only.contains(key)) continue;
    final input = _phon[key];
    if (input == null) {
      missing.add(key);
      continue;
    }
    final out = File('${outDir.path}/$key.wav');
    if (out.existsSync() && !opts.force) {
      skipped++;
      continue;
    }
    stdout.write('• $key ("$input") ... ');
    final res = await Process.run('espeak-ng', [
      '-v', 'de',
      '-s', '${opts.speed}',
      '-w', out.path,
      input,
    ]);
    if (res.exitCode != 0) {
      stdout.writeln('FEHLER: ${res.stderr}');
      continue;
    }
    created++;
    stdout.writeln('ok (${(out.lengthSync() / 1024).round()} KB)');
  }

  stdout.writeln('\nFertig. Neu: $created, uebersprungen: $skipped.');
  if (missing.isNotEmpty) {
    stdout.writeln('Ohne Zuordnung (uebersprungen): ${missing.join(', ')}');
  }
  stdout.writeln('Laute: ${outDir.path}/<key>.wav');
}

class _Opts {
  _Opts(this.force, this.only, this.speed);
  final bool force;
  final Set<String> only;
  final int speed;
}

_Opts _parseArgs(List<String> args) {
  var force = false;
  var only = <String>{};
  var speed = 90;
  for (final a in args) {
    if (a == '--force') {
      force = true;
    } else if (a.startsWith('--only=')) {
      only = a
          .substring('--only='.length)
          .split(',')
          .where((e) => e.trim().isNotEmpty)
          .toSet();
    } else if (a.startsWith('--speed=')) {
      speed = int.tryParse(a.substring('--speed='.length)) ?? 150;
    }
  }
  return _Opts(force, only, speed);
}
