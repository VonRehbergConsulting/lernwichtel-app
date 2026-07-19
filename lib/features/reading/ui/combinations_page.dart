import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/theme/tile_style.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/fullscreen_image.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/repositories/progression_repository.dart';
import '../../../data/repositories/reading_repository.dart';
import '../../hunt/fundstuecke_strip.dart';
import '../../hunt/sound_hunt_page.dart';
import '../bloc/combinations_bloc.dart';

/// Lese-Modul, Phase 2: Lautverbindungen (ei, au, sch, sp, st …).
///
/// Prinzip: der isolierte Laut wird gezeigt und vorgesprochen, dann ein
/// kindgerechtes Beispielwort mit farblich hervorgehobener Verbindung.
class CombinationsPage extends StatelessWidget {
  const CombinationsPage({super.key, required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CombinationsBloc(
        content: getIt<ContentRepository>(),
        reading: getIt<ReadingRepository>(),
        progression: getIt<ProgressionRepository>(),
        audio: getIt<AudioService>(),
      )..add(CombinationsStarted(child.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lautverbindungen · ${child.name}'),
          actions: [
            Builder(
              builder: (context) {
                final combo =
                    context.watch<CombinationsBloc>().state.currentCombo;
                return IconButton(
                  tooltip: 'Foto-Schatzsuche',
                  icon: const Icon(Icons.photo_camera_outlined),
                  onPressed: combo == null
                      ? null
                      : () {
                          final l = combo.symbol.toLowerCase();
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                builder: (_) => SoundHuntPage(
                                  sound: l,
                                  letter: l,
                                  childId: child.id,
                                ),
                              ))
                              .then((_) {
                            if (context.mounted) {
                              context
                                  .read<CombinationsBloc>()
                                  .add(CombinationsStarted(child.id));
                            }
                          });
                        },
                );
              },
            ),
            Builder(
              builder: (context) => IconButton(
                tooltip: 'Neue Runde',
                icon: const Icon(Icons.refresh),
                onPressed: () => context
                    .read<CombinationsBloc>()
                    .add(const NewComboRoundRequested()),
              ),
            ),
          ],
        ),
        body: SafeArea(child: _Body(child.id)),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.childId);
  final int childId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CombinationsBloc, CombinationsState>(
      builder: (context, state) {
        switch (state.status) {
          case CombinationsStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case CombinationsStatus.error:
            return ErrorView(
              onRetry: () => context
                  .read<CombinationsBloc>()
                  .add(CombinationsStarted(childId)),
            );
          case CombinationsStatus.empty:
            return const Center(
              child: Text('Keine Lautverbindungen vorhanden.',
                  style: TextStyle(fontSize: 20)),
            );
          case CombinationsStatus.ready:
            return _Exercise(state: state, childId: childId);
        }
      },
    );
  }
}

class _Exercise extends StatelessWidget {
  const _Exercise({required this.state, required this.childId});
  final CombinationsState state;
  final int childId;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CombinationsBloc>();
    final combo = state.currentCombo!;
    final example = state.currentExample;

    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 8),
            Text('${state.index + 1} / ${state.combos.length}',
                style: Theme.of(context).textTheme.labelLarge),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _ComboTile(
                        symbol: combo.symbol,
                        mastered: state.isMastered,
                        onTap: () =>
                            bloc.add(const ComboSoundRequested()),
                        onLongPress: () => bloc.add(const ComboMastered()),
                      ),
                      if (combo.merkhilfe != null) ...[
                        const SizedBox(height: 16),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            combo.merkhilfe!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                      FundstueckeStrip(
                          childId: childId, letter: combo.symbol),
                      const SizedBox(height: 28),
                      if (example != null)
                        _ExampleWord(
                          word: example.word.word,
                          highlight: combo.symbol,
                          onTap: () =>
                              bloc.add(const ExampleSpeakRequested()),
                        )
                      else
                        const Text('Kein Beispielwort',
                            style: TextStyle(fontSize: 18)),
                      if (state.examples.length > 1)
                        TextButton.icon(
                          onPressed: () =>
                              bloc.add(const NextExampleRequested()),
                          icon: const Icon(Icons.casino_outlined),
                          label: const Text('Anderes Beispiel'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            _Controls(state: state, bloc: bloc),
            const SizedBox(height: 12),
            _Navigation(state: state, bloc: bloc),
            const SizedBox(height: 12),
          ],
        ),
        if (state.imageRevealed && example != null)
          Positioned.fill(
            child: FullscreenImage(
              imagePath: example.imagePath,
              label: example.word.word,
              onClose: () => bloc.add(const ImageToggled()),
            ),
          ),
      ],
    );
  }
}

/// Grosse Kachel mit der isolierten Lautverbindung.
class _ComboTile extends StatelessWidget {
  const _ComboTile({
    required this.symbol,
    required this.mastered,
    required this.onTap,
    required this.onLongPress,
  });

  final String symbol;
  final bool mastered;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        decoration: TileStyle.surface(
          const Color(0xFF4FC3F7),
          radius: 28,
          border: mastered
              ? Border.all(color: const Color(0xFF2E7D32), width: 6)
              : null,
        ),
        child: Text(
          symbol.toLowerCase(),
          style: const TextStyle(
            fontSize: 96,
            fontWeight: FontWeight.w800,
            color: TileStyle.ink,
          ),
        ),
      ),
    );
  }
}

/// Beispielwort mit hervorgehobener Lautverbindung.
class _ExampleWord extends StatelessWidget {
  const _ExampleWord({
    required this.word,
    required this.highlight,
    required this.onTap,
  });

  final String word;
  final String highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lower = word.toLowerCase();
    final needle = highlight.toLowerCase();
    final at = lower.indexOf(needle);

    const base = TextStyle(
      fontSize: 56,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
    );
    final accent = base.copyWith(color: const Color(0xFF0277BD));

    final spans = <TextSpan>[];
    if (at < 0) {
      spans.add(TextSpan(text: lower, style: base));
    } else {
      if (at > 0) {
        spans.add(TextSpan(text: lower.substring(0, at), style: base));
      }
      spans.add(TextSpan(
          text: lower.substring(at, at + needle.length), style: accent));
      spans.add(
          TextSpan(text: lower.substring(at + needle.length), style: base));
    }

    return GestureDetector(
      onTap: onTap,
      child: Text.rich(TextSpan(children: spans)),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.state, required this.bloc});
  final CombinationsState state;
  final CombinationsBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: () => bloc.add(const ComboSoundRequested()),
          icon: const Icon(Icons.hearing),
          label: const Text('Laut hören'),
        ),
        FilledButton.tonalIcon(
          onPressed: () => bloc.add(const ExampleSpeakRequested()),
          icon: const Icon(Icons.volume_up),
          label: const Text('Wort vorlesen'),
        ),
        FilledButton.tonalIcon(
          onPressed: () => bloc.add(const ImageToggled()),
          icon: Icon(state.imageRevealed ? Icons.visibility_off : Icons.image),
          label: Text(state.imageRevealed ? 'Bild verbergen' : 'Bild zeigen'),
        ),
      ],
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation({required this.state, required this.bloc});
  final CombinationsState state;
  final CombinationsBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton.filledTonal(
          iconSize: 40,
          onPressed: state.hasPrevious
              ? () => bloc.add(const PreviousComboRequested())
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton.filledTonal(
          iconSize: 40,
          onPressed: state.hasNext
              ? () => bloc.add(const NextComboRequested())
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
