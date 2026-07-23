# Laute-Recorder

Kleiner lokaler Aufnahme-Helfer, um die Anlaut-Audios
(`assets/audio/laute/<key>.wav`) direkt im Browser aufzunehmen – am **Mac** oder
am **iPhone**. Die Seite zeigt Buchstabe, Sprech-Hinweis und Beispielwort;
**Start → sprechen → Stopp → Speichern** schreibt die Datei automatisch an die
richtige Stelle. Danach springt sie zum nächsten offenen Laut.

## Starten

```bash
fvm dart run tool/laute_recorder/serve.dart        # Port 8443
fvm dart run tool/laute_recorder/serve.dart 9000   # eigener Port
```

Der Server nennt beim Start die beiden URLs:

- **Am Mac:** `https://localhost:8443`
- **Am iPhone:** `https://<mac-ip>:8443` (gleiches WLAN)

## Warum HTTPS / die Zertifikatswarnung

Mikrofonzugriff im Browser braucht einen *secure context*. `localhost` gilt am
Mac automatisch als sicher – eine LAN-IP (iPhone) nicht. Deshalb läuft der Server
über HTTPS mit einem **selbstsignierten Zertifikat**, das beim ersten Start
einmalig via `openssl` erzeugt wird (liegt unter `.certs/`, ist gitignored).

Am iPhone einmal die Warnung bestätigen: **„Details einblenden" → „Diese Website
besuchen"**. Danach ist das Mikrofon freigegeben.

## Bedienung

| Taste | Aktion |
|---|---|
| `Leertaste` | Aufnehmen / Stopp |
| `P` | Anhören |
| `Enter` | Speichern |
| `←` / `→` | Blättern |

Tipps:

- Sprich den **Laut**, nicht den Buchstabennamen („mmm" statt „Em"). Der
  Sprech-Hinweis auf der Karte sagt, wie es klingen soll.
- Stille am Anfang/Ende wird automatisch grob abgeschnitten; sehr kurze
  Fehlklicks (< 150 ms) werden verworfen.
- Ausgabe ist **16-bit-Mono-WAV** in der Aufnahme-Samplerate – genau das Format,
  das die App aus dem gebündelten Ordner abspielt.
- Vorhandene Aufnahmen kannst du jederzeit überschreiben: Laut auswählen, neu
  aufnehmen, speichern.

Welche Datei zu welchem Laut gehört, steht in
[../../assets/audio/laute/README.md](../../assets/audio/laute/README.md). Die
Liste der Laute liest der Recorder direkt aus
`assets/content/lerninhalte.json` – sie bleibt also automatisch synchron.
