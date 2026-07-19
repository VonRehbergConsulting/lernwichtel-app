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

sealed class ReadingEvent extends Equatable {
  const ReadingEvent();
  @override
  List<Object?> get props => const [];
}

class ReadingStarted extends ReadingEvent {
  const ReadingStarted(this.childId);
  final int childId;
  @override
  List<Object?> get props => [childId];
}

/// Ein einzelner Buchstabe im Wort wurde angetippt -> Laut abspielen.
class LetterTapped extends ReadingEvent {
  const LetterTapped(this.letter);
  final String letter;
  @override
  List<Object?> get props => [letter];
}

/// Ganzes Wort vorlesen lassen.
class WordSpeakRequested extends ReadingEvent {
  const WordSpeakRequested();
}

/// Bild ein-/ausblenden (bewusst erst auf Wunsch).
class ImageToggled extends ReadingEvent {
  const ImageToggled();
}

class NextWordRequested extends ReadingEvent {
  const NextWordRequested();
}

class PreviousWordRequested extends ReadingEvent {
  const PreviousWordRequested();
}

/// Neue Runde: mischt einen frischen Wort-Pool und schaltet neue Woerter frei.
class NewRoundRequested extends ReadingEvent {
  const NewRoundRequested();
}

/// Buchstabe als "beherrscht" markieren (langer Druck durch Begleitperson).
class LetterMastered extends ReadingEvent {
  const LetterMastered(this.letter);
  final String letter;
  @override
  List<Object?> get props => [letter];
}

// ----------------------------- State -----------------------------

enum ReadingStatus { loading, ready, empty, error }

class ReadingState extends Equatable {
  const ReadingState({
    this.status = ReadingStatus.loading,
    this.words = const [],
    this.index = 0,
    this.imageRevealed = false,
    this.masteredSymbols = const {},
  });

  final ReadingStatus status;
  final List<WordWithImage> words;
  final int index;
  final bool imageRevealed;

  /// Kleingeschriebene Symbole der bereits sicheren Buchstaben (fuer Haekchen).
  final Set<String> masteredSymbols;

  WordWithImage? get currentWord =>
      words.isEmpty ? null : words[index];

  bool get hasNext => index < words.length - 1;
  bool get hasPrevious => index > 0;

  ReadingState copyWith({
    ReadingStatus? status,
    List<WordWithImage>? words,
    int? index,
    bool? imageRevealed,
    Set<String>? masteredSymbols,
  }) {
    return ReadingState(
      status: status ?? this.status,
      words: words ?? this.words,
      index: index ?? this.index,
      imageRevealed: imageRevealed ?? this.imageRevealed,
      masteredSymbols: masteredSymbols ?? this.masteredSymbols,
    );
  }

  @override
  List<Object?> get props =>
      [status, words, index, imageRevealed, masteredSymbols];
}

// ----------------------------- Bloc -----------------------------

class ReadingBloc extends Bloc<ReadingEvent, ReadingState> {
  ReadingBloc({
    required ContentRepository content,
    required ReadingRepository reading,
    required ProgressionRepository progression,
    required AudioService audio,
  })  : _content = content,
        _reading = reading,
        _progressionRepo = progression,
        _audio = audio,
        super(const ReadingState()) {
    on<ReadingStarted>(_onStarted);
    on<LetterTapped>(_onLetterTapped);
    on<WordSpeakRequested>(_onSpeak);
    on<ImageToggled>(_onImageToggled);
    on<NextWordRequested>(_onNext);
    on<PreviousWordRequested>(_onPrevious);
    on<NewRoundRequested>(_onNewRound);
    on<LetterMastered>(_onLetterMastered);
  }

  final ContentRepository _content;
  final ReadingRepository _reading;
  final ProgressionRepository _progressionRepo;
  final AudioService _audio;
  final _rnd = Random();

  int _childId = 0;

  /// Nur Wörter, deren Buchstaben alle schon eingeführt sind (Selbstlernen
  /// läuft dem Lektions-Fortschritt so nicht voraus).
  List<Word> _playableWords = const [];

  /// Buchstaben-Grapheme, nach kleingeschriebenem Symbol.
  final Map<String, Grapheme> _bySymbol = {};

  Future<void> _onStarted(
    ReadingStarted event,
    Emitter<ReadingState> emit,
  ) async {
    _childId = event.childId;
    try {
      final graphemes = await _content.graphemesByKind('buchstabe');
      _bySymbol
        ..clear()
        ..addEntries(graphemes.map((g) => MapEntry(g.symbol.toLowerCase(), g)));

      final progression = await _progressionRepo.wordProgression();
      final progress = await _reading.progressFor(_childId);

      // Schon sichere Buchstaben (für die Häkchen an den Kacheln).
      final mastered = <String>{};
      for (final g in graphemes) {
        if (progress[g.id]?.status == 'sicher') {
          mastered.add(g.symbol.toLowerCase());
        }
      }

      // Nur Wörter, die sich vollständig in bekannte Bausteine zerlegen lassen
      // (eingeführte Buchstaben UND Silben) – „Stein" braucht so z. B. „st".
      final k = await _reading.readingKnowledge(_childId);
      _playableWords = progression
          .where((w) => unknownGraphemeParts(
                w.word,
                knownLetters: k.letters,
                knownCombos: k.combos,
                comboVocab: k.vocab,
              ) ==
              0)
          .toList();

      final unlocked = await _progressionRepo.wordsUnlocked(_childId);
      final pool = await _buildPool(unlocked);

      emit(state.copyWith(
        status: pool.isEmpty ? ReadingStatus.empty : ReadingStatus.ready,
        words: pool,
        index: 0,
        imageRevealed: false,
        masteredSymbols: mastered,
      ));
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: ReadingStatus.error));
    }
  }

  /// Zufaelliger Uebungs-Pool aus den spielbaren Woertern (nur eingeführte
  /// Buchstaben), angereichert mit eventuell hinterlegten eigenen Fotos.
  Future<List<WordWithImage>> _buildPool(int unlocked) async {
    final words = buildBatchPool(
      _playableWords,
      unlocked,
      maxPool: ReadingPool.wordsMax,
      newestCount: ReadingPool.wordsNewest,
      rnd: _rnd,
    );
    final paths =
        await _reading.imagePathsForWords(words.map((w) => w.id).toList());
    return words
        .map((w) => WordWithImage(word: w, imagePath: paths[w.id]))
        .toList();
  }

  Future<void> _onNewRound(
    NewRoundRequested event,
    Emitter<ReadingState> emit,
  ) async {
    final unlocked =
        await _progressionRepo.unlockMore(_childId, _playableWords.length);
    final pool = await _buildPool(unlocked);
    emit(state.copyWith(
      status: pool.isEmpty ? ReadingStatus.empty : ReadingStatus.ready,
      words: pool,
      index: 0,
      imageRevealed: false,
    ));
  }

  Future<void> _onLetterTapped(
    LetterTapped event,
    Emitter<ReadingState> emit,
  ) async {
    final g = _bySymbol[event.letter.toLowerCase()];
    await _audio.playGrapheme(
      key: g?.graphemeKey ?? event.letter.toLowerCase(),
      fallbackText: event.letter,
    );
  }

  Future<void> _onSpeak(
    WordSpeakRequested event,
    Emitter<ReadingState> emit,
  ) async {
    final word = state.currentWord;
    if (word != null) await _audio.speak(word.word.word);
  }

  void _onImageToggled(ImageToggled event, Emitter<ReadingState> emit) {
    emit(state.copyWith(imageRevealed: !state.imageRevealed));
  }

  void _onNext(NextWordRequested event, Emitter<ReadingState> emit) {
    if (!state.hasNext) return;
    emit(state.copyWith(index: state.index + 1, imageRevealed: false));
  }

  void _onPrevious(PreviousWordRequested event, Emitter<ReadingState> emit) {
    if (!state.hasPrevious) return;
    emit(state.copyWith(index: state.index - 1, imageRevealed: false));
  }

  Future<void> _onLetterMastered(
    LetterMastered event,
    Emitter<ReadingState> emit,
  ) async {
    final g = _bySymbol[event.letter.toLowerCase()];
    if (g == null) return;
    await _reading.setMastered(
      childId: _childId,
      graphemeId: g.id,
      mastered: true,
    );
    await _audio.playGrapheme(
      key: g.graphemeKey,
      fallbackText: event.letter,
    );
    emit(state.copyWith(
      masteredSymbols: {...state.masteredSymbols, g.symbol.toLowerCase()},
    ));
  }
}
