import 'dart:math';

import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

/// Eltern-Schutz: authentifiziert per Geraetesperre (Face ID / Touch ID /
/// Code). Ist keine Geraetesperre eingerichtet oder schlaegt sie fehl, wird
/// eine kleine Rechenaufgabe gestellt. Gibt true zurueck, wenn der Zugang
/// gewaehrt wird.
Future<bool> confirmParent(BuildContext context) async {
  final auth = LocalAuthentication();
  try {
    if (await auth.isDeviceSupported()) {
      final ok = await auth.authenticate(
        localizedReason: 'Bitte bestätige, dass du ein Elternteil bist.',
        persistAcrossBackgrounding: true,
      );
      if (ok) return true;
    }
  } catch (_) {
    // Faellt auf die Rechenaufgabe zurueck.
  }
  if (!context.mounted) return false;
  return _mathGate(context);
}

Future<bool> _mathGate(BuildContext context) async {
  final rnd = Random();
  final a = 3 + rnd.nextInt(6); // 3..8
  final b = 4 + rnd.nextInt(6); // 4..9
  final controller = TextEditingController();

  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Nur für Eltern'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Löse zum Fortfahren:  $a + $b'),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Antwort'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Abbrechen'),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(ctx).pop(int.tryParse(controller.text.trim()) == a + b),
          child: const Text('Weiter'),
        ),
      ],
    ),
  );
  return ok ?? false;
}
