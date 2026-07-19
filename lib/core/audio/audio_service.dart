import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Spielt Laute und liest Woerter/Saetze vor.
///
/// Fuer einen einzelnen Laut gilt die Reihenfolge:
/// 1. eigene Aufnahme im App-Ordner (`laute/<key>.m4a`) – falls vorhanden,
/// 2. generierter Laut als gebuendeltes Asset (`assets/audio/laute/<key>.wav`),
/// 3. Sprachsynthese (TTS) als Fallback.
///
/// So klingt der reine Laut (nicht der Buchstabenname), und einzelne Laute
/// lassen sich spaeter durch eine eigene Aufnahme ersetzen.
class AudioService {
  AudioService() {
    _tts
      ..setLanguage('de-DE')
      ..setSpeechRate(0.4)
      ..setPitch(1.0);
  }

  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  final Map<String, bool> _assetExists = {};

  /// Spielt den Laut zu einem Graphem-Schluessel (z. B. "m", "sch", "ae").
  Future<void> playGrapheme({
    required String key,
    required String fallbackText,
  }) async {
    final rec = await _recordedFile(key);
    if (rec != null && rec.existsSync()) {
      await _stopAll();
      await _player.play(DeviceFileSource(rec.path));
      return;
    }

    final rel = 'audio/laute/$key.wav';
    if (await _hasAsset('assets/$rel')) {
      await _stopAll();
      await _player.play(AssetSource(rel));
      return;
    }

    await _speak(fallbackText);
  }

  /// Liest ein ganzes Wort / einen Satz vor (immer via TTS).
  Future<void> speak(String text) => _speak(text);

  /// Datei einer eventuellen eigenen Aufnahme (`App-Dokumente/laute/<key>.m4a`).
  Future<File?> _recordedFile(String key) async {
    try {
      final docs = await getApplicationDocumentsDirectory();
      return File(p.join(docs.path, 'laute', '$key.m4a'));
    } catch (_) {
      return null;
    }
  }

  Future<void> _speak(String text) async {
    await _stopAll();
    await _tts.speak(text);
  }

  Future<void> _stopAll() async {
    await _player.stop();
    await _tts.stop();
  }

  Future<bool> _hasAsset(String path) async {
    final cached = _assetExists[path];
    if (cached != null) return cached;
    var exists = false;
    try {
      await rootBundle.load(path);
      exists = true;
    } catch (_) {
      exists = false;
    }
    _assetExists[path] = exists;
    return exists;
  }

  Future<void> stop() => _stopAll();

  void dispose() {
    _player.dispose();
    _tts.stop();
  }
}
