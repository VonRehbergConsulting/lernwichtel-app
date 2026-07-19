/// Die eindeutigen Buchstaben eines Namens (kleingeschrieben), ohne
/// Nicht-Buchstaben (Leerzeichen, Bindestriche …). Grundlage für „Mein Name":
/// welche Buchstaben muss das Kind können, um seinen Namen zu lesen/schreiben.
Set<String> nameLetters(String name) {
  final out = <String>{};
  for (final ch in name.toLowerCase().split('')) {
    if (RegExp(r'[a-zäöüß]').hasMatch(ch)) out.add(ch);
  }
  return out;
}
