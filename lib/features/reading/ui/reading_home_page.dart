import 'package:flutter/material.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/responsive.dart';
import '../../../core/theme/tile_style.dart';
import '../../../core/widgets/adaptive_home_layout.dart';
import '../../../core/widgets/locked_hint.dart';
import '../../../core/widgets/menu_icon.dart';
import '../../../core/widgets/menu_tile.dart';
import '../../../data/db/database.dart';
import '../../../data/repositories/fund_repository.dart';
import '../../../data/repositories/gate_repository.dart';
import '../../../data/repositories/reading_repository.dart';
import '../../guided/guided_session_page.dart';
import '../../guided/lesson_widgets.dart';
import '../../hunt/fundstuecke_page.dart';
import '../../learning/learning_sections.dart';
import '../../name/my_name_page.dart';
import '../../writing/ui/writing_page.dart';
import 'combinations_page.dart';
import 'letter_match_page.dart';
import 'reading_page.dart';
import 'sentences_page.dart';
import 'word_building_page.dart';

/// Auswahl der drei Lese-Phasen. Fortgeschrittene Phasen sind gesperrt, bis die
/// Grundlagen sitzen (oder die Eltern sie freigeschaltet haben).
class ReadingHomePage extends StatefulWidget {
  const ReadingHomePage({super.key, required this.child});

  final Child child;

  @override
  State<ReadingHomePage> createState() => _ReadingHomePageState();
}

class _ReadingHomePageState extends State<ReadingHomePage> {
  final _gate = getIt<GateRepository>();
  Set<String>? _unlocked;
  int _nameTick = 0; // erzwingt Neuladen des „Mein Name"-Banners nach Lektionen

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final unlocked = await _gate.unlockedFor(widget.child.id);
    if (!mounted) return;
    setState(() {
      _unlocked = unlocked;
      _nameTick++;
    });
  }

  void _openOrHint(String key, Widget page) {
    if (!(_unlocked ?? const {}).contains(key)) {
      showLockedHint(context, lockedHintFor(key));
      return;
    }
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => page)).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    final unlocked = _unlocked;
    final Widget content;
    if (unlocked == null) {
      content = const Center(child: CircularProgressIndicator());
    } else {
      final compact = context.isCompact;
      final lesson = GuidedLessonCard(
        iconId: 'lese_lektion',
        subtitle: 'Den nächsten Laut gemeinsam einführen',
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(
              builder: (_) => GuidedSessionPage(child: widget.child),
            ))
            .then((_) => _load()),
      );
      final topBanners = <Widget>[
        _MyNameBanner(key: ValueKey(_nameTick), child: widget.child),
        _FundstueckeBanner(
            key: ValueKey('fund_$_nameTick'), child: widget.child),
      ];
      final grid = GridView.count(
        // Handy (hoch): 2 große Kacheln nebeneinander; Tablet: 3.
        crossAxisCount: compact ? 2 : 3,
        mainAxisSpacing: compact ? 12 : 20,
        crossAxisSpacing: compact ? 12 : 20,
        children: [
                          MenuTile(
                            label: 'Buchstaben',
                            iconId: 'lese_buchstaben',
                            emoji: '🔤',
                            color: const Color(0xFFFFCC80),
                            subtitle: 'Laute lernen',
                            onTap: () => _openOrHint(
                              'lese_buchstaben',
                              ReadingPage(child: widget.child),
                            ),
                          ),
                          MenuTile(
                            label: 'Lautverbindungen',
                            iconId: 'lese_verbindungen',
                            emoji: '🔡',
                            color: const Color(0xFF90CAF9),
                            subtitle: 'ei · au · sch …',
                            locked: !unlocked.contains('lese_verbindungen'),
                            onTap: () => _openOrHint(
                              'lese_verbindungen',
                              CombinationsPage(child: widget.child),
                            ),
                          ),
                          MenuTile(
                            label: 'Sätze',
                            iconId: 'lese_saetze',
                            emoji: '📝',
                            color: const Color(0xFFA5D6A7),
                            subtitle: 'Wörter zusammen',
                            locked: !unlocked.contains('lese_saetze'),
                            onTap: () => _openOrHint(
                              'lese_saetze',
                              SentencesPage(child: widget.child),
                            ),
                          ),
                          MenuTile(
                            label: 'Schreiben',
                            iconId: 'lese_schreiben',
                            emoji: '✏️',
                            color: const Color(0xFFCE93D8),
                            subtitle: 'Nachfahren',
                            onTap: () => Navigator.of(context)
                                .push(MaterialPageRoute(
                                  builder: (_) =>
                                      WritingPage(child: widget.child),
                                ))
                                .then((_) => _load()),
                          ),
                          MenuTile(
                            label: 'Wörter bauen',
                            iconId: 'lese_bauen',
                            emoji: '🧩',
                            color: const Color(0xFF80CBC4),
                            subtitle: 'Laute legen',
                            onTap: () => Navigator.of(context)
                                .push(MaterialPageRoute(
                                  builder: (_) =>
                                      WordBuildingPage(child: widget.child),
                                ))
                                .then((_) => _load()),
                          ),
                          MenuTile(
                            label: 'Groß & klein',
                            iconId: 'lese_matching',
                            emoji: '🔠',
                            color: const Color(0xFFFFAB91),
                            subtitle: 'Passt zusammen',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    LetterMatchPage(child: widget.child),
                              ),
                            ),
                          ),
        ],
      );

      content = AdaptiveHomeLayout(
        sidebar: [lesson, const SizedBox(height: 10), ...topBanners],
        grid: grid,
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Lesen · ${widget.child.name}')),
      body: SafeArea(child: content),
    );
  }
}

/// „Meine Fundstücke": erscheint nur, wenn das Kind schon Fotos behalten hat.
/// Führt zur Galerie der bei der Laut-Jagd gesammelten Fotos.
class _FundstueckeBanner extends StatefulWidget {
  const _FundstueckeBanner({super.key, required this.child});
  final Child child;

  @override
  State<_FundstueckeBanner> createState() => _FundstueckeBannerState();
}

class _FundstueckeBannerState extends State<_FundstueckeBanner> {
  final _funds = getIt<FundRepository>();
  int _count = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await _funds.countForChild(widget.child.id);
    if (!mounted) return;
    setState(() => _count = c);
  }

  @override
  Widget build(BuildContext context) {
    if (_count == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        color: const Color(0xFFFFE0B2),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(
                  builder: (_) => FundstueckePage(child: widget.child)))
              .then((_) => _load()),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              children: [
                const Text('📸', style: TextStyle(fontSize: 34)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Meine Fundstücke',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      Text(
                        '$_count ${_count == 1 ? 'Foto' : 'Fotos'} von eurer '
                        'Laut-Schatzsuche',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Einstieg in die eltern-geführte Anlaut-Lektion – innerhalb des Lese-Bereichs.
/// Zugang zu „Mein Name": Countdown, bis alle Buchstaben des Namens sitzen –
/// danach eine Feier + Einstieg in die Namens-Aktivität. Sitzt im Lese-Bereich.
class _MyNameBanner extends StatefulWidget {
  const _MyNameBanner({super.key, required this.child});
  final Child child;

  @override
  State<_MyNameBanner> createState() => _MyNameBannerState();
}

class _MyNameBannerState extends State<_MyNameBanner> {
  final _reading = getIt<ReadingRepository>();
  ({int total, int mastered})? _p;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p =
        await _reading.nameLetterProgress(widget.child.id, widget.child.name);
    if (!mounted) return;
    setState(() => _p = p);
  }

  @override
  Widget build(BuildContext context) {
    final p = _p;
    if (p == null || p.total == 0) return const SizedBox.shrink();

    if (p.mastered >= p.total) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: DecoratedBox(
          decoration:
              TileStyle.surface(const Color(0xFFFFC24D), depth: 1.1),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => Navigator.of(context)
                  .push(MaterialPageRoute(
                      builder: (_) => MyNamePage(child: widget.child)))
                  .then((_) => _load()),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.60),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: const MenuIcon(
                          id: 'feier_konfetti', emoji: '🎉', size: 40),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Mein Name',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: TileStyle.ink)),
                          Text('Lies, bau und schreib ${widget.child.name}',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: TileStyle.ink.withValues(alpha: 0.62))),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded,
                        color: TileStyle.ink.withValues(alpha: 0.75)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final remaining = p.total - p.mastered;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration:
            TileStyle.surface(const Color(0xFFFFE0B2), depth: 0.7),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.60),
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const MenuIcon(id: 'feier_stern', emoji: '✨', size: 30),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Noch $remaining ${remaining == 1 ? 'Buchstabe' : 'Buchstaben'}'
                  ', bis du deinen Namen schreiben kannst!',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: TileStyle.ink),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
