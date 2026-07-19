import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/child_repository.dart';
import '../../../data/repositories/content_repository.dart';
import '../../../data/repositories/gate_repository.dart';
import '../../../data/repositories/number_repository.dart';
import '../../../data/repositories/reading_repository.dart';
import '../../learning/learning_sections.dart';

/// Details zu einem Kind: umbenennen, loeschen und die beherrschten Laute
/// (Buchstaben) abhaken.
class ChildDetailPage extends StatefulWidget {
  const ChildDetailPage({super.key, required this.child});
  final Child child;

  @override
  State<ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends State<ChildDetailPage> {
  final _childRepo = getIt<ChildRepository>();
  final _content = getIt<ContentRepository>();
  final _reading = getIt<ReadingRepository>();
  final _numbers = getIt<NumberRepository>();
  final _gate = getIt<GateRepository>();

  late final TextEditingController _name =
      TextEditingController(text: widget.child.name);

  List<Grapheme> _letters = const [];
  final Set<int> _mastered = {};
  final Set<int> _masteredNumbers = {};
  Set<String> _manualUnlocks = const {};
  Set<String> _autoUnlocks = const {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final letters = await _content.graphemesByKind('buchstabe');
    final progress = await _reading.progressFor(widget.child.id);
    final numberProgress = await _numbers.progressFor(widget.child.id);
    final manual = await _gate.manualUnlocks(widget.child.id);
    final auto = await _gate.autoUnlocks(widget.child.id);
    if (!mounted) return;
    setState(() {
      _letters = letters;
      _mastered
        ..clear()
        ..addAll(
          progress.entries
              .where((e) => e.value.status == 'sicher')
              .map((e) => e.key),
        );
      _masteredNumbers
        ..clear()
        ..addAll(
          numberProgress.entries
              .where((e) => e.value.status == 'sicher')
              .map((e) => e.key),
        );
      _manualUnlocks = manual;
      _autoUnlocks = auto;
      _loading = false;
    });
  }

  Future<void> _toggleSection(String key, bool value) async {
    final next = {..._manualUnlocks};
    if (value) {
      next.add(key);
    } else {
      next.remove(key);
    }
    setState(() => _manualUnlocks = next);
    await _gate.setManualUnlock(widget.child.id, key, value);
  }

  Widget _sectionGroup(String title, LearningTrack track) {
    final sections = unlockableSections(track).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(title,
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ),
        for (final s in sections)
          _sectionSwitch(s),
      ],
    );
  }

  Widget _sectionSwitch(LearningSection s) {
    // Durch Übung freigeschaltete Bereiche kann man nicht wieder sperren.
    final earned = _autoUnlocks.contains(s.key);
    final on = earned || _manualUnlocks.contains(s.key);
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(s.label),
      subtitle: earned ? const Text('durch Übung freigeschaltet') : null,
      value: on,
      onChanged: earned ? null : (v) => _toggleSection(s.key, v),
    );
  }

  Future<void> _toggle(Grapheme g, bool value) async {
    setState(() {
      value ? _mastered.add(g.id) : _mastered.remove(g.id);
    });
    await _reading.setMastered(
      childId: widget.child.id,
      graphemeId: g.id,
      mastered: value,
    );
    // Automatische Freischaltungen koennen sich dadurch geaendert haben.
    final auto = await _gate.autoUnlocks(widget.child.id);
    if (!mounted) return;
    setState(() => _autoUnlocks = auto);
  }

  Future<void> _toggleNumber(int n, bool value) async {
    setState(() {
      value ? _masteredNumbers.add(n) : _masteredNumbers.remove(n);
    });
    await _numbers.setMastered(
      childId: widget.child.id,
      value: n,
      mastered: value,
    );
    final auto = await _gate.autoUnlocks(widget.child.id);
    if (!mounted) return;
    setState(() => _autoUnlocks = auto);
  }

  Future<void> _saveName() async {
    final name = _name.text.trim();
    if (name.isEmpty) return;
    await _childRepo.rename(widget.child.id, name);
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Name gespeichert.')));
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('${widget.child.name} löschen?'),
        content: const Text('Der gesamte Fortschritt dieses Kindes geht '
            'verloren. Das lässt sich nicht rückgängig machen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade400),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Löschen'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await _childRepo.delete(widget.child.id);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.child.name)),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Name
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(labelText: 'Name'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      FilledButton(
                        onPressed: _saveName,
                        child: const Text('Speichern'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Beherrschte Buchstaben',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  const Text(
                    'Angehakte Laute gelten als „sicher".',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final g in _letters)
                        FilterChip(
                          label: Text(g.symbol,
                              style: const TextStyle(fontSize: 20)),
                          selected: _mastered.contains(g.id),
                          onSelected: (v) => _toggle(g, v),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Beherrschte Zahlen',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  const Text(
                    'Angehakte Zahlen gelten als „sicher".',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var n = 1; n <= NumberRepository.maxNumber; n++)
                        FilterChip(
                          label: Text('$n',
                              style: const TextStyle(fontSize: 20)),
                          selected: _masteredNumbers.contains(n),
                          onSelected: (v) => _toggleNumber(n, v),
                        ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text('Bereiche freischalten',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  const Text(
                    'Gesperrte Bereiche gehen von selbst auf, sobald die '
                    'Grundlagen sitzen. Hier kannst du sie früher öffnen.',
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 8),
                  _sectionGroup('Lesen', LearningTrack.lesen),
                  const SizedBox(height: 8),
                  _sectionGroup('Rechnen', LearningTrack.rechnen),
                  const SizedBox(height: 32),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade400,
                    ),
                    onPressed: _delete,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Kind löschen'),
                  ),
                ],
              ),
      ),
    );
  }
}
