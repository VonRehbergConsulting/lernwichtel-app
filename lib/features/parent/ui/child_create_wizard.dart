import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/widgets/menu_icon.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/child_repository.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/repositories/gate_repository.dart';
import '../../../data/repositories/number_repository.dart';
import '../../../data/repositories/reading_repository.dart';
import '../../guided/lesson_widgets.dart';
import '../../learning/learning_sections.dart';

const _avatare = ['🦊', '🐻', '🐰', '🦁', '🐸', '🐼', '🐨', '🦄', '🐝'];

/// Mehrstufiges Anlegen eines Kindes: Name → Avatar → Startniveau. Wischbar
/// (PageView) mit Fortschritts-Punkten. Legt das Kind an und setzt die zum
/// Startniveau passenden Freischaltungen – und markiert bei Vorkenntnissen die
/// konkret schon beherrschten Buchstaben und Zahlen als „sicher", damit Wörter,
/// Lautverbindungen und Zahlenbereiche direkt passend aufgehen.
class ChildCreateWizard extends StatefulWidget {
  const ChildCreateWizard({super.key});

  @override
  State<ChildCreateWizard> createState() => _ChildCreateWizardState();
}

class _ChildCreateWizardState extends State<ChildCreateWizard> {
  final _childRepo = getIt<ChildRepository>();
  final _gate = getIt<GateRepository>();
  final _content = getIt<ContentRepository>();
  final _reading = getIt<ReadingRepository>();
  final _numbers = getIt<NumberRepository>();
  final _name = TextEditingController();
  final _flow = StepController();

  int _step = 0;
  String _avatar = _avatare.first;
  StartLevel _level = StartLevel.anfaenger;
  bool _saving = false;

  /// Alle Buchstaben-Grapheme (fuer die Vorkenntnis-Abfrage).
  List<Grapheme> _letters = const [];

  /// Schon beherrschte Buchstaben (Graphem-IDs) bzw. Zahlen (1..max).
  final Set<int> _knownLetters = {};
  final Set<int> _knownNumbers = {};

  static const _titles = ['Name', 'Avatar', 'Startniveau'];

  bool get _hasName => _name.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _loadLetters();
  }

  Future<void> _loadLetters() async {
    final letters = await _content.graphemesByKind('buchstabe');
    if (!mounted) return;
    setState(() => _letters = letters);
  }

  /// Passt die Vorauswahl ans gewaehlte Niveau an: „geübt" = alles bekannt,
  /// sonst leer (die Eltern haken selbst ab).
  void _selectLevel(StartLevel level) {
    setState(() {
      _level = level;
      _knownLetters.clear();
      _knownNumbers.clear();
      if (level == StartLevel.geuebt) {
        _knownLetters.addAll(_letters.map((g) => g.id));
        for (var n = 1; n <= NumberRepository.maxNumber; n++) {
          _knownNumbers.add(n);
        }
      }
    });
  }

  void _primary() {
    // Beim Verlassen des Namens-Schritts die Tastatur schliessen.
    FocusScope.of(context).unfocus();
    if (_step < 2) {
      _flow.goTo(_step + 1);
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    final name = _name.text.trim();
    if (name.isEmpty || _saving) return;
    setState(() => _saving = true);
    try {
      final child = await _childRepo.create(name: name, avatar: _avatar);
      await _gate.applyStartUnlocks(child.id, _level.unlocks);
      // Konkrete Vorkenntnisse als „sicher" verbuchen -> schaltet Wörter,
      // Lautverbindungen und Zahlenbereiche passend frei.
      for (final id in _knownLetters) {
        await _reading.setMastered(
            childId: child.id, graphemeId: id, mastered: true);
      }
      for (final n in _knownNumbers) {
        await _numbers.setMastered(
            childId: child.id, value: n, mastered: true);
      }
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anlegen fehlgeschlagen. Nochmal?')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auf Schritt 2 (Anlegen) muss ein Name da sein.
    final canPrimary = !_saving && (_step < 2 || _hasName);
    return Scaffold(
      appBar: AppBar(title: Text('Neues Kind · ${_titles[_step]}')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: StepPageView(
                controller: _flow,
                step: _step,
                onStepChanged: (i) {
                  FocusScope.of(context).unfocus();
                  setState(() => _step = i);
                },
                pages: [
                  _page(_nameStep()),
                  _page(_avatarStep()),
                  _page(_levelStep()),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                children: [
                  if (_step > 0)
                    TextButton(
                      onPressed: _saving ? null : () => _flow.goTo(_step - 1),
                      child: const Text('Zurück'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: canPrimary ? _primary : null,
                    child: Text(_step < 2 ? 'Weiter' : 'Anlegen'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Zentriert und begrenzt jeden Schritt (schön auf breiten Tablets). Die
  /// gleichmäßige Polsterung kommt vom [StepPageView].
  Widget _page(Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: child,
      ),
    );
  }

  Widget _nameStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Wie heißt das Kind?', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        TextField(
          controller: _name,
          autofocus: true,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24),
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Name'),
          onChanged: (_) => setState(() {}),
          onSubmitted: (_) {
            if (_hasName) {
              FocusScope.of(context).unfocus();
              _flow.goTo(1);
            }
          },
        ),
      ],
    );
  }

  Widget _avatarStep() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Welches Tier passt?', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: [
            for (final e in _avatare)
              GestureDetector(
                onTap: () => setState(() => _avatar = e),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: _avatar == e ? 80 : 66,
                  height: _avatar == e ? 80 : 66,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _avatar == e
                        ? scheme.primaryContainer
                        : scheme.surfaceContainerHighest,
                    border: _avatar == e
                        ? Border.all(color: scheme.primary, width: 4)
                        : null,
                    boxShadow: _avatar == e
                        ? [
                            BoxShadow(
                              color: scheme.primary.withValues(alpha: 0.35),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(e,
                      style: TextStyle(fontSize: _avatar == e ? 42 : 34)),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _levelStep() {
    return ListView(
      children: [
        const Text('Wo fängt das Kind an?', style: TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        const Text(
          'Das legt fest, welche Bereiche gleich offen sind. Ändern kannst '
          'du das später jederzeit.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 12),
        for (final level in StartLevel.values) _levelCard(level),
        // Bei Vorkenntnissen direkt die konkreten Buchstaben/Zahlen abfragen.
        if (_level != StartLevel.anfaenger) _knownStep(),
      ],
    );
  }

  Widget _levelCard(StartLevel level) {
    final selected = _level == level;
    return Card(
      color: selected ? Theme.of(context).colorScheme.primaryContainer : null,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _selectLevel(level),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MenuIcon(id: level.iconId, emoji: level.emoji, size: 44),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(level.label,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(level.description,
                        style: const TextStyle(color: Colors.black54)),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }

  /// Abfrage der konkret schon beherrschten Buchstaben und Zahlen.
  Widget _knownStep() {
    final name = _hasName ? _name.text.trim() : 'das Kind';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Divider(),
        const SizedBox(height: 8),
        Text('Was kann $name schon?',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        const Text(
          'Tippt an, was schon sicher sitzt. Das schaltet passende Wörter und '
          'Übungen direkt frei – der Rest wächst gemeinsam nach.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 16),
        _pickerHeader(
          'Buchstaben',
          allSelected: _letters.isNotEmpty &&
              _knownLetters.length == _letters.length,
          onAll: () => setState(() =>
              _knownLetters.addAll(_letters.map((g) => g.id))),
          onNone: () => setState(_knownLetters.clear),
        ),
        const SizedBox(height: 8),
        if (_letters.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('…', style: TextStyle(color: Colors.black45)),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final g in _letters)
                _chip(
                  label: g.symbol.toLowerCase(),
                  selected: _knownLetters.contains(g.id),
                  onTap: () => setState(() {
                    if (!_knownLetters.remove(g.id)) _knownLetters.add(g.id);
                  }),
                ),
            ],
          ),
        const SizedBox(height: 20),
        _pickerHeader(
          'Zahlen',
          allSelected:
              _knownNumbers.length == NumberRepository.maxNumber,
          onAll: () => setState(() {
            for (var n = 1; n <= NumberRepository.maxNumber; n++) {
              _knownNumbers.add(n);
            }
          }),
          onNone: () => setState(_knownNumbers.clear),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var n = 1; n <= NumberRepository.maxNumber; n++)
              _chip(
                label: '$n',
                selected: _knownNumbers.contains(n),
                onTap: () => setState(() {
                  if (!_knownNumbers.remove(n)) _knownNumbers.add(n);
                }),
              ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _pickerHeader(
    String title, {
    required bool allSelected,
    required VoidCallback onAll,
    required VoidCallback onNone,
  }) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const Spacer(),
        TextButton(
          onPressed: allSelected ? null : onAll,
          child: const Text('Alle'),
        ),
        TextButton(onPressed: onNone, child: const Text('Keine')),
      ],
    );
  }

  Widget _chip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: 52,
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? scheme.primary : Colors.black12,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: selected ? scheme.onPrimary : Colors.black87,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _flow.dispose();
    super.dispose();
  }
}
