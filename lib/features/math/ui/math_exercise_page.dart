import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/responsive.dart';
import '../../../core/widgets/error_view.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/math_repository.dart';
import '../../../data/repositories/number_repository.dart';
import '../bloc/math_bloc.dart';
import '../model/math_problem.dart';
import 'math_visuals.dart';
import 'number_pad.dart';

/// Übungs-Screen für einen Rechen-Bereich. Aufgabe oben, Antwort-Anzeige,
/// darunter der große Nummernblock. Schwierigkeit passt sich pro Kind an;
/// jederzeit "leichter" möglich.
class MathExercisePage extends StatelessWidget {
  const MathExercisePage({super.key, required this.child, required this.module});

  final Child child;
  final MathModule module;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MathBloc(
        repo: getIt<MathRepository>(),
        numbers: getIt<NumberRepository>(),
      )..add(MathStarted(child.id, module)),
      child: Scaffold(
        appBar: AppBar(title: Text('${module.label} · ${child.name}')),
        body: SafeArea(child: _Body(child: child, module: module)),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.child, required this.module});
  final Child child;
  final MathModule module;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MathBloc, MathState>(
      builder: (context, state) {
        if (state.status == MathStatus.error) {
          return ErrorView(
            onRetry: () =>
                context.read<MathBloc>().add(MathStarted(child.id, module)),
          );
        }
        if (state.status == MathStatus.loading || state.problem == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final bloc = context.read<MathBloc>();
        final compact = context.isCompact;

        // Aufgabe (skaliert in den freien Raum – kein Scrollen) + kurzer
        // Feedback-Streifen darunter.
        final problemPane = Column(
          children: [
            Expanded(child: _FitVisual(child: _Problem(state: state))),
            _Feedback(state: state),
            const SizedBox(height: 8),
          ],
        );

        final numberPad = Padding(
          padding: compact
              ? const EdgeInsets.fromLTRB(16, 0, 16, 8)
              : const EdgeInsets.fromLTRB(8, 8, 16, 8),
          child: Center(
            child: SizedBox(
              width: compact ? 340 : 360,
              child: NumberPad(
                enabled: state.phase == MathPhase.answering,
                onDigit: (d) => bloc.add(DigitTyped(d)),
                onBackspace: () => bloc.add(const BackspacePressed()),
                onSubmit: () => bloc.add(const AnswerSubmitted()),
              ),
            ),
          ),
        );

        return Column(
          children: [
            _LevelBar(state: state, bloc: bloc),
            Expanded(
              // Hochformat (Handy): Aufgabe oben, Nummernblock unten.
              // Querformat (Tablet): Aufgabe links, Nummernblock rechts.
              child: compact
                  ? Column(
                      children: [Expanded(child: problemPane), numberPad],
                    )
                  : Row(
                      children: [Expanded(child: problemPane), numberPad],
                    ),
            ),
          ],
        );
      },
    );
  }
}

/// Passt ein Aufgaben-Visual so an, dass es den verfügbaren Platz **ausfüllt,
/// aber nie überläuft** – so muss man auch bei „Zahlen bis 100" oder Plus/Minus
/// nichts scrollen. Kleine Mengen bleiben in Originalgröße (kein Hochskalieren).
class _FitVisual extends StatelessWidget {
  const _FitVisual({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth > 24 ? c.maxWidth - 24 : c.maxWidth;
        return Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(width: w, child: child),
          ),
        );
      },
    );
  }
}

class _LevelBar extends StatelessWidget {
  const _LevelBar({required this.state, required this.bloc});
  final MathState state;
  final MathBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Text('Stufe ${state.level}',
              style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          TextButton.icon(
            onPressed: state.level > 1
                ? () => bloc.add(const EasierRequested())
                : null,
            icon: const Icon(Icons.arrow_downward),
            label: const Text('leichter'),
          ),
        ],
      ),
    );
  }
}

class _Problem extends StatelessWidget {
  const _Problem({required this.state});
  final MathState state;

  @override
  Widget build(BuildContext context) {
    final p = state.problem!;
    switch (p.visual) {
      case MathVisual.objekte:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ObjectsView(count: p.a!, slug: p.object),
            const SizedBox(height: 24),
            const Text('Wie viele?', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 12),
            _AnswerBox(state: state),
          ],
        );
      case MathVisual.zehnerEiner:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TensOnesView(value: p.a!),
            const SizedBox(height: 24),
            const Text('Welche Zahl?', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 12),
            _AnswerBox(state: state),
          ],
        );
      case MathVisual.gleichung:
        return _EquationView(state: state);
    }
  }
}

/// Gleichung „a op b = [Antwort]“, bei kleinen Zahlen mit Objektreihen.
class _EquationView extends StatelessWidget {
  const _EquationView({required this.state});
  final MathState state;

  @override
  Widget build(BuildContext context) {
    final p = state.problem!;
    final showObjects = p.a! <= 10 && p.b! <= 10;
    const numStyle = TextStyle(fontSize: 64, fontWeight: FontWeight.w800);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showObjects) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: OperandObjects(count: p.a!, slug: p.object),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(p.op!, style: numStyle),
              ),
              Flexible(
                child: OperandObjects(count: p.b!, slug: p.object),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 14,
          children: [
            Text('${p.a}', style: numStyle),
            Text(p.op!, style: numStyle),
            Text('${p.b}', style: numStyle),
            const Text('=', style: numStyle),
            _AnswerBox(state: state),
          ],
        ),
      ],
    );
  }
}

/// Anzeige der eingetippten Antwort; färbt sich bei Feedback grün/rot.
class _AnswerBox extends StatelessWidget {
  const _AnswerBox({required this.state});
  final MathState state;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Color border = scheme.outline;
    Color fill = scheme.surfaceContainerHighest;
    if (state.phase == MathPhase.feedback) {
      final ok = state.lastCorrect == true;
      border = ok ? const Color(0xFF2E7D32) : const Color(0xFFC62828);
      fill = ok ? const Color(0xFFC8E6C9) : const Color(0xFFFFCDD2);
    }
    return Container(
      constraints: const BoxConstraints(minWidth: 110),
      height: 96,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 4),
      ),
      child: Text(
        state.entered.isEmpty ? '?' : state.entered,
        style: const TextStyle(fontSize: 56, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.state});
  final MathState state;

  @override
  Widget build(BuildContext context) {
    if (state.phase != MathPhase.feedback) {
      return const SizedBox(height: 40);
    }
    final ok = state.lastCorrect == true;
    final String text;
    if (ok) {
      text = state.leveledUp ? 'Super! Eine Stufe weiter! ⭐' : 'Richtig! 🎉';
    } else {
      text = 'Fast! Richtig ist ${state.problem!.answer}.'
          '${state.leveledDown ? ' Wir machen es leichter.' : ''}';
    }
    return SizedBox(
      height: 40,
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: ok ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
          ),
        ),
      ),
    );
  }
}
