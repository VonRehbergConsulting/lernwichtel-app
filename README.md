# Lern-App (education_app)

Kindgerechte, **komplett offline** laufende Lern-App für Tablets: spielerisches
Lesen- und Rechnenlernen für mehrere Kinder, mit lokal gespeichertem Fortschritt
pro Kind. Keine Cloud, keine Musik, wenige Ablenkungen.

- **Technik:** Flutter + BLoC-Pattern, lokale SQLite-DB (Drift), Sprachausgabe
  via TTS + optionale eigene Laut-Aufnahmen.
- **Zielgerät:** Tablets (iPad/Android), Querformat.

---

## Schnellstart

Das Projekt ist auf eine feste Flutter-Version via **fvm** gepinnt
(`.fvmrc` → Flutter 3.41.7). Immer `fvm flutter …` / `fvm dart …` verwenden.

```bash
# Abhängigkeiten
fvm flutter pub get

# Generierten Code (Drift-DB) erzeugen – nach jeder Änderung an
# lib/data/db/database.dart nötig
fvm flutter pub run build_runner build --delete-conflicting-outputs

# Statische Analyse
fvm flutter analyze

# Auf verbundenem Gerät starten (Geräte-ID via `fvm flutter devices`)
fvm flutter run -d <device-id>
```

> **iOS-17-Deploy-Eigenheit:** Beim Start auf ein physisches iPad kann einmalig
> `CoreDeviceError error 3 / connection was invalidated` erscheinen. Das ist ein
> bekanntes, harmloses Zucken der iOS-17-Tooling-Verbindung – Flutter erholt
> sich meist selbst oder ein erneuter `flutter run` behebt es. iPad muss im
> **Entwicklermodus** und **entsperrt** sein. USB-Kabel ist stabiler als WLAN.

---

## Projektstruktur

```
lib/
  core/
    theme/       App-Theme (hell, farbenfroh, große Touch-Flächen)
    audio/       AudioService: Laut-Asset zuerst, sonst TTS-Fallback
    di/          get_it Service-Locator (setupServiceLocator)
    widgets/     FullscreenImage (Bild-Fallback-Kette)
    utils/       wortSlug() – MUSS identisch mit tool/-Skript sein
  data/
    db/          Drift-Datenbank (database.dart) + generiert database.g.dart
    repositories/ ChildRepository, ContentRepository, ReadingRepository
  features/
    profiles/    Kinder anlegen/wählen/löschen (bloc + ui)
    reading/     Lese-Modul (bloc + ui): Buchstaben · Lautverbindungen · Sätze
    math/        Rechen-Modul (noch leer – geplant)
    parent/      Eltern-Bereich (noch leer – ganz zum Schluss)
assets/
  content/lerninhalte.json   Seed-Inhalte (Buchstaben, Lautverbindungen, Sätze)
  content/bild_prompts.json  Vom Generator erzeugte Bild-Prompts (versioniert)
  audio/laute/               Laut-Aufnahmen <grapheme>.mp3 (optional)
  images/standard/           Generierte Comic-Standardbilder <slug>.png
tool/
  generate_standard_images.dart   Bild-Generator (Claude-Prompt → gpt-image-1)
```

---

## Datenmodell (Drift)

Kern-Tabellen in [lib/data/db/database.dart](lib/data/db/database.dart):

- **Children** – Kind-Profile.
- **Graphemes** – Buchstaben & Lautverbindungen (global), inkl. `merkhilfe`.
- **GraphemeProgress** – Lese-Fortschritt **pro Kind** (Leitner-Boxen).
- **Words / ImageAssets / WordEnabled** – Wörter, geteilte Bilder, Auswahl je Kind.
- **MathSkills / MathAttempts** – Rechen-Fortschritt (für das kommende Modul).

**Fortschritt** ist bewusst pro Kind an der `graphemeId` verankert.

---

## Inhalte pflegen

Alle Lerninhalte liegen in
[assets/content/lerninhalte.json](assets/content/lerninhalte.json):

- `buchstaben` – Laut, Typ (Dauerlaut/Vokal/Plosiv), Beispielwörter, Reihenfolge.
- `lautverbindungen` – z. B. ei, au, sch, sp, st …, mit `merkhilfe` (Kinderspruch)
  und Beispielwörtern.
- `saetze` – einfache Übungssätze in Schwierigkeitsstufen.

**Wichtig – nach inhaltlichen Änderungen:** In
[lib/data/repositories/content_repository.dart](lib/data/repositories/content_repository.dart)
die Konstante `_contentVersion` **hochzählen**. Beim nächsten App-Start werden
neue Grapheme/Merksätze/Wörter dann **nachgezogen** (Update statt Neuanlage) –
der Kind-Fortschritt bleibt erhalten.

Sätze werden direkt aus der JSON gelesen (keine DB, kein Fortschritt).

---

## Bild-Generator (Comic-Standardbilder)

Erzeugt reproduzierbar einheitliche, flache Kinder-Cartoon-Bilder je Wort.
Pro Wort gibt es einen Motiv-Prompt; ein fixer Stil-Baustein wird angehängt,
**OpenAI gpt-image-1** rendert das PNG.

Die Prompts für alle aktuellen Wörter liegen bereits fertig in
[assets/content/bild_prompts.json](assets/content/bild_prompts.json). Deshalb
braucht der Standardlauf **nur einen OpenAI-Key**. `ANTHROPIC_API_KEY` ist
**optional** und wird nur benötigt, wenn ein Wort **noch keinen** Prompt hat
(z. B. neu hinzugefügte Wörter) – dann schreibt Claude ihn automatisch.

Skript: [tool/generate_standard_images.dart](tool/generate_standard_images.dart)

```bash
# Aus dem Projektwurzelverzeichnis. Key steht im selben Befehl,
# da jede Shell frisch startet.

# 1) Testlauf (Stil prüfen)
OPENAI_API_KEY=sk-... \
  fvm dart run tool/generate_standard_images.dart --only=Apfel,Ball,Maus

# 2) Voller Lauf (überspringt vorhandene Bilder automatisch)
OPENAI_API_KEY=sk-... \
  fvm dart run tool/generate_standard_images.dart

# Neues Wort ohne Prompt? Dann zusätzlich einen echten Anthropic-API-Key
# (beginnt mit sk-ant-api...) mitgeben, damit Claude den Prompt schreibt:
# ANTHROPIC_API_KEY=sk-ant-api... OPENAI_API_KEY=sk-... fvm dart run ...
```

Optionen: `--quality=low|medium|high` (Standard `medium`), `--dry-run`
(nur Prompts), `--force` (auch vorhandene neu erzeugen), `--only=A,B`,
`--limit=N`.

**Eigenschaften:**
- **Inkrementell:** Wörter mit vorhandenem `assets/images/standard/<slug>.png`
  werden übersprungen. Später Liste erweitern → nur neue Wörter werden erzeugt.
- **Reproduzierbar:** Prompts liegen versioniert in `bild_prompts.json`.
- **Konsistenter Stil:** Der `_styleSuffix` im Skript wird an jeden Prompt
  angehängt. Diesen zu ändern = neuer Gesamtstil (dann `--force`).
- **Dateinamen:** `wortSlug()` in App und Skript **müssen identisch** bleiben
  (Umlaute → ae/oe/ue/ss, Kleinschreibung, nur a-z0-9, sonst `_`).

**Assets sind gebündelt:** Neu erzeugte Bilder erscheinen erst nach einem
**erneuten Build/Deploy** der App.

**gpt-image-1** kann eine einmalige Organisations-Verifizierung im
OpenAI-Dashboard voraussetzen (sonst 403).

### Menü-Icons

Eigene kleine Pipeline für die Menü-Kacheln (statt Emojis). Prompts liegen fest
in [assets/content/menu_prompts.json](assets/content/menu_prompts.json)
(Icon-ID → Prompt), gerendert nach `assets/images/menu/<id>.png`. Braucht nur
den OpenAI-Key.

```bash
OPENAI_API_KEY=sk-... fvm dart run tool/generate_menu_images.dart
```

Die Icon-IDs müssen mit denen in der UI übereinstimmen: `module_lesen`,
`module_rechnen`, `lese_buchstaben`, `lese_verbindungen`, `lese_saetze`,
`math_ziffern`, `math_zehner`, `math_addieren`, `math_subtrahieren`. Fehlt ein
Icon, zeigt die App automatisch das **Emoji als Fallback** (Widget
`MenuIcon`).

---

## Laute (Anlaut-Methode)

Kern der Lesedidaktik: Buchstaben werden als **Laut** gelernt, nicht als Name.
TTS spricht bei Einzelbuchstaben oft den Namen ("Em" statt "mmm") – deshalb
werden die Laute per Pipeline mit **espeak-ng** erzeugt und gebündelt. Über die
**Lautschrift (IPA)** wird der reine Laut exakt vorgegeben (deutsche Stimme).

Skript: [tool/generate_laute.dart](tool/generate_laute.dart) →
`assets/audio/laute/<key>.wav` (ein File je Graphem-Schlüssel).

```bash
brew install espeak-ng                       # einmalig
fvm dart run tool/generate_laute.dart        # erzeugt alle Laute
# Optionen: --force, --only=m,sch, --speed=150
```

Die IPA-Zuordnung steht als Tabelle `_phon` im Skript und ist mit
`espeak-ng -v de -q --ipa "<input>"` textuell prüfbar. Klingt ein Laut daneben,
einfach den Eintrag anpassen und mit `--force --only=<key>` neu erzeugen.

**Wiedergabe-Reihenfolge im `AudioService`:** eigene Aufnahme
(`App-Dokumente/laute/<key>.m4a`, für spätere Ersetzung einzelner Laute) →
generierter Laut (`assets/audio/laute/<key>.wav`) → TTS-Fallback. Ganze Wörter
und Sätze werden weiterhin per TTS vorgelesen.

---

## Tests

```bash
fvm flutter test
```

Abgedeckt (`test/`): adaptive Rechenlogik + Protokoll (`math_repository_test`),
Aufgaben-Generator/Bereiche & „keine 0 am Anfang" (`math_problem_test`),
Batch-Pool-Auswahl (`batch_pool_test`), Wort-/Verbindungs-Progression &
Freischaltung (`progression_repository_test`), ein Bloc-Flow
(`math_bloc_test`) und die String-Verträge zwischen App/JSON/Skripten
(`content_integrity_test`). Repository-/Bloc-Tests laufen gegen eine
In-Memory-SQLite-DB (`AppDatabase.forTesting(NativeDatabase.memory())`).

## Architektur-Notizen

- **Fehler:** `AppBlocObserver` loggt alle Bloc-Fehler; `main` fängt via
  `runZonedGuarded` + `FlutterError.onError` global. Ladefehler in den Modulen
  führen zu einem `error`-State → `ErrorView` mit „Nochmal".
- **Repositories:** `ReadingRepository` (Leitner-Fortschritt, Wort-/Bilddaten),
  `ProgressionRepository` (Batch-Progression + Freischalt-Zähler),
  `MathRepository` (adaptive Level), `ContentRepository` (Seed/Sätze),
  `ChildRepository`.
- **Wiederverwendung:** `buildBatchPool` (Wörter + Verbindungen), `MenuTile`
  (alle Auswahl-Kacheln), `MenuIcon`/`ErrorView`.

## Stand & nächste Schritte

**Fertig:**
- Profile (anlegen/wählen/löschen, lokal).
- Lese-Modul in 3 Phasen: Buchstaben · Lautverbindungen (mit Merksätzen) · Sätze.
- Bild-Pipeline (Generator + Fallback-Kette in der App).

**Offen / geplant:**
- **Rechen-Modul:** Ziffern → Zahlen bis 100 → Addieren/Subtrahieren, mit
  adaptiver Schwierigkeit pro Kind (Tabellen `MathSkills`/`MathAttempts` liegen
  schon vor).
- **Echte Laut-Aufnahmen** (ggf. Aufnahme-Funktion in der App).
- **Eltern-Bereich** (hinter Gate): Wörter auswählen, eigene Fotos hinterlegen,
  Buchstaben abhaken. Bewusst als Letztes.
- **Großbuchstaben** als späterer Umschalter pro Wort.
