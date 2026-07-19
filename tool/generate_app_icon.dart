// Reproduzierbarer Generator fuer das App-Icon (Lernwichtel) via gpt-image-1.
//
// Erzeugt zwei 1024x1024-PNGs:
//   assets/icon/app_icon.png             – deckend (fuer iOS + Android-Legacy)
//   assets/icon/app_icon_foreground.png  – transparent (Android Adaptive Icon)
//
// Danach die Plattform-Groessen ableiten:
//   fvm dart run flutter_launcher_icons
//
// Aufruf (aus dem Projektwurzelverzeichnis):
//   OPENAI_API_KEY=sk-... fvm dart run tool/generate_app_icon.dart [--force]

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const _size = '1024x1024';

/// Gemeinsamer Bild-Kern: eine niedliche, klar erkennbare Figur, mittig,
/// funktioniert auch klein.
const _subject =
    'App icon of a cute friendly cartoon gnome ("Lernwichtel") for a '
    'children\'s learning app: round rosy cheeks, a small pointy hat, holding '
    'a big pencil, big friendly eyes, warm cheerful colors, bold thick clean '
    'outline, flat 2D style, simple and centered, no text, no letters. '
    'The subject fills the middle and reads well even at small sizes.';

Future<void> main(List<String> args) async {
  final force = args.contains('--force');
  final key = Platform.environment['OPENAI_API_KEY']?.trim();
  if (key == null || key.isEmpty) {
    stderr.writeln('FEHLER: OPENAI_API_KEY ist nicht gesetzt.');
    exit(1);
  }

  final dir = Directory('assets/icon')..createSync(recursive: true);
  final client = http.Client();
  try {
    await _make(
      client,
      key,
      file: File('${dir.path}/app_icon.png'),
      force: force,
      // Deckend: weicher, warmer Hintergrund (passt zum App-Cremeton).
      prompt: '$_subject Soft warm solid cream background (#FFF8EF), '
          'the figure gently centered.',
      transparent: false,
    );
    await _make(
      client,
      key,
      file: File('${dir.path}/app_icon_foreground.png'),
      force: force,
      // Transparent + reichlich Rand (Android beschneidet die Ecken).
      prompt: '$_subject Fully transparent background, no background. Keep the '
          'whole figure well within the central 70% with generous padding on '
          'all sides (safe zone for adaptive icons).',
      transparent: true,
    );
  } finally {
    client.close();
  }
  stdout.writeln('\nFertig. Jetzt: fvm dart run flutter_launcher_icons');
}

Future<void> _make(
  http.Client client,
  String key, {
  required File file,
  required String prompt,
  required bool transparent,
  required bool force,
}) async {
  if (file.existsSync() && !force) {
    stdout.writeln('• ${file.path} existiert schon (--force zum Neu-Erzeugen)');
    return;
  }
  stdout.write('• ${file.path} ... ');
  final bytes = await _generate(client, key, prompt, transparent);
  await file.writeAsBytes(bytes);
  stdout.writeln('ok (${(bytes.length / 1024).round()} KB)');
}

Future<List<int>> _generate(
  http.Client client,
  String apiKey,
  String prompt,
  bool transparent,
) async {
  final body = {
    'model': 'gpt-image-1',
    'prompt': prompt,
    'n': 1,
    'size': _size,
    'quality': 'high',
    if (transparent) 'background': 'transparent',
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
