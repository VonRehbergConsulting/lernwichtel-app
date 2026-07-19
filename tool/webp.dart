import 'dart:io';

/// Schreibt PNG-Bytes als optimiertes WebP über das `cwebp`-CLI (libwebp).
///
/// WebP spart bei den flachen Comic-Bildern ~90 % gegenüber PNG bei visuell
/// verlustfreier Qualität. [resize] > 0 skaliert das Bild quadratisch herunter
/// (z. B. Menü-Icons). Wirft, wenn `cwebp` fehlt oder scheitert.
///
/// Installation, falls nicht vorhanden:  brew install webp
Future<void> writePngAsWebp(
  List<int> pngBytes,
  String outWebpPath, {
  int quality = 90,
  int? resize,
}) async {
  final tmp = File('${Directory.systemTemp.path}/'
      'gen_${DateTime.now().microsecondsSinceEpoch}_${outWebpPath.hashCode}.png');
  await tmp.writeAsBytes(pngBytes);
  try {
    final args = <String>['-quiet', '-q', '$quality'];
    if (resize != null && resize > 0) {
      args.addAll(['-resize', '$resize', '$resize']);
    }
    args.addAll([tmp.path, '-o', outWebpPath]);
    final res = await Process.run('cwebp', args);
    if (res.exitCode != 0) {
      throw 'cwebp fehlgeschlagen (Exit ${res.exitCode}). Ist libwebp '
          'installiert? (brew install webp)\n${res.stderr}';
    }
  } finally {
    if (await tmp.exists()) await tmp.delete();
  }
}
