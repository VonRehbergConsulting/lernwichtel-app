import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/audio/audio_service.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/repositories/progression_repository.dart';
import '../../../data/repositories/reading_repository.dart';
import '../batch_pool.dart';
import '../reading_config.dart';
import '../word_gating.dart';

// ----------------------------- Events -----------------------------

sealed class CombinationsEvent extends Equatable {
  const CombinationsEvent();
  @override
  List<Object?> get props => const [];
}

class CombinationsStarted extends CombinationsEvent {
  const CombinationsStarted(this.childId);
  final int childId;
  @override
  List<Object?> get props => [childId];
}

/// Die Lautverbindung wurde angetippt -> isolierten Laut abspielen.
class ComboSoundRequested extends CombinationsEvent {
  const ComboSoundRequested();
}

/// Beispielwort vorlesen.
class ExampleSpeakRequested extends CombinationsEvent {
  const ExampleSpeakRequested();
}

class NextExampleRequested extends CombinationsEvent {
  const NextExampleRequested();
}

class ImageToggled extends CombinationsEvent {
  const ImageToggled();
}

class NextComboRequested extends CombinationsEvent {
  const NextComboRequested();
}

class PreviousComboRequested extends CombinationsEvent {
  const PreviousComboRequested();
}

/// Neue Runde: frischer Verbindungs-Pool + neue Verbindungen freischalten.
class NewComboRoundRequested extends CombinationsEvent {
  const NewComboRoundRequested();
}

class ComboMastered extends CombinationsEvent {
  const ComboMastered();
}

// ----------------------------- State -----------------------------

enum CombinationsStatus { loading, ready, empty, error }

class CombinationsState extends Equatable {
  const CombinationsState({
    this.status = CombinationsStatus.loading,
    this.combos = const [],
    this.index = 0,
    this.examples = const [],
    this.exampleIndex = 0,
    this.imageRevealed = false,
    this.masteredKeys = const {},
  });

  final CombinationsStatus status;
  final List<Grapheme> combos;
  final int index;
  final List<WordWithImage> examples;
  final int exampleIndex;
  final bool imageRevealed;

  /// graphemeKeys der bereits sicheren Verbindungen.
  final Set<String> masteredKeys;

  Grapheme? get currentCombo => combos.isEmpty ? null : combos[index];
  WordWithImage? get currentExample =>
      examples.isEmpty ? null : examples[exampleIndex % examples.length];
  bool get hasNext => index < combos.length - 1;
  bool get hasPrevious => index > 0;
  bool get isMastered =>
      currentCombo != null && masteredKeys.contains(currentCombo!.graphemeKey);

  CombinationsState copyWith({
    CombinationsStatus? status,
    List<Grapheme>? combos,
    int? index,
    List<WordWithImage>? examples,
    int? exampleIndex,
    bool? imageRevealed,
    Set<String>? masteredKeys,
  }) {
    return CombinationsState(
      status: status ?? this.status,
      combos: combos ?? this.combos,
      index: index ?? this.index,
      examples: examples ?? this.examples,
      exampleIndex: exampleIndex ?? this.exampleIndex,
      imageRevealed: imageRevealed ?? this.imageRevealed,
      masteredKeys: masteredKeys ?? this.masteredKeys,
    );
  }

  @override
  List<Object?> get props => [
        status,
        combos,
        index,
        examples,
        exampleIndex,
        imageRevealed,
        masteredKeys,
      ];
}

// ----------------------------- Bloc -----------------------------

class CombinationsBloc extends Bloc<CombinationsEvent, CombinationsState> {
  CombinationsBloc({
    required ContentRepository content,
    required ReadingRepository reading,
    required ProgressionRepository progression,
    required AudioService audio,
  })  : _content = content,
        _reading = reading,
        _progressionRepo = progression,
        _audio = audio,
        super(const CombinationsState()) {
    on<CombinationsStarted>(_onStarted);
    on<ComboSoundRequested>(_onSound);
    on<ExampleSpeakRequested>(_onSpeak);
    on<NextExampleRequested>(_onNextExample);
    on<ImageToggled>(_onImageToggled);
    on<NextComboRequested>(_onNext);
    on<PreviousComboRequested>(_onPrevious);
    on<NewComboRoundRequested>(_onNewRound);
    on<ComboMastered>(_onMastered);
  }

  final ContentRepository _content;
  final ReadingRepository _reading;
  final ProgressionRepository _progressionRepo;
  final AudioService _audio;
  final _rnd = Random();

  int _childId = 0;

  /// Alle Verbindungen in Lern-Reihenfolge (Seed-Reihenfolge).
  List<Grapheme> _progression = const [];

  /// Kleingeschriebene Symbole der schon eingeführten Buchstaben – Basis fürs
  /// Auswählen lesbarer Beispielwörter (Fortschritt beachten).
  Set<String> _known = const {};

  /// Kleingeschriebene Symbole der schon eingeführten Silben (Fortschritt ≠
  /// „neu") – nötig, damit z. B. „Stein" erst zählt, wenn auch „st" sitzt.
  Set<String> _knownCombos = const {};

  /// Alle Silben-Symbole, nach Länge absteigend – für die Längster-Treffer-
  /// Zerlegung eines Wortes in Bausteine (Silben vor Einzelbuchstaben).
  List<String> _comboVocab = const [];

  Future<void> _onStarted(
    CombinationsStarted event,
    Emitter<CombinationsState> emit,
  ) async {
    _childId = event.childId;
    try {
      _progression = await _content.graphemesByKind('verbindung');
      if (_progression.isEmpty) {
        emit(state.copyWith(status: CombinationsStatus.empty));
        return;
      }

      final progress = await _reading.progressFor(_childId);
      final k = await _reading.readingKnowledge(_childId);
      _known = k.letters;
      _knownCombos = k.combos;
      _comboVocab = k.vocab;
      final mastered = <String>{};
      for (final g in _progression) {
        if (progress[g.id]?.status == 'sicher') mastered.add(g.graphemeKey);
      }

      final unlocked = await _progressionRepo.combosUnlocked(_childId);
      final pool = _buildPool(unlocked);
      final examples = await _loadExamples(pool.first);
      emit(state.copyWith(
        status: CombinationsStatus.ready,
        combos: pool,
        index: 0,
        examples: examples,
        exampleIndex: 0,
        imageRevealed: false,
        masteredKeys: mastered,
      ));
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: CombinationsStatus.error));
    }
  }

  /// Zufaelliger Verbindungs-Pool.
  List<Grapheme> _buildPool(int unlocked) => buildBatchPool(
        _progression,
        unlocked,
        maxPool: ReadingPool.combosMax,
        newestCount: ReadingPool.combosNewest,
        rnd: _rnd,
      );

  Future<void> _onNewRound(
    NewComboRoundRequested event,
    Emitter<CombinationsState> emit,
  ) async {
    final unlocked =
        await _progressionRepo.unlockMoreCombos(_childId, _progression.length);
    final pool = _buildPool(unlocked);
    final examples = await _loadExamples(pool.first);
    emit(state.copyWith(
      status: CombinationsStatus.ready,
      combos: pool,
      index: 0,
      examples: examples,
      exampleIndex: 0,
      imageRevealed: false,
    ));
  }

  Future<List<WordWithImage>> _loadExamples(Grapheme g) async {
    // Kuratierte Beispiele je Graphem-Key (ch-ach/ch-ich getrennt) – nicht per
    // Substring, sonst käme „ch" auch in sch-/chs-Wörtern (Schatz, Fuchs …).
    final words = await _content.exampleWords(g.graphemeKey);
    final examples = await _reading.wordsByText(words);
    return _rankExamples(examples, g.symbol);
  }

  /// Ordnet Beispielwörter nach Lesbarkeit. Ein Wort wird in Bausteine zerlegt
  /// (Silben vor Einzelbuchstaben, Längster-Treffer). Bekannt sind: eingeführte
  /// Buchstaben, eingeführte Silben und die gerade gelernte Silbe. Voll lesbare
  /// Wörter kommen zuerst (gemischt); sonst die mit den wenigsten unbekannten
  /// Bausteinen. So kommt „Ei" vor „Stein", solange „st" noch nicht sitzt.
  List<WordWithImage> _rankExamples(
    List<WordWithImage> examples,
    String comboSymbol,
  ) {
    int unknown(WordWithImage w) => unknownGraphemeParts(
          w.word.word,
          knownLetters: _known,
          knownCombos: _knownCombos,
          comboVocab: _comboVocab,
          current: comboSymbol,
        );

    final readable = examples.where((w) => unknown(w) == 0).toList()
      ..shuffle(_rnd);
    if (readable.isNotEmpty) return readable;

    return [...examples]..sort((a, b) => unknown(a).compareTo(unknown(b)));
  }

  Future<void> _onSound(
    ComboSoundRequested event,
    Emitter<CombinationsState> emit,
  ) async {
    final g = state.currentCombo;
    if (g == null) return;
    await _audio.playGrapheme(
      key: g.graphemeKey,
      fallbackText: g.symbol,
    );
  }

  Future<void> _onSpeak(
    ExampleSpeakRequested event,
    Emitter<CombinationsState> emit,
  ) async {
    final ex = state.currentExample;
    if (ex != null) await _audio.speak(ex.word.word);
  }

  void _onNextExample(
    NextExampleRequested event,
    Emitter<CombinationsState> emit,
  ) {
    if (state.examples.length < 2) return;
    emit(state.copyWith(
      exampleIndex: state.exampleIndex + 1,
      imageRevealed: false,
    ));
  }

  void _onImageToggled(ImageToggled event, Emitter<CombinationsState> emit) {
    emit(state.copyWith(imageRevealed: !state.imageRevealed));
  }

  Future<void> _onNext(
    NextComboRequested event,
    Emitter<CombinationsState> emit,
  ) async {
    if (!state.hasNext) return;
    final newIndex = state.index + 1;
    final examples = await _loadExamples(state.combos[newIndex]);
    emit(state.copyWith(
      index: newIndex,
      examples: examples,
      exampleIndex: 0,
      imageRevealed: false,
    ));
  }

  Future<void> _onPrevious(
    PreviousComboRequested event,
    Emitter<CombinationsState> emit,
  ) async {
    if (!state.hasPrevious) return;
    final newIndex = state.index - 1;
    final examples = await _loadExamples(state.combos[newIndex]);
    emit(state.copyWith(
      index: newIndex,
      examples: examples,
      exampleIndex: 0,
      imageRevealed: false,
    ));
  }

  Future<void> _onMastered(
    ComboMastered event,
    Emitter<CombinationsState> emit,
  ) async {
    final g = state.currentCombo;
    if (g == null) return;
    await _reading.setMastered(
      childId: _childId,
      graphemeId: g.id,
      mastered: true,
    );
    emit(state.copyWith(
      masteredKeys: {...state.masteredKeys, g.graphemeKey},
    ));
  }
}
