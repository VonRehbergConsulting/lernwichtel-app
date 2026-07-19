import '../../core/audio/audio_service.dart';
import '../../data/repositories/content_repository.dart';

/// Spielt den Anlaut eines einzelnen Buchstabens. Kapselt die Zuordnung
/// Symbol → graphemeKey (einmalig geladen, dann gecacht), damit Bau- und
/// Namens-Flächen nicht jeweils dieselbe Lade-Logik wiederholen.
class PhonicsPlayer {
  PhonicsPlayer(this._content, this._audio);

  final ContentRepository _content;
  final AudioService _audio;
  Map<String, String>? _keys;

  Future<void> _ensure() async {
    if (_keys != null) return;
    final graphemes = await _content.graphemesByKind('buchstabe');
    _keys = {for (final g in graphemes) g.symbol.toLowerCase(): g.graphemeKey};
  }

  /// Spielt den Anlaut zu [char] (lädt die Zuordnung beim ersten Aufruf).
  Future<void> playChar(String char) async {
    await _ensure();
    final lower = char.toLowerCase();
    await _audio.playGrapheme(key: _keys![lower] ?? lower, fallbackText: char);
  }
}
