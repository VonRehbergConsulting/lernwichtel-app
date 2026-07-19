import 'package:flutter/material.dart';

import '../../core/app_info.dart';
import '../../core/widgets/menu_icon.dart';

/// Einmaliger Willkommens-Screen beim ersten Start: kurz, warm, ehrlich –
/// beschreibt die Motivation der App und ihre Werte.
class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key, required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const MenuIcon(id: 'lernwichtel', emoji: '🧝', size: 140),
                  const SizedBox(height: 16),
                  Text(
                    'Willkommen bei $kAppName!',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 30, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 20),
                  const _Line(
                    'Hier bringt ihr eurem Kind Lesen, Schreiben und erste '
                    'Zahlen bei – nach Montessori-Art: mit den Lauten, in Ruhe '
                    'und gemeinsam.',
                  ),
                  const _Line(
                    'Die App ist kein Bildschirm-Babysitter. Sie begleitet '
                    'dich als Elternteil – und schickt euch immer wieder raus '
                    'in die echte Welt.',
                  ),
                  const _Line(
                    'Kostenlos, quelloffen und werbefrei: kein Tracking, keine '
                    'In-App-Käufe, alles bleibt auf dem Gerät.',
                  ),
                  const _Line(
                    'Von einer Community für alle Kinder gemacht – erweiterbar '
                    'und für jeden zugänglich.',
                  ),
                  const SizedBox(height: 28),
                  FilledButton(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 36, vertical: 18),
                      textStyle: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    child: const Text("Los geht's"),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Im Tempo deines Kindes.',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 17, height: 1.35),
      ),
    );
  }
}
