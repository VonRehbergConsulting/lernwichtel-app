import 'package:flutter/material.dart';

import 'menu_icon.dart';

/// Kindgerechter Hinweis, wenn ein noch gesperrter Bereich angetippt wird.
/// Zeigt ein freundliches Schloss-Icon und den Grund.
void showLockedHint(BuildContext context, String hint) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MenuIcon(id: 'hinweis_schloss', emoji: '🔒', size: 60),
          const SizedBox(height: 12),
          Text(
            hint.isEmpty ? 'Das ist noch nicht offen.' : hint,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Alles klar'),
        ),
      ],
    ),
  );
}
