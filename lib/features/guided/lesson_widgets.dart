import 'package:flutter/material.dart';

import '../../core/theme/tile_style.dart';
import '../../core/widgets/menu_icon.dart';

/// Geteilte Bausteine für geführte Eltern-Lektionen (Lesen & Rechnen).

/// Steuert einen wischbaren Schritt-Ablauf (Lektionen, Anlege-Assistent):
/// kapselt den PageController samt animiertem Springen.
class StepController {
  final PageController page = PageController();

  void goTo(int step) => page.animateToPage(
        step,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );

  void dispose() => page.dispose();
}

/// Fortschritts-Punkte + wischbare Seiten. Auf [noSwipeSteps] ist Wischen aus
/// (z. B. Zeichen-/Auswahl-/Abschluss-Schritte); dort führen die Knöpfe bzw.
/// `controller.goTo`. Jede Seite wird einheitlich gepolstert.
class StepPageView extends StatelessWidget {
  const StepPageView({
    super.key,
    required this.controller,
    required this.step,
    required this.pages,
    required this.onStepChanged,
    this.noSwipeSteps = const {},
  });

  final StepController controller;
  final int step;
  final List<Widget> pages;
  final ValueChanged<int> onStepChanged;
  final Set<int> noSwipeSteps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StepDots(current: step, total: pages.length),
        Expanded(
          child: PageView(
            controller: controller.page,
            physics: noSwipeSteps.contains(step)
                ? const NeverScrollableScrollPhysics()
                : null,
            onPageChanged: onStepChanged,
            children: [
              for (final p in pages)
                Padding(padding: const EdgeInsets.all(24), child: p),
            ],
          ),
        ),
      ],
    );
  }
}

/// Prominenter, klar als *Eltern*-Aktion gekennzeichneter Einstieg in die
/// geführte Lektion (bewusst kein Werbebanner-Streifen: eigene Karte mit
/// „Für Eltern"-Kennzeichnung, Symbol und echtem Start-Knopf).
class GuidedLessonCard extends StatelessWidget {
  const GuidedLessonCard({
    super.key,
    required this.iconId,
    required this.subtitle,
    required this.onTap,
  });

  final String iconId;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Warmer Korall-Verlauf – hebt die Eltern-Karte als besondere Kachel ab
    // und passt zum Look der Auswahl-Kacheln (heller Verlauf, dunkle Schrift).
    const ink = TileStyle.ink;

    return DecoratedBox(
      decoration: TileStyle.surface(const Color(0xFFF7A98A),
          radius: 28, depth: 1.2),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      alignment: Alignment.center,
                      child: MenuIcon(id: iconId, emoji: '🧝', size: 60),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('Für Eltern',
                                style: TextStyle(
                                    color: scheme.onPrimary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700)),
                          ),
                          const SizedBox(height: 6),
                          const Text('Gemeinsame Lektion',
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: ink)),
                          const SizedBox(height: 2),
                          Text(subtitle,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: ink.withValues(alpha: 0.62))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Zusammen starten'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Große, gerahmte Karte für den zentralen Glyph einer Lektion – Buchstabe
/// ODER Ziffer, damit beide Lektionen denselben Look haben und gut lesbar sind.
class LessonGlyphCard extends StatelessWidget {
  const LessonGlyphCard(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 200,
        height: 200,
        alignment: Alignment.center,
        decoration: TileStyle.surface(const Color(0xFFFFCC80), radius: 28),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 130,
                  fontWeight: FontWeight.w800,
                  color: TileStyle.ink),
            ),
          ),
        ),
      ),
    );
  }
}

/// Antippbare Auswahl-Kachel im „Zeig mir"-Schritt (Buchstabe oder Zahl).
class LessonOptionTile extends StatelessWidget {
  const LessonOptionTile({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: 96,
        height: 96,
        alignment: Alignment.center,
        decoration: TileStyle.surface(const Color(0xFF90CAF9),
            radius: 22, depth: 0.7),
        child: Text(text,
            style: const TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: TileStyle.ink)),
      ),
    );
  }
}

/// Kleine Bestätigung im Schreib-Schritt, wenn das Nachfahren angenommen wurde.
class LessonWroteBadge extends StatelessWidget {
  const LessonWroteBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          MenuIcon(id: 'feier_stern', emoji: '🌟', size: 28),
          SizedBox(width: 8),
          Text('Schön geschrieben!',
              style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

/// Anweisungstext an die Eltern (Titel + Erklärung).
class LessonInstruction extends StatelessWidget {
  const LessonInstruction(this.title, this.body, {super.key});
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        Text(body, style: const TextStyle(fontSize: 17)),
      ],
    );
  }
}

/// Coaching-Tipp mit **fett**-Auszeichnung (einfacher Markdown-Ersatz).
class LessonTip extends StatelessWidget {
  const LessonTip(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final spans = <TextSpan>[];
    var bold = false;
    for (final part in text.split('**')) {
      spans.add(TextSpan(
        text: part,
        style: bold ? const TextStyle(fontWeight: FontWeight.w700) : null,
      ));
      bold = !bold;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                children: spans,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rahmen für einen Schritt: Inhalt oben, Aktions-Knöpfe unten.
class StepScaffold extends StatelessWidget {
  const StepScaffold({
    super.key,
    required this.content,
    this.primaryLabel,
    this.onPrimary,
    this.onBack,
  });

  final Widget content;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    // Auf breiten Tablets mittig und begrenzt – passt zum Rest der App.
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            Expanded(child: content),
            const SizedBox(height: 12),
            Row(
              children: [
                if (onBack != null)
                  TextButton(onPressed: onBack, child: const Text('Zurück')),
                const Spacer(),
                if (primaryLabel != null)
                  FilledButton(
                      onPressed: onPrimary, child: Text(primaryLabel!)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Fortschritts-Punkte über den Lektions-Schritten.
class StepDots extends StatelessWidget {
  const StepDots({super.key, required this.current, required this.total});
  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    final active = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 0; i < total; i++)
            Container(
              width: 9,
              height: 9,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i <= current ? active : Colors.black26,
              ),
            ),
        ],
      ),
    );
  }
}
