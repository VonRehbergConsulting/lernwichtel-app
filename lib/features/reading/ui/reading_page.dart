import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/responsive.dart';
import '../../../core/theme/tile_style.dart';
import '../../../core/widgets/error_view.dart';
import '../../../core/widgets/fullscreen_image.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/repositories/progression_repository.dart';
import '../../../data/repositories/reading_repository.dart';
import '../../hunt/fundstuecke_strip.dart';
import '../../hunt/sound_hunt_page.dart';
import '../bloc/reading_bloc.dart';

/// Frohe Farbpalette fuer die Buchstaben-Kacheln (nach Position durchrotiert).
const _letterColors = <Color>[
  Color(0xFFFF8A65), // Orange
  Color(0xFF4FC3F7), // Hellblau
  Color(0xFF81C784), // Gruen
  Color(0xFFFFD54F), // Gelb
  Color(0xFFBA68C8), // Lila
  Color(0xFFF06292), // Pink
  Color(0xFF4DB6AC), // Tuerkis
];

/// Lese-Modul, Buchstaben-Phase.
///
/// Ablauf: Wort erscheint (klein geschrieben) -> Kind tippt einen Buchstaben
/// und hoert dessen Laut -> optional ganzes Wort vorlesen -> Bild erst auf
/// Wunsch einblenden. Langer Druck auf einen Buchstaben = "beherrscht".
class ReadingPage extends StatelessWidget {
  const ReadingPage({super.key, required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ReadingBloc(
        content: getIt<ContentRepository>(),
        reading: getIt<ReadingRepository>(),
        progression: getIt<ProgressionRepository>(),
        audio: getIt<AudioService>(),
      )..add(ReadingStarted(child.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Lesen · ${child.name}'),
          centerTitle: true,
          actions: [
            Builder(
              builder: (context) {
                final word =
                    context.watch<ReadingBloc>().state.currentWord?.word.word;
                return IconButton(
                  tooltip: 'Foto-Schatzsuche',
                  icon: const Icon(Icons.photo_camera_outlined),
                  onPressed: (word == null || word.isEmpty)
                      ? null
                      : () {
                          final l = word[0].toLowerCase();
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
                                  .read<ReadingBloc>()
                                  .add(ReadingStarted(child.id));
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
                onPressed: () =>
                    context.read<ReadingBloc>().add(const NewRoundRequested()),
              ),
            ),
          ],
        ),
        body: SafeArea(child: _ReadingBody(child.id)),
      ),
    );
  }
}

class _ReadingBody extends StatelessWidget {
  const _ReadingBody(this.childId);
  final int childId;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReadingBloc, ReadingState>(
      builder: (context, state) {
        switch (state.status) {
          case ReadingStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case ReadingStatus.error:
            return ErrorView(
              onRetry: () =>
                  context.read<ReadingBloc>().add(ReadingStarted(childId)),
            );
          case ReadingStatus.empty:
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Noch nichts zum Üben.\n'
                  'Macht zuerst eine Lektion mit den Eltern –\n'
                  'dann erscheinen hier passende Wörter.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ),
            );
          case ReadingStatus.ready:
            return _Exercise(state: state, childId: childId);
        }
      },
    );
  }
}

class _Exercise extends StatelessWidget {
  const _Exercise({required this.state, required this.childId});
  final ReadingState state;
  final int childId;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReadingBloc>();
    final word = state.currentWord!;
    final anlaut = word.word.word.isEmpty ? '' : word.word.word[0];

    return Stack(
      children: [
        Column(
          children: [
            const SizedBox(height: 8),
            // Fortschritt durch die Wortliste.
            Text(
              '${state.index + 1} / ${state.words.length}',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: _LetterRow(word: word.word.word, state: state),
                ),
              ),
            ),
            // Eigene Fundstücke zum Anlaut des Wortes – ruft den Laut wieder
            // ins Gedächtnis.
            if (anlaut.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: FundstueckeStrip(childId: childId, letter: anlaut),
              ),
            _Controls(state: state, bloc: bloc),
            const SizedBox(height: 12),
            _Navigation(state: state, bloc: bloc),
            const SizedBox(height: 12),
          ],
        ),
        // Bild bildschirmfuellend – erscheint erst auf Wunsch, Tippen schliesst.
        if (state.imageRevealed)
          Positioned.fill(
            child: FullscreenImage(
              imagePath: word.imagePath,
              label: word.word.word,
              onClose: () => bloc.add(const ImageToggled()),
            ),
          ),
      ],
    );
  }
}

/// Das Wort als Reihe grosser, antippbarer Buchstaben (klein geschrieben).
class _LetterRow extends StatelessWidget {
  const _LetterRow({required this.word, required this.state});
  final String word;
  final ReadingState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ReadingBloc>();
    final letters = word.toLowerCase().split('');

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        for (var i = 0; i < letters.length; i++)
          _LetterTile(
            letter: letters[i],
            color: _letterColors[i % _letterColors.length],
            mastered: state.masteredSymbols.contains(letters[i]),
            onTap: () => bloc.add(LetterTapped(letters[i])),
            onLongPress: () => bloc.add(LetterMastered(letters[i])),
          ),
      ],
    );
  }
}

class _LetterTile extends StatelessWidget {
  const _LetterTile({
    required this.letter,
    required this.color,
    required this.mastered,
    required this.onTap,
    required this.onLongPress,
  });

  final String letter;
  final Color color;
  final bool mastered;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final compact = context.isCompact;
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: compact ? 62 : 92,
        height: compact ? 82 : 120,
        alignment: Alignment.center,
        decoration: TileStyle.surface(
          color,
          radius: 22,
          depth: 0.7,
          border: mastered
              ? Border.all(color: const Color(0xFF2E7D32), width: 5)
              : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              letter,
              style: TextStyle(
                fontSize: compact ? 46 : 68,
                fontWeight: FontWeight.w800,
                color: TileStyle.ink,
              ),
            ),
            if (mastered)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(Icons.check_circle,
                    color: Color(0xFF2E7D32), size: 22),
              ),
          ],
        ),
      ),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({required this.state, required this.bloc});
  final ReadingState state;
  final ReadingBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: () => bloc.add(const WordSpeakRequested()),
          icon: const Icon(Icons.volume_up),
          label: const Text('Vorlesen'),
        ),
        FilledButton.tonalIcon(
          onPressed: () => bloc.add(const ImageToggled()),
          icon: Icon(
            state.imageRevealed ? Icons.visibility_off : Icons.image,
          ),
          label: Text(state.imageRevealed ? 'Bild verbergen' : 'Bild zeigen'),
        ),
      ],
    );
  }
}

class _Navigation extends StatelessWidget {
  const _Navigation({required this.state, required this.bloc});
  final ReadingState state;
  final ReadingBloc bloc;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton.filledTonal(
          iconSize: 40,
          onPressed: state.hasPrevious
              ? () => bloc.add(const PreviousWordRequested())
              : null,
          icon: const Icon(Icons.chevron_left),
        ),
        IconButton.filledTonal(
          iconSize: 40,
          onPressed: state.hasNext
              ? () => bloc.add(const NextWordRequested())
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}
