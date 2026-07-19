import 'package:education_app/features/reading/word_gating.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('wordUsesOnlyKnown', () {
    test('alle Buchstaben eingeführt -> spielbar', () {
      expect(wordUsesOnlyKnown('Mama', {'m', 'a'}), isTrue);
    });

    test('ein fehlender Buchstabe -> nicht spielbar', () {
      expect(wordUsesOnlyKnown('Papa', {'p'}), isFalse);
      expect(wordUsesOnlyKnown('Oma', {'o', 'm'}), isFalse); // 'a' fehlt
    });

    test('Groß-/Kleinschreibung egal', () {
      expect(wordUsesOnlyKnown('OMA', {'o', 'm', 'a'}), isTrue);
    });

    test('leeres Wissen -> nur leeres Wort spielbar', () {
      expect(wordUsesOnlyKnown('a', <String>{}), isFalse);
    });
  });

  group('unknownGraphemeParts (Silben-Zerlegung)', () {
    // Alle Silben, längenabsteigend (wie im Bloc erzeugt).
    final vocab = ['sch', 'st', 'sp', 'ei', 'ie', 'au', 'ch', 'ck']
      ..sort((a, b) => b.length.compareTo(a.length));

    int parts(String w, Set<String> letters, Set<String> combos,
            {String? current}) =>
        unknownGraphemeParts(w,
            knownLetters: letters,
            knownCombos: combos,
            comboVocab: vocab,
            current: current);

    test('Stein braucht st UND ei – nur Buchstaben reichen nicht', () {
      // Kind kennt s,t,e,i,n als Buchstaben, lernt gerade „ei", aber „st" nicht.
      final letters = {'s', 't', 'e', 'i', 'n'};
      expect(parts('Stein', letters, <String>{}, current: 'ei'), 1); // st unbekannt
      // Mit bekanntem „st" wird Stein voll lesbar.
      expect(parts('Stein', letters, {'st'}, current: 'ei'), 0);
    });

    test('Ei ist beim ei-Lernen sofort voll lesbar', () {
      expect(parts('Ei', <String>{}, <String>{}, current: 'ei'), 0);
    });

    test('Stern beim st-Lernen: braucht nur e,r,n als Buchstaben', () {
      expect(parts('Stern', {'e', 'r', 'n'}, <String>{}, current: 'st'), 0);
      expect(parts('Stern', {'e', 'r'}, <String>{}, current: 'st'), 1); // n fehlt
    });

    test('Längster-Treffer: sch wird als Einheit erkannt (nicht s+ch)', () {
      // „Fisch" = f·i·sch: beim sch-Lernen nur f,i als Buchstaben nötig.
      expect(parts('Fisch', {'f', 'i'}, <String>{}, current: 'sch'), 0);
    });
  });
}
