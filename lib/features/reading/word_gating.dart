/// Ob ein Wort schon „spielbar" ist: alle seine Buchstaben wurden bereits in
/// einer Eltern-Lektion eingeführt (klein geschrieben in [known]). Basis fürs
/// Gating von Selbstlernen und Wörter-Bauen auf bereits Gelerntes.
bool wordUsesOnlyKnown(String word, Set<String> known) =>
    word.toLowerCase().split('').every(known.contains);

/// Zerlegt [word] in Bausteine (Silben vor Einzelbuchstaben, Längster-Treffer
/// gegen [comboVocab] – der Vokabel *aller* Silben, längenabsteigend sortiert)
/// und zählt, wie viele Bausteine dem Kind noch unbekannt sind. 0 = voll lesbar.
///
/// Bekannt sind eingeführte Einzelbuchstaben [knownLetters], eingeführte Silben
/// [knownCombos] sowie – optional – die gerade gelernte Silbe [current].
/// So braucht z. B. „Stein" (st·ei·n) sowohl „st" als auch „ei".
int unknownGraphemeParts(
  String word, {
  required Set<String> knownLetters,
  required Set<String> knownCombos,
  required List<String> comboVocab,
  String? current,
}) {
  final w = word.toLowerCase();
  final cur = current?.toLowerCase();
  var unknown = 0;
  var i = 0;
  while (i < w.length) {
    String? syl;
    for (final c in comboVocab) {
      if (c.length > 1 && w.startsWith(c, i)) {
        syl = c;
        break;
      }
    }
    if (syl != null) {
      if (syl != cur && !knownCombos.contains(syl)) unknown++;
      i += syl.length;
    } else {
      if (!knownLetters.contains(w[i])) unknown++;
      i += 1;
    }
  }
  return unknown;
}
