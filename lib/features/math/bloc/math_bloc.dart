import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/math_repository.dart';
import '../../../data/repositories/number_repository.dart';
import '../model/math_problem.dart';

// ----------------------------- Events -----------------------------

sealed class MathEvent extends Equatable {
  const MathEvent();
  @override
  List<Object?> get props => const [];
}

class MathStarted extends MathEvent {
  const MathStarted(this.childId, this.module);
  final int childId;
  final MathModule module;
  @override
  List<Object?> get props => [childId, module];
}

class DigitTyped extends MathEvent {
  const DigitTyped(this.digit);
  final int digit;
  @override
  List<Object?> get props => [digit];
}

class BackspacePressed extends MathEvent {
  const BackspacePressed();
}

class AnswerSubmitted extends MathEvent {
  const AnswerSubmitted();
}

class EasierRequested extends MathEvent {
  const EasierRequested();
}

class _NextProblem extends MathEvent {
  const _NextProblem();
}

// ----------------------------- State -----------------------------

enum MathStatus { loading, ready, error }

/// answering = Kind tippt; feedback = Ergebnis wird kurz gezeigt.
enum MathPhase { answering, feedback }

class MathState extends Equatable {
  const MathState({
    this.status = MathStatus.loading,
    this.module,
    this.level = 1,
    this.problem,
    this.phase = MathPhase.answering,
    this.entered = '',
    this.lastCorrect,
    this.leveledUp = false,
    this.leveledDown = false,
  });

  final MathStatus status;
  final MathModule? module;
  final int level;
  final MathProblem? problem;
  final MathPhase phase;

  /// Aktuell eingetippte Ziffernfolge.
  final String entered;

  /// Nur in der Feedback-Phase gesetzt.
  final bool? lastCorrect;
  final bool leveledUp;
  final bool leveledDown;

  bool get canSubmit =>
      phase == MathPhase.answering && entered.isNotEmpty;

  MathState copyWith({
    MathStatus? status,
    MathModule? module,
    int? level,
    MathProblem? problem,
    MathPhase? phase,
    String? entered,
    bool? lastCorrect,
    bool clearLastCorrect = false,
    bool? leveledUp,
    bool? leveledDown,
  }) {
    return MathState(
      status: status ?? this.status,
      module: module ?? this.module,
      level: level ?? this.level,
      problem: problem ?? this.problem,
      phase: phase ?? this.phase,
      entered: entered ?? this.entered,
      lastCorrect: clearLastCorrect ? null : (lastCorrect ?? this.lastCorrect),
      leveledUp: leveledUp ?? this.leveledUp,
      leveledDown: leveledDown ?? this.leveledDown,
    );
  }

  @override
  List<Object?> get props => [
        status,
        module,
        level,
        problem,
        phase,
        entered,
        lastCorrect,
        leveledUp,
        leveledDown,
      ];
}

// ----------------------------- Bloc -----------------------------

class MathBloc extends Bloc<MathEvent, MathState> {
  MathBloc({required MathRepository repo, NumberRepository? numbers})
      : _repo = repo,
        _numbers = numbers,
        super(const MathState()) {
    on<MathStarted>(_onStarted);
    on<DigitTyped>(_onDigit);
    on<BackspacePressed>(_onBackspace);
    on<AnswerSubmitted>(_onAnswer);
    on<EasierRequested>(_onEasier);
    on<_NextProblem>(_onNext);
  }

  final MathRepository _repo;

  /// Optional: begrenzt die Ziffern aufs bereits Eingeführte (null = ungegated).
  final NumberRepository? _numbers;
  final _rnd = Random();
  int _childId = 0;
  int? _cap;

  Future<void> _onStarted(MathStarted e, Emitter<MathState> emit) async {
    _childId = e.childId;
    try {
      final skill = await _repo.skill(_childId, e.module.key);
      // Ziffern: nie über die eingeführten Zahlen hinaus (Boden 1, damit vor
      // der ersten Lektion nicht 1–3 abgefragt werden).
      if (e.module == MathModule.ziffern && _numbers != null) {
        final introduced = await _numbers.highestIntroduced(_childId);
        _cap = introduced < 1 ? 1 : introduced;
      } else {
        _cap = null;
      }
      emit(MathState(
        status: MathStatus.ready,
        module: e.module,
        level: skill.level,
        problem: generateProblem(e.module, skill.level, _rnd, maxNumber: _cap),
        phase: MathPhase.answering,
      ));
    } catch (err, st) {
      addError(err, st);
      emit(const MathState(status: MathStatus.error));
    }
  }

  void _onDigit(DigitTyped e, Emitter<MathState> emit) {
    if (state.phase != MathPhase.answering) return;
    if (state.entered.length >= 3) return; // bis 999 reicht locker
    // Fuehrende Null nur zulassen, wenn noch nichts getippt wurde.
    final next = state.entered == '0' ? '${e.digit}' : '${state.entered}${e.digit}';
    emit(state.copyWith(entered: next));
  }

  void _onBackspace(BackspacePressed e, Emitter<MathState> emit) {
    if (state.phase != MathPhase.answering || state.entered.isEmpty) return;
    emit(state.copyWith(
        entered: state.entered.substring(0, state.entered.length - 1)));
  }

  Future<void> _onAnswer(AnswerSubmitted e, Emitter<MathState> emit) async {
    if (!state.canSubmit || state.problem == null || state.module == null) {
      return;
    }
    final value = int.tryParse(state.entered);
    if (value == null) return;
    final correct = value == state.problem!.answer;

    final outcome = await _repo.recordAnswer(
      childId: _childId,
      module: state.module!.key,
      problem: state.problem!.promptText,
      correct: correct,
    );

    emit(state.copyWith(
      phase: MathPhase.feedback,
      lastCorrect: correct,
      level: outcome.skill.level,
      leveledUp: outcome.leveledUp,
      leveledDown: outcome.leveledDown,
    ));

    await Future.delayed(Duration(milliseconds: correct ? 900 : 1700));
    if (isClosed) return;
    add(const _NextProblem());
  }

  void _onNext(_NextProblem e, Emitter<MathState> emit) {
    if (state.module == null) return;
    emit(state.copyWith(
      problem:
          generateProblem(state.module!, state.level, _rnd, maxNumber: _cap),
      phase: MathPhase.answering,
      entered: '',
      clearLastCorrect: true,
      leveledUp: false,
      leveledDown: false,
    ));
  }

  Future<void> _onEasier(EasierRequested e, Emitter<MathState> emit) async {
    if (state.module == null) return;
    final skill = await _repo.decreaseLevel(_childId, state.module!.key);
    emit(state.copyWith(
      level: skill.level,
      problem: generateProblem(state.module!, skill.level, _rnd, maxNumber: _cap),
      phase: MathPhase.answering,
      entered: '',
      clearLastCorrect: true,
      leveledUp: false,
      leveledDown: false,
    ));
  }
}
