import 'package:flutter/material.dart';

import '../theme/tile_style.dart';
import 'menu_icon.dart';

/// Einheitliche Auswahl-Kachel (Icon + Titel, optional Untertitel) fuer alle
/// Menue-/Auswahl-Bildschirme.
///
/// Moderner Look: sanfter Farbverlauf, Icon in einer hellen „Mulde", weicher
/// farbiger Schatten und ein dezenter Pfeil als Antipp-Hinweis. Gesperrte
/// Kacheln werden entsaettigt mit Schloss-Abzeichen gezeigt.
class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.iconId,
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.iconSize = 92,
    this.labelSize = 22,
    this.locked = false,
  });

  final String iconId;
  final String emoji;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;
  final double iconSize;
  final double labelSize;

  /// Gesperrt: gedimmt dargestellt mit Schloss-Abzeichen. `onTap` wird trotzdem
  /// ausgeloest (die aufrufende Seite zeigt dann einen Hinweis).
  final bool locked;

  @override
  Widget build(BuildContext context) {
    const ink = TileStyle.ink;
    final well = iconSize * 1.12;
    final content = Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon in heller „Mulde" – hebt die generierten Bilder gross hervor.
          Container(
            width: well,
            height: well,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(well * 0.30),
            ),
            alignment: Alignment.center,
            child: MenuIcon(id: iconId, emoji: emoji, size: iconSize * 0.98),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: labelSize,
              fontWeight: FontWeight.w800,
              color: ink,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: ink.withValues(alpha: 0.60),
              ),
            ),
          ],
        ],
      ),
    );

    return DecoratedBox(
      decoration: TileStyle.surface(color,
          locked: locked, radius: 28, depth: 1.2),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Stack(
            children: [
              Positioned.fill(
                child: locked ? Opacity(opacity: 0.75, child: content) : content,
              ),
              // Antipp-Hinweis unten rechts (nur freigeschaltet).
              if (!locked)
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: _AffordanceDot(ink: ink),
                ),
              if (locked)
                const Positioned(top: 12, right: 12, child: _LockBadge()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kleiner Pfeil-Kreis als „hier tippen"-Hinweis.
class _AffordanceDot extends StatelessWidget {
  const _AffordanceDot({required this.ink});
  final Color ink;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.arrow_forward_rounded,
          size: 18, color: ink.withValues(alpha: 0.75)),
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Icon(Icons.lock_rounded, size: 19, color: Color(0xFF6E5D48)),
    );
  }
}
