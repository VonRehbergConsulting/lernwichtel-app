/// Erzeugt aus einem deutschen Wort einen stabilen, dateisicheren Slug.
///
/// WICHTIG: Diese Logik muss identisch mit der im Generator-Skript
/// (tool/generate_standard_images.dart) sein, damit App und Skript denselben
/// Dateinamen fuer das Standardbild verwenden.
String wortSlug(String wort) {
  var s = wort.toLowerCase().trim();
  const umlaute = {
    'ä': 'ae',
    'ö': 'oe',
    'ü': 'ue',
    'ß': 'ss',
  };
  umlaute.forEach((k, v) => s = s.replaceAll(k, v));
  s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  s = s.replaceAll(RegExp(r'^_+|_+$'), '');
  return s;
}
