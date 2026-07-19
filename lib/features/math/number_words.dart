const _zahlwoerter = [
  'null',
  'eins',
  'zwei',
  'drei',
  'vier',
  'fünf',
  'sechs',
  'sieben',
  'acht',
  'neun',
  'zehn',
  'elf',
  'zwölf',
];

/// Deutsches Zahlwort zu einer Zahl (fürs Vorlesen/Anzeigen). Außerhalb des
/// bekannten Bereichs die Ziffernschreibweise als Rückfall.
String zahlwort(int n) =>
    (n >= 0 && n < _zahlwoerter.length) ? _zahlwoerter[n] : '$n';
