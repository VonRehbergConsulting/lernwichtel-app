import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/db/database.dart';
import '../../../data/repositories/child_repository.dart';

// ----------------------------- Events -----------------------------

sealed class ProfilesEvent extends Equatable {
  const ProfilesEvent();
  @override
  List<Object?> get props => const [];
}

/// Startet das Beobachten der Profil-Liste.
class ProfilesStarted extends ProfilesEvent {
  const ProfilesStarted();
}

/// Internes Event: die Liste hat sich geaendert.
class _ProfilesUpdated extends ProfilesEvent {
  const _ProfilesUpdated(this.children);
  final List<Child> children;
  @override
  List<Object?> get props => [children];
}

/// Internes Event: das Beobachten der Profile schlug fehl.
class _ProfilesFailed extends ProfilesEvent {
  const _ProfilesFailed();
}

// ----------------------------- State -----------------------------

enum ProfilesStatus { loading, ready, error }

class ProfilesState extends Equatable {
  const ProfilesState({
    this.status = ProfilesStatus.loading,
    this.children = const [],
  });

  final ProfilesStatus status;
  final List<Child> children;

  ProfilesState copyWith({
    ProfilesStatus? status,
    List<Child>? children,
  }) {
    return ProfilesState(
      status: status ?? this.status,
      children: children ?? this.children,
    );
  }

  @override
  List<Object?> get props => [status, children];
}

// ----------------------------- Bloc -----------------------------

/// Beobachtet die Profil-Liste (Anlegen/Umbenennen/Loeschen laufen direkt
/// ueber das [ChildRepository]; die Liste aktualisiert sich per Stream).
class ProfilesBloc extends Bloc<ProfilesEvent, ProfilesState> {
  ProfilesBloc(this._repo) : super(const ProfilesState()) {
    on<ProfilesStarted>(_onStarted);
    on<_ProfilesUpdated>(_onUpdated);
    on<_ProfilesFailed>(_onFailed);
  }

  final ChildRepository _repo;
  StreamSubscription<List<Child>>? _sub;

  Future<void> _onStarted(
    ProfilesStarted event,
    Emitter<ProfilesState> emit,
  ) async {
    await _sub?.cancel();
    _sub = _repo.watchAll().listen(
      (children) => add(_ProfilesUpdated(children)),
      onError: (Object e, StackTrace st) {
        addError(e, st);
        add(const _ProfilesFailed());
      },
    );
  }

  void _onFailed(_ProfilesFailed event, Emitter<ProfilesState> emit) {
    emit(state.copyWith(status: ProfilesStatus.error));
  }

  void _onUpdated(_ProfilesUpdated event, Emitter<ProfilesState> emit) {
    emit(state.copyWith(
      status: ProfilesStatus.ready,
      children: event.children,
    ));
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
