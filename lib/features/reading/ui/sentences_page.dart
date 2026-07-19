import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/audio/audio_service.dart';
import '../../../core/di/service_locator.dart';
import '../../../core/widgets/error_view.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/content_repository.dart';
import '../bloc/sentences_bloc.dart';

/// Lese-Modul, Phase 3: einfache Saetze.
///
/// Das Kind kann einzelne Woerter antippen (werden vorgelesen) oder sich den
/// ganzen Satz vorlesen lassen.
class SentencesPage extends StatelessWidget {
  const SentencesPage({super.key, required this.child});

  final Child child;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SentencesBloc(
        content: getIt<ContentRepository>(),
        audio: getIt<AudioService>(),
      )..add(const SentencesStarted()),
      child: Scaffold(
        appBar: AppBar(title: Text('Sätze · ${child.name}')),
        body: const SafeArea(child: _Body()),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SentencesBloc, SentencesState>(
      builder: (context, state) {
        switch (state.status) {
          case SentencesStatus.loading:
            return const Center(child: CircularProgressIndicator());
          case SentencesStatus.error:
            return ErrorView(
              onRetry: () =>
                  context.read<SentencesBloc>().add(const SentencesStarted()),
            );
          case SentencesStatus.empty:
            return const Center(
              child: Text('Keine Sätze vorhanden.',
                  style: TextStyle(fontSize: 20)),
            );
          case SentencesStatus.ready:
            return _Exercise(state: state);
        }
      },
    );
  }
}

class _Exercise extends StatelessWidget {
  const _Exercise({required this.state});
  final SentencesState state;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<SentencesBloc>();
    final sentence = state.current!;

    return Column(
      children: [
        const SizedBox(height: 8),
        Text('${state.index + 1} / ${state.revealed}',
            style: Theme.of(context).textTheme.labelLarge),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final word in sentence.words)
                    _WordChip(
                      word: word,
                      onTap: () => bloc.add(SentenceWordTapped(word)),
                    ),
                ],
              ),
            ),
          ),
        ),
        FilledButton.icon(
          onPressed: () => bloc.add(const SentenceSpeakRequested()),
          icon: const Icon(Icons.volume_up),
          label: const Text('Satz vorlesen'),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton.filledTonal(
              iconSize: 40,
              onPressed: state.hasPrevious
                  ? () => bloc.add(const PreviousSentenceRequested())
                  : null,
              icon: const Icon(Icons.chevron_left),
            ),
            IconButton.filledTonal(
              iconSize: 40,
              onPressed: state.hasNext
                  ? () => bloc.add(const NextSentenceRequested())
                  : null,
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        if (state.canRevealMore) ...[
          const SizedBox(height: 12),
          FilledButton.tonalIcon(
            onPressed: () => bloc.add(const MoreSentencesRequested()),
            icon: const Icon(Icons.add),
            label: const Text('Mehr Sätze'),
          ),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

/// Ein antippbares Wort im Satz.
class _WordChip extends StatelessWidget {
  const _WordChip({required this.word, required this.onTap});
  final String word;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFA5D6A7),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          word,
          style: const TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}
