import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/audio/audio_service.dart';
import '../../../data/repositories/content_repository.dart';

// ----------------------------- Events -----------------------------

sealed class SilbenEvent extends Equatable {
  const SilbenEvent();
  @override
  List<Object?> get props => const [];
}

class SilbenStarted extends SilbenEvent {
  const SilbenStarted();
}

/// Ganzes Wort vorlesen.
class SilbenSpeakWord extends SilbenEvent {
  const SilbenSpeakWord();
}

/// Eine einzelne Silbe vorsprechen (beim Klatschen).
class SilbenSpeakSyllable extends SilbenEvent {
  const SilbenSpeakSyllable(this.syllable);
  final String syllable;
  @override
  List<Object?> get props => [syllable];
}

class NextSyllableWordRequested extends SilbenEvent {
  const NextSyllableWordRequested();
}

class PreviousSyllableWordRequested extends SilbenEvent {
  const PreviousSyllableWordRequested();
}

/// Noch ein paar Wörter freischalten (Batch-Lernen).
class MoreSyllableWordsRequested extends SilbenEvent {
  const MoreSyllableWordsRequested();
}

// ----------------------------- State -----------------------------

enum SilbenStatus { loading, ready, empty, error }

class SilbenState extends Equatable {
  const SilbenState({
    this.status = SilbenStatus.loading,
    this.words = const [],
    this.index = 0,
    this.revealed = 0,
  });

  final SilbenStatus status;
  final List<SyllableWord> words;
  final int index;

  /// Wie viele Wörter aktuell im Batch verfügbar sind (wächst auf Wunsch).
  final int revealed;

  SyllableWord? get current => words.isEmpty ? null : words[index];
  bool get hasNext => index < revealed - 1;
  bool get hasPrevious => index > 0;
  bool get canRevealMore => revealed < words.length;

  SilbenState copyWith({
    SilbenStatus? status,
    List<SyllableWord>? words,
    int? index,
    int? revealed,
  }) {
    return SilbenState(
      status: status ?? this.status,
      words: words ?? this.words,
      index: index ?? this.index,
      revealed: revealed ?? this.revealed,
    );
  }

  @override
  List<Object?> get props => [status, words, index, revealed];
}

// ----------------------------- Bloc -----------------------------

class SilbenBloc extends Bloc<SilbenEvent, SilbenState> {
  SilbenBloc({
    required ContentRepository content,
    required AudioService audio,
  })  : _content = content,
        _audio = audio,
        super(const SilbenState()) {
    on<SilbenStarted>(_onStarted);
    on<SilbenSpeakWord>(_onSpeakWord);
    on<SilbenSpeakSyllable>(_onSpeakSyllable);
    on<NextSyllableWordRequested>(_onNext);
    on<PreviousSyllableWordRequested>(_onPrevious);
    on<MoreSyllableWordsRequested>(_onMore);
  }

  final ContentRepository _content;
  final AudioService _audio;

  // Batch-Lernen: erst ein paar Wörter, dann auf Wunsch mehr.
  static const _batchStart = 6;
  static const _batchStep = 6;

  Future<void> _onStarted(
    SilbenStarted event,
    Emitter<SilbenState> emit,
  ) async {
    try {
      final words = await _content.loadSyllableWords();
      emit(state.copyWith(
        status: words.isEmpty ? SilbenStatus.empty : SilbenStatus.ready,
        words: words,
        index: 0,
        revealed: words.length < _batchStart ? words.length : _batchStart,
      ));
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: SilbenStatus.error));
    }
  }

  void _onMore(MoreSyllableWordsRequested event, Emitter<SilbenState> emit) {
    if (!state.canRevealMore) return;
    final firstNew = state.revealed;
    final next = state.revealed + _batchStep;
    emit(state.copyWith(
      revealed: next > state.words.length ? state.words.length : next,
      index: firstNew,
    ));
  }

  Future<void> _onSpeakWord(
    SilbenSpeakWord event,
    Emitter<SilbenState> emit,
  ) async {
    final w = state.current;
    if (w != null) await _audio.speak(w.word);
  }

  // TODO(phonologische-bewusstheit): TTS auf Silbenfragmenten pruefen. Ganze
  // Woerter und Saetze liest die App ueberall per TTS vor, das ist etabliert.
  // Neu ist das Vorlesen einzelner Fragmente („Ap", „fel", „Schmet") – die
  // liest deutsches TTS wie eigene Woerter, was oft danebenklingt. Dieselbe
  // Klasse von Problem fuehrte bei den Anlauten zu Handaufnahmen. Vor dem
  // Anschliessen einmal am Geraet anhoeren, sonst Aufnahmen vorsehen.
  // Gesamtstand des Features: siehe SilbenPage.
  Future<void> _onSpeakSyllable(
    SilbenSpeakSyllable event,
    Emitter<SilbenState> emit,
  ) async {
    if (event.syllable.isNotEmpty) await _audio.speak(event.syllable);
  }

  void _onNext(NextSyllableWordRequested event, Emitter<SilbenState> emit) {
    if (state.hasNext) emit(state.copyWith(index: state.index + 1));
  }

  void _onPrevious(
    PreviousSyllableWordRequested event,
    Emitter<SilbenState> emit,
  ) {
    if (state.hasPrevious) emit(state.copyWith(index: state.index - 1));
  }
}
