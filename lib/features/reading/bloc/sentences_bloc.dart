import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/audio/audio_service.dart';
import '../../../data/repositories/content_repository.dart';

// ----------------------------- Events -----------------------------

sealed class SentencesEvent extends Equatable {
  const SentencesEvent();
  @override
  List<Object?> get props => const [];
}

class SentencesStarted extends SentencesEvent {
  const SentencesStarted();
}

/// Einzelnes Wort im Satz antippen -> vorlesen.
class SentenceWordTapped extends SentencesEvent {
  const SentenceWordTapped(this.word);
  final String word;
  @override
  List<Object?> get props => [word];
}

/// Ganzen Satz vorlesen.
class SentenceSpeakRequested extends SentencesEvent {
  const SentenceSpeakRequested();
}

class NextSentenceRequested extends SentencesEvent {
  const NextSentenceRequested();
}

class PreviousSentenceRequested extends SentencesEvent {
  const PreviousSentenceRequested();
}

/// Noch ein paar Sätze freischalten (Batch-Lernen, auf Wunsch des Kindes).
class MoreSentencesRequested extends SentencesEvent {
  const MoreSentencesRequested();
}

// ----------------------------- State -----------------------------

enum SentencesStatus { loading, ready, empty, error }

class SentencesState extends Equatable {
  const SentencesState({
    this.status = SentencesStatus.loading,
    this.sentences = const [],
    this.index = 0,
    this.revealed = 0,
  });

  final SentencesStatus status;
  final List<SentenceItem> sentences;
  final int index;

  /// Wie viele Sätze aktuell im Batch verfügbar sind (wächst auf Wunsch).
  final int revealed;

  SentenceItem? get current =>
      sentences.isEmpty ? null : sentences[index];
  bool get hasNext => index < revealed - 1;
  bool get hasPrevious => index > 0;
  bool get canRevealMore => revealed < sentences.length;

  SentencesState copyWith({
    SentencesStatus? status,
    List<SentenceItem>? sentences,
    int? index,
    int? revealed,
  }) {
    return SentencesState(
      status: status ?? this.status,
      sentences: sentences ?? this.sentences,
      index: index ?? this.index,
      revealed: revealed ?? this.revealed,
    );
  }

  @override
  List<Object?> get props => [status, sentences, index, revealed];
}

// ----------------------------- Bloc -----------------------------

class SentencesBloc extends Bloc<SentencesEvent, SentencesState> {
  SentencesBloc({
    required ContentRepository content,
    required AudioService audio,
  })  : _content = content,
        _audio = audio,
        super(const SentencesState()) {
    on<SentencesStarted>(_onStarted);
    on<SentenceWordTapped>(_onWordTapped);
    on<SentenceSpeakRequested>(_onSpeak);
    on<NextSentenceRequested>(_onNext);
    on<PreviousSentenceRequested>(_onPrevious);
    on<MoreSentencesRequested>(_onMore);
  }

  final ContentRepository _content;
  final AudioService _audio;

  // Batch-Lernen: erst ein paar Sätze, dann auf Wunsch mehr.
  static const _batchStart = 4;
  static const _batchStep = 4;

  Future<void> _onStarted(
    SentencesStarted event,
    Emitter<SentencesState> emit,
  ) async {
    try {
      final sentences = await _content.loadSentences();
      emit(state.copyWith(
        status:
            sentences.isEmpty ? SentencesStatus.empty : SentencesStatus.ready,
        sentences: sentences,
        index: 0,
        revealed:
            sentences.length < _batchStart ? sentences.length : _batchStart,
      ));
    } catch (e, st) {
      addError(e, st);
      emit(state.copyWith(status: SentencesStatus.error));
    }
  }

  void _onMore(MoreSentencesRequested event, Emitter<SentencesState> emit) {
    if (!state.canRevealMore) return;
    final firstNew = state.revealed; // Sprung zum ersten neuen Satz
    final next = state.revealed + _batchStep;
    emit(state.copyWith(
      revealed: next > state.sentences.length ? state.sentences.length : next,
      index: firstNew,
    ));
  }

  Future<void> _onWordTapped(
    SentenceWordTapped event,
    Emitter<SentencesState> emit,
  ) async {
    // Satzzeichen fuers Vorlesen abstreifen.
    final clean = event.word.replaceAll(RegExp(r'[.,!?;:]'), '');
    if (clean.isNotEmpty) await _audio.speak(clean);
  }

  Future<void> _onSpeak(
    SentenceSpeakRequested event,
    Emitter<SentencesState> emit,
  ) async {
    final s = state.current;
    if (s != null) await _audio.speak(s.text);
  }

  void _onNext(NextSentenceRequested event, Emitter<SentencesState> emit) {
    if (state.hasNext) emit(state.copyWith(index: state.index + 1));
  }

  void _onPrevious(
    PreviousSentenceRequested event,
    Emitter<SentencesState> emit,
  ) {
    if (state.hasPrevious) emit(state.copyWith(index: state.index - 1));
  }
}
