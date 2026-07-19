// Reproduzierbarer Generator fuer Menue-Icons (statt Emojis).
//
// Liest assets/content/menu_prompts.json (Icon-ID -> Prompt), haengt einen
// festen Icon-Stil an und rendert je Eintrag ein PNG nach
// assets/images/menu/<id>.png via OpenAI gpt-image-1.
//
// Prompts sind fest hinterlegt -> es wird KEIN Anthropic-Key gebraucht.
//
// Aufruf (aus dem Projektwurzelverzeichnis):
//   OPENAI_API_KEY=sk-... fvm dart run tool/generate_menu_images.dart
//
// Optionen: --quality=low|medium|high (Standard medium), --force,
//           --only=module_lesen,math_plus

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'webp.dart';

const _imageSize = '1024x1024';

/// Icon-Stil OHNE Text (Standard). Mathe-Zeichen (+/-) sind erlaubt.
/// TRANSPARENTER Hintergrund (Sticker) -> passt auf farbige Kacheln.
const _styleNoText =
    'Style: flat 2D cartoon sticker icon, bold thick clean outline, bright '
    'cheerful colors, one simple subject filling the frame, die-cut sticker '
    'look. Fully transparent background, no background, no scenery, no square '
    'or circle behind it. No words, no text, no letters.';

/// Icon-Stil MIT Text (fuer Icons, die bewusst Buchstaben/Woerter zeigen).
/// Wird per "text": true im menu_prompts.json aktiviert.
const _styleWithText =
    'Style: flat 2D cartoon sticker icon, bold thick clean outline, bright '
    'cheerful colors, subject filling the frame, die-cut sticker look. Fully '
    'transparent background, no background, no scenery. Any letters or words '
    'must be large, clear and correctly spelled.';

Future<void> main(List<String> args) async {
  final opts = _parseArgs(args);
  final openaiKey = Platform.environment['OPENAI_API_KEY']?.trim();
  if (openaiKey == null || openaiKey.isEmpty) {
    stderr.writeln('FEHLER: OPENAI_API_KEY ist nicht gesetzt.');
    exit(1);
  }

  final promptFile = File('assets/content/menu_prompts.json');
  if (!promptFile.existsSync()) {
    stderr.writeln('FEHLER: assets/content/menu_prompts.json nicht gefunden. '
        'Bitte aus dem Projektwurzelverzeichnis starten.');
    exit(1);
  }
  final prompts =
      jsonDecode(await promptFile.readAsString()) as Map<String, dynamic>;

  final outDir = Directory('assets/images/menu')..createSync(recursive: true);
  final client = http.Client();
  var created = 0;
  var skipped = 0;
  try {
    for (final entry in prompts.entries) {
      final id = entry.key;
      if (opts.only.isNotEmpty && !opts.only.contains(id)) continue;
      final file = File('${outDir.path}/$id.webp');
      if (file.existsSync() && !opts.force) {
        skipped++;
        continue;
      }

      // Eintrag ist entweder ein Prompt-String oder {prompt, text}.
      final v = entry.value;
      final String prompt;
      final bool allowText;
      if (v is Map) {
        prompt = v['prompt'] as String;
        allowText = v['text'] == true;
      } else {
        prompt = v as String;
        allowText = false;
      }
      final suffix = allowText ? _styleWithText : _styleNoText;

      stdout.write('• $id ... ');
      final bytes = await _generateImage(
        client,
        openaiKey,
        '$prompt\n\n$suffix',
        opts.quality,
      );
      // Menü-Icons klein (384px) als optimiertes WebP ablegen.
      await writePngAsWebp(bytes, file.path, quality: 88, resize: 384);
      created++;
      stdout.writeln('ok (${(file.lengthSync() / 1024).round()} KB WebP)');
    }
  } finally {
    client.close();
  }
  stdout.writeln('\nFertig. Neu: $created, uebersprungen: $skipped.');
  stdout.writeln('Icons: ${outDir.path}/<id>.webp');
}

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
    'background': 'transparent',
  };
  var attempt = 0;
  while (true) {
    attempt++;
    try {
      final res = await client.post(
        Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'authorization': 'Bearer $apiKey',
          'content-type': 'application/json',
        },
        body: jsonEncode(body),
      );
      if ((res.statusCode == 429 || res.statusCode >= 500) && attempt < 4) {
        await Future.delayed(Duration(seconds: 2 * attempt));
        continue;
      }
      if (res.statusCode != 200) {
        throw 'OpenAI ${res.statusCode}: ${res.body}';
      }
      final json = jsonDecode(res.body) as Map<String, dynamic>;
      final b64 = (json['data'] as List).first['b64_json'] as String;
      return base64Decode(b64);
    } catch (_) {
      if (attempt >= 4) rethrow;
      await Future.delayed(Duration(seconds: 2 * attempt));
    }
  }
}

class _Opts {
  _Opts(this.quality, this.force, this.only);
  final String quality;
  final bool force;
  final Set<String> only;
}

_Opts _parseArgs(List<String> args) {
  var quality = 'medium';
  var force = false;
  var only = <String>{};
  for (final a in args) {
    if (a == '--force') {
      force = true;
    } else if (a.startsWith('--quality=')) {
      quality = a.substring('--quality='.length);
    } else if (a.startsWith('--only=')) {
      only = a
          .substring('--only='.length)
          .split(',')
          .where((e) => e.trim().isNotEmpty)
          .toSet();
    }
  }
  return _Opts(quality, force, only);
}
