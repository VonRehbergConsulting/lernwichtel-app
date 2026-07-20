import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/tile_style.dart';
import 'menu_icon.dart';

/// Einheitliche Auswahl-Kachel (Icon + Titel, optional Untertitel) fuer alle
/// Menue-/Auswahl-Bildschirme.
///
/// Zell-adaptiv: Icon-„Mulde", Schrift und Abstaende richten sich nach der
/// Groesse der Grid-Zelle (via [LayoutBuilder]) – so passt die Kachel auf iPad
/// wie auf kleinen Phones, ohne globales Herunterskalieren. Moderner Look:
/// sanfter Verlauf, Icon in heller Mulde, weicher farbiger Schatten, dezenter
/// Pfeil als Antipp-Hinweis; gesperrte Kacheln entsaettigt mit Schloss.
class MenuTile extends StatelessWidget {
  const MenuTile({
    super.key,
    required this.iconId,
    required this.emoji,
    required this.label,
    required this.color,
    required this.onTap,
    this.subtitle,
    this.locked = false,
  });

  final String iconId;
  final String emoji;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  /// Gesperrt: gedimmt dargestellt mit Schloss-Abzeichen. `onTap` wird trotzdem
  /// ausgeloest (die aufrufende Seite zeigt dann einen Hinweis).
  final bool locked;

  @override
  Widget build(BuildContext context) {
    const ink = TileStyle.ink;

    return DecoratedBox(
      decoration: TileStyle.surface(color, locked: locked, radius: 28, depth: 1.2),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth.isFinite ? c.maxWidth : 200.0;
              final h = c.maxHeight.isFinite ? c.maxHeight : 200.0;
              // Breit-flache Zelle (z. B. eine volle Zeile im Hochformat) ->
              // waagerechte Darstellung: Icon links, Text rechts.
              final horizontal = w > h * 1.9;

              final content = horizontal
                  ? _rowContent(ink, h)
                  : _columnContent(ink, min(w, h));

              // Bezugsgroesse fuer die Ecken-Abzeichen.
              final s = horizontal ? h : min(w, h);
              final pad = (s * (horizontal ? 0.16 : 0.09)).clamp(10.0, 18.0);
              final dot = (s * (horizontal ? 0.34 : 0.15)).clamp(24.0, 34.0);

              return Stack(
                children: [
                  Positioned.fill(
                    child: locked ? Opacity(opacity: 0.75, child: content) : content,
                  ),
                  if (!locked)
                    Positioned(
                      right: pad * 0.7,
                      bottom: pad * 0.7,
                      child: _AffordanceDot(ink: ink, size: dot),
                    ),
                  if (locked)
                    Positioned(
                      top: pad * 0.7,
                      right: pad * 0.7,
                      child: _LockBadge(size: dot),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Senkrechte Darstellung (Icon oben, Text darunter) – für quadratische
  /// Grid-Zellen. [s] = kleinere Zellkante.
  Widget _columnContent(Color ink, double s) {
    final well = s * 0.50;
    final labelSize = (s * 0.135).clamp(13.0, 24.0);
    final subSize = (s * 0.082).clamp(10.5, 14.0);
    final pad = (s * 0.09).clamp(10.0, 18.0);
    final gap = (s * 0.05).clamp(6.0, 12.0);

    return Padding(
      padding: EdgeInsets.all(pad),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: well,
            height: well,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(well * 0.30),
            ),
            alignment: Alignment.center,
            child: MenuIcon(id: iconId, emoji: emoji, size: well * 0.86),
          ),
          SizedBox(height: gap),
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
            SizedBox(height: gap * 0.25),
            Text(
              subtitle!,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: subSize,
                fontWeight: FontWeight.w600,
                color: ink.withValues(alpha: 0.60),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Waagerechte Darstellung (Icon links, Text rechts) – für breit-flache
  /// Zeilen-Zellen im Hochformat. [h] = Zellhöhe.
  Widget _rowContent(Color ink, double h) {
    final well = (h * 0.62).clamp(40.0, 96.0);
    final labelSize = (h * 0.24).clamp(15.0, 24.0);
    final subSize = (h * 0.15).clamp(11.0, 15.0);
    final pad = (h * 0.16).clamp(10.0, 20.0);
    final gap = (h * 0.14).clamp(10.0, 18.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, pad, pad + well * 0.4, pad),
      child: Row(
        children: [
          Container(
            width: well,
            height: well,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(well * 0.30),
            ),
            alignment: Alignment.center,
            child: MenuIcon(id: iconId, emoji: emoji, size: well * 0.72),
          ),
          SizedBox(width: gap),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: labelSize,
                    fontWeight: FontWeight.w800,
                    color: ink,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: subSize,
                      fontWeight: FontWeight.w600,
                      color: ink.withValues(alpha: 0.60),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Kleiner Pfeil-Kreis als „hier tippen"-Hinweis.
class _AffordanceDot extends StatelessWidget {
  const _AffordanceDot({required this.ink, required this.size});
  final Color ink;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(Icons.arrow_forward_rounded,
          size: size * 0.6, color: ink.withValues(alpha: 0.75)),
    );
  }
}

class _LockBadge extends StatelessWidget {
  const _LockBadge({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
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
      child: Icon(Icons.lock_rounded,
          size: size * 0.62, color: const Color(0xFF6E5D48)),
    );
  }
}
