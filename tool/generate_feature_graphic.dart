// Reproduzierbarer Generator fuer die Play-Store-Feature-Grafik (Hero-Banner)
// via gpt-image-1.
//
// gpt-image-1 kann 1024x500 nicht direkt erzeugen -> wir generieren ein
// 1536x1024-Motiv und schneiden es mittig auf 1024x500 zu.
//
// Erzeugt:  store/feature_graphic.png  (1024x500, Play-Store-Vorstellungsgrafik)
//
// Aufruf (aus dem Projektwurzelverzeichnis):
//   OPENAI_API_KEY=sk-... fvm dart run tool/generate_feature_graphic.dart [--force]

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

const _genSize = '1536x1024'; // Landscape; danach mittig auf 1024x500 zuschneiden

/// Wichtel spielt mit Buchstaben, Silben und Zahlen – warmes, ruhiges Sticker-
/// Motiv in der App-Farbwelt. Bewusst OHNE echten Text (gpt-image-1 verkrakelt
/// Wörter): nur einzelne dekorative Buchstaben/Ziffern auf den Bausteinen.
const _prompt =
    'A wide horizontal banner illustration for a children\'s learning app '
    'called Lernwichtel. A cute friendly cartoon gnome with round rosy cheeks '
    'and a small red pointy hat sits and joyfully plays with big colorful '
    'wooden blocks and cards: alphabet letter blocks, little syllable cards and '
    'number blocks gently floating and scattered around him. Cheerful and calm '
    'scene, soft warm cream background (#FFF8EF), coral red, denim blue and '
    'sunny yellow accents, bold thick clean black outline, flat 2D sticker '
    'style, lots of friendly playful energy. Keep calm empty background space on '
    'the left and right sides. No text and no words; only a few simple single '
    'decorative letters and single digits on the blocks.';

Future<void> main(List<String> args) async {
  final force = args.contains('--force');
  final key = Platform.environment['OPENAI_API_KEY']?.trim();
  if (key == null || key.isEmpty) {
    stderr.writeln('FEHLER: OPENAI_API_KEY ist nicht gesetzt.');
    exit(1);
  }

  final out = File('store/feature_graphic.png');
  if (out.existsSync() && !force) {
    stdout.writeln('• ${out.path} existiert schon (--force zum Neu-Erzeugen)');
    return;
  }
  Directory('store').createSync(recursive: true);

  final client = http.Client();
  try {
    stdout.write('• generiere $_genSize ... ');
    final raw = await _generate(client, key, _prompt);
    stdout.writeln('ok (${(raw.length / 1024).round()} KB)');

    // Mittiger Crop aufs Zielverhaeltnis 1024:500, dann auf 1024x500 skalieren.
    final src = img.decodeImage(raw);
    if (src == null) throw 'Konnte generiertes Bild nicht dekodieren.';
    const targetRatio = 1024 / 500;
    final cropH = (src.width / targetRatio).round();
    final top = ((src.height - cropH) / 2).round().clamp(0, src.height);
    final cropped = img.copyCrop(
      src,
      x: 0,
      y: top,
      width: src.width,
      height: cropH.clamp(1, src.height),
    );
    final banner = img.copyResize(
      cropped,
      width: 1024,
      height: 500,
      interpolation: img.Interpolation.cubic,
    );
    out.writeAsBytesSync(img.encodePng(banner));
    stdout.writeln('• gespeichert: ${out.path} (1024x500)');
    stdout.writeln('\nFertig. In der Play Console unter "Grafiken" als '
        'Vorstellungsgrafik hochladen.');
  } finally {
    client.close();
  }
}

Future<Uint8List> _generate(
  http.Client client,
  String apiKey,
  String prompt,
) async {
  final body = {
    'model': 'gpt-image-1',
    'prompt': prompt,
    'n': 1,
    'size': _genSize,
    'quality': 'high',
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
