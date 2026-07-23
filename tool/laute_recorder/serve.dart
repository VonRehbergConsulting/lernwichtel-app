// Lokaler Aufnahme-Server fuer die Anlaut-Audios.
//
// Zeigt im Browser (Mac via localhost, iPhone via LAN) pro Laut den Buchstaben,
// den Sprech-Hinweis und ein Beispielwort. Start -> sprechen -> Stopp -> Speichern
// schreibt die Aufnahme direkt als `assets/audio/laute/<key>.wav`.
//
// Start:
//   fvm dart run tool/laute_recorder/serve.dart          # Port 8443
//   fvm dart run tool/laute_recorder/serve.dart 9000     # eigener Port
//
// Warum HTTPS: Mikrofonzugriff im Browser braucht einen "secure context".
// localhost gilt automatisch als sicher, eine LAN-IP (iPhone) nicht - daher
// ein selbstsigniertes Zertifikat. Beim ersten Aufruf am iPhone einmal
// "trotzdem fortfahren" antippen.

import 'dart:convert';
import 'dart:io';

late final Directory _scriptDir;
late final Directory _repoRoot;
late final Directory _assetsDir;
late final File _htmlFile;
late final Set<String> _allowedKeys;

Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.tryParse(args.first) ?? 8443 : 8443;

  _scriptDir = File.fromUri(Platform.script).parent;
  _repoRoot = _scriptDir.parent.parent; // tool/laute_recorder -> repo root
  _assetsDir = Directory('${_repoRoot.path}/assets/audio/laute');
  _htmlFile = File('${_scriptDir.path}/index.html');

  final jsonFile = File('${_repoRoot.path}/assets/content/lerninhalte.json');
  if (!jsonFile.existsSync()) {
    stderr.writeln('Fehlt: ${jsonFile.path}');
    exit(1);
  }
  if (!_assetsDir.existsSync()) {
    _assetsDir.createSync(recursive: true);
  }

  final content = _buildGraphemes(
    jsonDecode(jsonFile.readAsStringSync()) as Map<String, dynamic>,
  );
  _allowedKeys = {
    for (final g in content) g['key'] as String,
  };

  final lanIp = await _lanIp();
  final ctx = await _securityContext(lanIp);

  final server = await HttpServer.bindSecure(
    InternetAddress.anyIPv4,
    port,
    ctx,
  );

  stdout
    ..writeln()
    ..writeln('  Lernwichtel Laute-Recorder laeuft.')
    ..writeln()
    ..writeln('    Am Mac:     https://localhost:$port')
    ..writeln('    Am iPhone:  https://${lanIp ?? '<mac-ip>'}:$port'
        '   (gleiches WLAN, Zertifikatswarnung bestaetigen)')
    ..writeln()
    ..writeln('  Ziel-Ordner: ${_assetsDir.path}')
    ..writeln('  Stoppen mit Strg+C.')
    ..writeln();

  await for (final req in server) {
    try {
      await _handle(req, content);
    } catch (e) {
      stderr.writeln('Fehler: $e');
      _tryClose(req.response, HttpStatus.internalServerError, 'error');
    }
  }
}

Future<void> _handle(HttpRequest req, List<Map<String, dynamic>> content) async {
  final path = req.uri.path;

  if (req.method == 'GET' && (path == '/' || path == '/index.html')) {
    req.response.headers.contentType = ContentType.html;
    req.response.add(_htmlFile.readAsBytesSync());
    await req.response.close();
    return;
  }

  if (req.method == 'GET' && path == '/graphemes.json') {
    final withStatus = [
      for (final g in content) {...g, 'recorded': _isRecorded(g['key'] as String)},
    ];
    _json(req.response, {'items': withStatus});
    return;
  }

  // Vorhandene Aufnahme abspielen: GET /laute/<key>.wav
  if (req.method == 'GET' && path.startsWith('/laute/')) {
    final key = Uri.decodeComponent(path.substring('/laute/'.length));
    final clean = key.endsWith('.wav') ? key.substring(0, key.length - 4) : key;
    if (!_allowedKeys.contains(clean)) {
      _tryClose(req.response, HttpStatus.notFound, 'unknown key');
      return;
    }
    final f = File('${_assetsDir.path}/$clean.wav');
    if (!f.existsSync()) {
      _tryClose(req.response, HttpStatus.notFound, 'no recording');
      return;
    }
    req.response.headers.contentType = ContentType('audio', 'wav');
    req.response.headers.set('Cache-Control', 'no-store');
    req.response.add(f.readAsBytesSync());
    await req.response.close();
    return;
  }

  // Aufnahme speichern: POST /save?key=<key>  (Body = WAV-Bytes)
  if (req.method == 'POST' && path == '/save') {
    final key = req.uri.queryParameters['key'];
    if (key == null || !_allowedKeys.contains(key)) {
      _tryClose(req.response, HttpStatus.badRequest, 'unknown key');
      return;
    }
    final bytes = await _readBody(req);
    if (!_looksLikeWav(bytes)) {
      _tryClose(req.response, HttpStatus.badRequest, 'not a wav');
      return;
    }
    final target = File('${_assetsDir.path}/$key.wav');
    target.writeAsBytesSync(bytes, flush: true);
    stdout.writeln('  gespeichert: $key.wav  (${bytes.length} bytes)');
    _json(req.response, {'ok': true, 'key': key, 'bytes': bytes.length});
    return;
  }

  _tryClose(req.response, HttpStatus.notFound, 'not found');
}

// ---- Inhalte aus lerninhalte.json ----------------------------------------

List<Map<String, dynamic>> _buildGraphemes(Map<String, dynamic> data) {
  final result = <Map<String, dynamic>>[];

  final buchstaben = (data['buchstaben'] as List).cast<Map<String, dynamic>>();
  final sortedB = [...buchstaben]..sort((a, b) =>
      (a['reihenfolge'] as num).compareTo(b['reihenfolge'] as num));
  for (final b in sortedB) {
    result.add(_entry(b, 'Buchstaben'));
  }

  final lv = (data['lautverbindungen'] as List).cast<Map<String, dynamic>>();
  for (final v in lv) {
    result.add(_entry(v, 'Lautverbindungen'));
  }

  return result;
}

Map<String, dynamic> _entry(Map<String, dynamic> src, String group) {
  final beispiele = (src['beispiele'] as List?)?.cast<String>() ?? const [];
  return {
    'key': src['grapheme'] as String,
    'laut': (src['laut'] as String?) ?? (src['grapheme'] as String),
    'beispiel': beispiele.isNotEmpty ? beispiele.first : '',
    'group': group,
  };
}

bool _isRecorded(String key) {
  final f = File('${_assetsDir.path}/$key.wav');
  return f.existsSync() && f.lengthSync() > 44; // > WAV-Header
}

// ---- HTTP-Helfer ----------------------------------------------------------

Future<List<int>> _readBody(HttpRequest req) async {
  final chunks = <int>[];
  await for (final chunk in req) {
    chunks.addAll(chunk);
  }
  return chunks;
}

bool _looksLikeWav(List<int> b) {
  if (b.length < 12) return false;
  final riff = String.fromCharCodes(b.sublist(0, 4));
  final wave = String.fromCharCodes(b.sublist(8, 12));
  return riff == 'RIFF' && wave == 'WAVE';
}

void _json(HttpResponse res, Object data) {
  res.headers.contentType = ContentType.json;
  res.write(jsonEncode(data));
  res.close();
}

void _tryClose(HttpResponse res, int status, String msg) {
  try {
    res.statusCode = status;
    res.write(msg);
    res.close();
  } catch (_) {/* Verbindung evtl. schon zu */}
}

// ---- Netzwerk & TLS -------------------------------------------------------

Future<String?> _lanIp() async {
  final interfaces =
      await NetworkInterface.list(type: InternetAddressType.IPv4);
  for (final iface in interfaces) {
    for (final addr in iface.addresses) {
      if (!addr.isLoopback && !addr.address.startsWith('169.254')) {
        return addr.address;
      }
    }
  }
  return null;
}

/// Selbstsigniertes Zertifikat unter tool/laute_recorder/.certs erzeugen
/// (nur einmal bzw. wenn sich die LAN-IP geaendert hat).
Future<SecurityContext> _securityContext(String? lanIp) async {
  final certDir = Directory('${_scriptDir.path}/.certs');
  if (!certDir.existsSync()) certDir.createSync();
  final cert = File('${certDir.path}/cert.pem');
  final key = File('${certDir.path}/key.pem');
  final hostFile = File('${certDir.path}/host.txt');

  final wantHost = lanIp ?? '127.0.0.1';
  final haveHost = hostFile.existsSync() ? hostFile.readAsStringSync().trim() : '';
  final needNew = !cert.existsSync() || !key.existsSync() || haveHost != wantHost;

  if (needNew) {
    final san = 'subjectAltName=DNS:localhost,IP:127.0.0.1'
        '${lanIp != null ? ',IP:$lanIp' : ''}';
    final res = await Process.run('openssl', [
      'req', '-x509', '-newkey', 'rsa:2048', '-sha256', '-days', '3650',
      '-nodes',
      '-keyout', key.path,
      '-out', cert.path,
      '-subj', '/CN=lernwichtel-recorder',
      '-addext', san,
    ]);
    if (res.exitCode != 0) {
      stderr.writeln('openssl fehlgeschlagen:\n${res.stderr}');
      exit(1);
    }
    hostFile.writeAsStringSync(wantHost);
    stdout.writeln('  Neues Zertifikat erzeugt (SAN: $san).');
  }

  return SecurityContext()
    ..useCertificateChain(cert.path)
    ..usePrivateKey(key.path);
}
