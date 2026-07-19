import 'dart:convert';
import 'dart:io';

import 'package:education_app/features/math/model/math_problem.dart';
import 'package:flutter_test/flutter_test.dart';

/// Faengt Tippfehler in den String-Vertraegen zwischen App, JSON und
/// Generator-Skripten ab (sonst erst zur Laufzeit sichtbar).
void main() {
  Map<String, dynamic> readJson(String path) =>
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

  test('jedes Seed-Wort hat einen Bild-Prompt', () {
    final seed = readJson('assets/content/lerninhalte.json');
    final prompts = readJson('assets/content/bild_prompts.json');
    final words = <String>{};
    for (final key in ['buchstaben', 'lautverbindungen']) {
      for (final e in seed[key] as List) {
        for (final w in ((e as Map)['beispiele'] as List? ?? const [])) {
          words.add(w as String);
        }
      }
    }
    final missing = words.where((w) => !prompts.containsKey(w)).toList();
    expect(missing, isEmpty, reason: 'Ohne Prompt: $missing');
  });

  test('alle in der App genutzten Menue-Icon-IDs haben einen Prompt', () {
    final prompts = readJson('assets/content/menu_prompts.json');
    const used = [
      'module_lesen', 'module_rechnen',
      'lese_buchstaben', 'lese_verbindungen', 'lese_saetze',
      'math_ziffern', 'math_zehner', 'math_addieren', 'math_subtrahieren',
      'ziffern_kennenlernen', 'ziffern_ueben',
    ];
    final missing = used.where((id) => !prompts.containsKey(id)).toList();
    expect(missing, isEmpty, reason: 'Fehlende Icon-Prompts: $missing');
  });

  test('jeder Zaehl-Objekt-Slug hat ein Wortbild', () {
    final prompts = readJson('assets/content/bild_prompts.json');
    final slugs = <String>{
      for (final v in prompts.values) (v as Map)['slug'] as String,
    };
    final missing =
        mathObjects.map((o) => o.slug).where((s) => !slugs.contains(s)).toList();
    expect(missing, isEmpty, reason: 'Objekt-Slugs ohne Bild: $missing');
  });
}
