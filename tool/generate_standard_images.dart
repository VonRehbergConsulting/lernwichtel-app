// Reproduzierbarer Generator fuer Comic-Standardbilder je Wort.
//
// Ablauf pro Wort (nur wenn noch KEIN Bild existiert):
//   1. Claude (Anthropic Messages API) schreibt einen Motiv-Prompt.
//   2. Der Prompt wird in assets/content/bild_prompts.json versioniert.
//   3. Ein fixer Stil-Baustein wird angehaengt (=> konsistenter Look).
//   4. OpenAI gpt-image-1 rendert das PNG nach assets/images/standard/<slug>.png
//
// Erneuter Lauf erzeugt nur Bilder fuer Woerter ohne vorhandenes PNG.
//
// Aufruf (aus dem Projektwurzelverzeichnis):
//   export ANTHROPIC_API_KEY=...   (oder `ant auth`-Profil, siehe unten)
//   export OPENAI_API_KEY=...
//   fvm dart run tool/generate_standard_images.dart
//
// Optionen:
//   --quality=low|medium|high   (Standard: medium)
//   --force                     (auch vorhandene Bilder neu erzeugen)
//   --only=Apfel,Ball           (nur diese Woerter)
//   --limit=5                   (hoechstens N Bilder in diesem Lauf)
//   --dry-run                   (nur Prompts erzeugen, keine Bilder rendern)

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'webp.dart';

const _anthropicModel = 'claude-opus-4-8';
const _anthropicVersion = '2023-06-01';
const _imageSize = '1024x1024';

/// Fixer Stil-Baustein: wird an JEDEN Prompt angehaengt -> einheitlicher Look,
/// jetzt und in Zukunft. Hier aendern = neuer Gesamtstil (dann --force noetig).
const _styleSuffix =
    'Style: flat 2D children\'s book cartoon illustration, bold clean black '
    'outlines, bright cheerful flat colors, one simple friendly subject '
    'centered, plain soft off-white background, minimal detail. No text, no '
    'letters, no numbers, no words anywhere in the image. Cute and simple, '
    'appropriate for a 3 to 5 year old.';

const _promptSystem =
    'You write prompts for an image generator used in a German children\'s '
    'reading app. Given a single German word a small child is learning, produce '
    'a short, concrete ENGLISH visual description of ONE clear subject that '
    'depicts the word so a 3-5 year old instantly recognizes it. Rules: exactly '
    'one subject; concrete and literal; never include text, letters or numbers '
    'in the scene; if the word is abstract, pick one simple representative '
    'scene. Keep it under 30 words. Do NOT add style directives - those are '
    'appended separately.';

Future<void> main(List<String> args) async {
  final opts = _parseArgs(args);

  // .trim() entfernt versehentliche Leerzeichen/Zeilenumbrueche.
  // ANTHROPIC_API_KEY ist OPTIONAL: nur noetig, wenn fuer ein Wort noch kein
  // Prompt in bild_prompts.json steht. Sind alle Prompts vorhanden, reicht der
  // OpenAI-Key.
  final anthropicKey = Platform.environment['ANTHROPIC_API_KEY']?.trim();
  final openaiKey = Platform.environment['OPENAI_API_KEY']?.trim();
  if (!opts.dryRun && (openaiKey == null || openaiKey.isEmpty)) {
    _fail('OPENAI_API_KEY ist nicht gesetzt (fuer die Bildgenerierung).');
  }

  final seedFile = File('assets/content/lerninhalte.json');
  if (!seedFile.existsSync()) {
    _fail('assets/content/lerninhalte.json nicht gefunden. '
        'Bitte aus dem Projektwurzelverzeichnis starten.');
  }
  final seed = jsonDecode(await seedFile.readAsString()) as Map<String, dynamic>;

  // Woerter einsammeln (Buchstaben-Beispiele + Lautverbindungs-Beispiele).
  final words = <String>{};
  for (final key in ['buchstaben', 'lautverbindungen']) {
    for (final e in (seed[key] as List? ?? const [])) {
      for (final w in ((e as Map)['beispiele'] as List? ?? const [])) {
        words.add(w as String);
      }
    }
  }
  var wordList = words.toList()..sort();
  if (opts.only.isNotEmpty) {
    final wanted = opts.only.map((e) => e.toLowerCase()).toSet();
    wordList = wordList.where((w) => wanted.contains(w.toLowerCase())).toList();
  }

  final outDir = Directory('assets/images/standard')
    ..createSync(recursive: true);
  final promptFile = File('assets/content/bild_prompts.json');
  final prompts = promptFile.existsSync()
      ? (jsonDecode(await promptFile.readAsString()) as Map<String, dynamic>)
      : <String, dynamic>{};

  final client = http.Client();
  var created = 0;
  var skipped = 0;
  try {
    for (final word in wordList) {
      if (opts.limit != null && created >= opts.limit!) break;
      final slug = _slug(word);
      final imgFile = File('${outDir.path}/$slug.webp');
      if (imgFile.existsSync() && !opts.force) {
        skipped++;
        continue;
      }

      // 1./2. Prompt holen oder generieren (versioniert).
      var entry = prompts[word] as Map<String, dynamic>?;
      if (entry == null || (entry['prompt'] as String?)?.isEmpty != false) {
        if (anthropicKey == null || anthropicKey.isEmpty) {
          _fail('Fuer "$word" fehlt ein Prompt in bild_prompts.json und es ist '
              'kein ANTHROPIC_API_KEY gesetzt, um einen zu erzeugen. Entweder '
              'Prompt manuell ergaenzen oder ANTHROPIC_API_KEY setzen.');
        }
        stdout.write('• "$word": Prompt generieren ... ');
        final prompt = await _generatePrompt(client, anthropicKey, word);
        entry = {'slug': slug, 'prompt': prompt};
        prompts[word] = entry;
        // Inkrementell speichern -> nichts geht bei Abbruch verloren.
        await promptFile.writeAsString(
          const JsonEncoder.withIndent('  ').convert(prompts),
        );
        stdout.writeln('ok');
      }

      if (opts.dryRun) {
        skipped++;
        continue;
      }

      // 3./4. Bild rendern.
      final fullPrompt = '${entry['prompt']}\n\n$_styleSuffix';
      stdout.write('  -> Bild rendern ($slug.webp) ... ');
      final bytes = await _generateImage(
        client,
        openaiKey!,
        fullPrompt,
        opts.quality,
      );
      // Direkt als optimiertes WebP ablegen (statt großem PNG).
      await writePngAsWebp(bytes, imgFile.path, quality: 90);
      created++;
      stdout.writeln('ok (${(imgFile.lengthSync() / 1024).round()} KB WebP)');
    }
  } finally {
    client.close();
  }

  stdout.writeln('\nFertig. Neu erzeugt: $created, uebersprungen: $skipped.');
  stdout.writeln('Bilder: ${outDir.path}/<wort>.webp');
  stdout.writeln('Prompts: ${promptFile.path}');
}

// --------------------------- Anthropic ---------------------------

/// Waehlt die Authentifizierung anhand des Schluesseltyps:
/// - Console-API-Key (sk-ant-api...) -> Header `x-api-key`.
/// - OAuth-Token (sk-ant-oat..., z. B. aus Claude Code / `ant auth`) ->
///   `Authorization: Bearer` + `anthropic-beta: oauth-2025-04-20`.
Map<String, String> _anthropicHeaders(String key) {
  final base = {
    'anthropic-version': _anthropicVersion,
    'content-type': 'application/json',
  };
  if (key.startsWith('sk-ant-api')) {
    return {...base, 'x-api-key': key};
  }
  return {
    ...base,
    'authorization': 'Bearer $key',
    'anthropic-beta': 'oauth-2025-04-20',
  };
}

Future<String> _generatePrompt(
  http.Client client,
  String apiKey,
  String word,
) async {
  final body = {
    'model': _anthropicModel,
    'max_tokens': 400,
    'system': _promptSystem,
    'output_config': {
      'format': {
        'type': 'json_schema',
        'schema': {
          'type': 'object',
          'properties': {
            'prompt': {'type': 'string'},
          },
          'required': ['prompt'],
          'additionalProperties': false,
        },
      },
    },
    'messages': [
      {'role': 'user', 'content': 'Deutsches Wort: "$word"'},
    ],
  };

  final res = await _withRetry(() => client.post(
        Uri.parse('https://api.anthropic.com/v1/messages'),
        headers: _anthropicHeaders(apiKey),
        body: jsonEncode(body),
      ));
  if (res.statusCode != 200) {
    throw 'Anthropic ${res.statusCode}: ${res.body}';
  }
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  final content = json['content'] as List;
  final text = content
      .firstWhere((b) => (b as Map)['type'] == 'text')['text'] as String;
  final parsed = jsonDecode(text) as Map<String, dynamic>;
  return (parsed['prompt'] as String).trim();
}

// --------------------------- OpenAI gpt-image-1 ---------------------------

Future<List<int>> _generateImage(
  http.Client client,
  String apiKey,
  String prompt,
  String quality,
) async {
  final body = {
    'model': 'gpt-image-1',
    'prompt': prompt,
    'n': 1,
    'size': _imageSize,
    'quality': quality,
  };
  final res = await _withRetry(() => client.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'authorization': 'Bearer $apiKey',
          'content-type': 'application/json',
        },
        body: jsonEncode(body),
      ));
  if (res.statusCode != 200) {
    throw 'OpenAI ${res.statusCode}: ${res.body}';
  }
  final json = jsonDecode(res.body) as Map<String, dynamic>;
  final b64 = (json['data'] as List).first['b64_json'] as String;
  return base64Decode(b64);
}

// --------------------------- Helpers ---------------------------

Future<http.Response> _withRetry(
  Future<http.Response> Function() send, {
  int maxAttempts = 4,
}) async {
  var attempt = 0;
  while (true) {
    attempt++;
    try {
      final res = await send();
      // 429/5xx: erneut versuchen.
      if ((res.statusCode == 429 || res.statusCode >= 500) &&
          attempt < maxAttempts) {
        await Future.delayed(Duration(seconds: 2 * attempt));
        continue;
      }
      return res;
    } catch (_) {
      if (attempt >= maxAttempts) rethrow;
      await Future.delayed(Duration(seconds: 2 * attempt));
    }
  }
}

/// Muss identisch mit lib/core/utils/slug.dart sein.
String _slug(String wort) {
  var s = wort.toLowerCase().trim();
  const umlaute = {'ä': 'ae', 'ö': 'oe', 'ü': 'ue', 'ß': 'ss'};
  umlaute.forEach((k, v) => s = s.replaceAll(k, v));
  s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  s = s.replaceAll(RegExp(r'^_+|_+$'), '');
  return s;
}

class _Opts {
  _Opts(this.quality, this.force, this.only, this.limit, this.dryRun);
  final String quality;
  final bool force;
  final List<String> only;
  final int? limit;
  final bool dryRun;
}

_Opts _parseArgs(List<String> args) {
  var quality = 'medium';
  var force = false;
  var dryRun = false;
  var only = <String>[];
  int? limit;
  for (final a in args) {
    if (a == '--force') {
      force = true;
    } else if (a == '--dry-run') {
      dryRun = true;
    } else if (a.startsWith('--quality=')) {
      quality = a.substring('--quality='.length);
    } else if (a.startsWith('--only=')) {
      only = a
          .substring('--only='.length)
          .split(',')
          .where((e) => e.trim().isNotEmpty)
          .toList();
    } else if (a.startsWith('--limit=')) {
      limit = int.tryParse(a.substring('--limit='.length));
    }
  }
  return _Opts(quality, force, only, limit, dryRun);
}

Never _fail(String msg) {
  stderr.writeln('FEHLER: $msg');
  exit(1);
}
