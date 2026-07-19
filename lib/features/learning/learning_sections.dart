import '../../data/repositories/gate_repository.dart';

/// Die beiden Lern-Spuren.
enum LearningTrack { lesen, rechnen }

/// Ein einzelner Lern-Bereich (Menue-Kachel), inkl. Freischalt-Info.
class LearningSection {
  const LearningSection({
    required this.key,
    required this.track,
    required this.label,
    required this.lockedHint,
  });

  /// Entspricht der Menue-Icon-ID und dem `sectionKey` im [GateRepository].
  final String key;
  final LearningTrack track;
  final String label;

  /// Kindgerechter Hinweis, wenn der Bereich noch gesperrt ist.
  final String lockedHint;

  bool get isBase => GateRepository.baseSections.contains(key);
}

/// Reihenfolge der Bereiche je Spur (Basis zuerst).
const kLearningSections = <LearningSection>[
  LearningSection(
    key: 'lese_buchstaben',
    track: LearningTrack.lesen,
    label: 'Buchstaben',
    lockedHint: '',
  ),
  LearningSection(
    key: 'lese_verbindungen',
    track: LearningTrack.lesen,
    label: 'Lautverbindungen',
    lockedHint: 'Übe zuerst die Buchstaben, dann geht das hier auf.',
  ),
  LearningSection(
    key: 'lese_saetze',
    track: LearningTrack.lesen,
    label: 'Sätze',
    lockedHint: 'Übe zuerst die Lautverbindungen, dann geht das hier auf.',
  ),
  LearningSection(
    key: 'math_ziffern',
    track: LearningTrack.rechnen,
    label: 'Ziffern',
    lockedHint: '',
  ),
  LearningSection(
    key: 'math_zehner',
    track: LearningTrack.rechnen,
    label: 'Zahlen bis 100',
    lockedHint: 'Übe zuerst die Ziffern, dann geht das hier auf.',
  ),
  LearningSection(
    key: 'math_addieren',
    track: LearningTrack.rechnen,
    label: 'Plus',
    lockedHint: 'Übe zuerst die Zahlen bis 100, dann geht das hier auf.',
  ),
  LearningSection(
    key: 'math_subtrahieren',
    track: LearningTrack.rechnen,
    label: 'Minus',
    lockedHint: 'Übe zuerst das Plusrechnen, dann geht das hier auf.',
  ),
];

/// Nicht-Basis-Bereiche einer Spur (die, die man freischalten kann).
Iterable<LearningSection> unlockableSections(LearningTrack track) =>
    kLearningSections.where((s) => s.track == track && !s.isBase);

final Map<String, LearningSection> _sectionsByKey = {
  for (final s in kLearningSections) s.key: s,
};

/// Kindgerechter Sperr-Hinweis zu einem Bereich (einzige Quelle der Wahrheit).
String lockedHintFor(String key) => _sectionsByKey[key]?.lockedHint ?? '';

/// Startniveau beim Anlegen eines Kindes.
enum StartLevel { anfaenger, etwas, geuebt }

extension StartLevelX on StartLevel {
  String get label => switch (this) {
        StartLevel.anfaenger => 'Fängt bei Null an',
        StartLevel.etwas => 'Kann schon etwas',
        StartLevel.geuebt => 'Schon geübt',
      };

  String get description => switch (this) {
        StartLevel.anfaenger =>
          'Nur Buchstaben und Ziffern sind offen. Alles Weitere schaltet '
              'sich frei, sobald die Grundlagen sitzen.',
        StartLevel.etwas =>
          'Kennt schon einige Buchstaben und Zahlen: Lautverbindungen und '
              'Zahlen bis 100 sind zusätzlich offen.',
        StartLevel.geuebt =>
          'Liest und rechnet bereits etwas: alle Bereiche sind von Anfang '
              'an offen.',
      };

  String get emoji => switch (this) {
        StartLevel.anfaenger => '🌱',
        StartLevel.etwas => '🌿',
        StartLevel.geuebt => '🌳',
      };

  /// Menue-Icon-ID (generiertes Bild via Pipeline, Emoji nur als Fallback).
  String get iconId => switch (this) {
        StartLevel.anfaenger => 'start_anfaenger',
        StartLevel.etwas => 'start_etwas',
        StartLevel.geuebt => 'start_geuebt',
      };

  /// Manuell freizuschaltende Bereiche fuer dieses Startniveau.
  Set<String> get unlocks => switch (this) {
        StartLevel.anfaenger => const {},
        StartLevel.etwas => const {'lese_verbindungen', 'math_zehner'},
        StartLevel.geuebt => const {
            'lese_verbindungen',
            'lese_saetze',
            'math_zehner',
            'math_addieren',
            'math_subtrahieren',
          },
      };
}
