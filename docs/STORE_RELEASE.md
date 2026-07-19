# Release & Store-Veröffentlichung – Lernwichtel

Dieses Dokument beschreibt den kompletten Weg der App in **Google Play** und den
**Apple App Store** – vom Commit bis zum Build in der Testspur. Der Release ist
über **semantic-release** und **GitHub Actions** automatisiert; die Store-Konten
müssen einmalig eingerichtet werden.

---

## 1. Wie der automatische Release funktioniert

```
 fe/… ──PR──▶ develop ──PR──▶ main ──push──▶ [GitHub Action „Release"]
                                              │
                                              ├─ semantic-release
                                              │    • Version aus Commits ableiten (SemVer)
                                              │    • pubspec.yaml bumpen (+Build-Nr.)
                                              │    • CHANGELOG.md schreiben
                                              │    • Git-Tag + GitHub-Release
                                              ├─ Merge zurück nach develop
                                              ├─ Deploy Android  ▶ Google Play (internal)
                                              └─ Deploy iOS      ▶ TestFlight
```

- **Ausgelöst** wird alles durch einen **Push auf `main`** (üblich: PR von
  `develop` nach `main` mergen).
- Die nächste Versionsnummer kommt aus den **Conventional Commits** seit dem
  letzten Release (siehe Abschnitt 6).
- Android/iOS-Version werden **nicht** separat gepflegt – beide leiten sich aus
  `pubspec.yaml` ab (`flutter.versionCode/Name` bzw. `$(FLUTTER_BUILD_*)`).
- Deployed wird in die **Testspuren** (Play „internal" + TestFlight). Die
  Freigabe in die **Produktion** bleibt ein bewusster manueller Schritt in den
  Konsolen.

### Workflows

| Datei | Trigger | Zweck |
|---|---|---|
| `.github/workflows/build_and_test.yaml` | PR auf `develop`/`main` | `flutter analyze` + `flutter test` + Android-Build-Check |
| `.github/workflows/release.yaml` | Push auf `main` | semantic-release + Deploy in beide Testspuren |
| `.github/workflows/deploy-android.yaml` | manuell **oder** aus Release | App Bundle bauen, signieren, zu Play hochladen |
| `.github/workflows/deploy-ios.yaml` | manuell **oder** aus Release | IPA bauen (match), zu TestFlight hochladen |

> Flutter-Version in allen Workflows: **3.41.7** (identisch zur lokalen
> `.fvmrc`). Bei einem Flutter-Upgrade an allen vier Stellen anpassen.

---

## 2. Einmalige Voraussetzungen (Überblick)

1. GitHub-Repo mit den Branches `main` und `develop`.
2. Ein **Personal Access Token** (PAT) als Secret `GH_PAT` (für Push durch
   semantic-release trotz Branch-Schutz + für das Merge-back nach develop).
3. **Google Play**: App anlegen, Service-Account-JSON, Upload-Keystore.
4. **Apple**: App-Datensatz (ist bereits angelegt ✅), App-Store-Connect-API-Key,
   `match`-Zertifikate-Repo.
5. Alle Secrets/Variablen in GitHub hinterlegen (Abschnitt 5).

---

## 3. Google Play einrichten (aktuell noch „nackig")

1. **Play Console → App erstellen**
   - Name „Lernwichtel", App (nicht Spiel), kostenlos.
   - Package-Name muss **`app.lernwichtel`** sein.
2. **Store-Eintrag & Pflichtangaben** ausfüllen (Texte in `store/store-listing.md`):
   Kurz-/Vollbeschreibung, Icon (512²), Feature-Grafik (1024×500),
   mind. 2 Screenshots, Kategorie „Bildung", Inhaltsbewertung (Fragebogen),
   Datensicherheit („keine Daten erfasst"), Zielgruppe, Datenschutzerklärung-URL.
3. **Upload-Keystore erzeugen** (lokal, einmalig – gut sichern!):
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks \
     -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
   Daraus für GitHub-Secrets:
   ```bash
   base64 -i upload-keystore.jks | pbcopy   # -> Secret ANDROID_SIGNING_KEY
   ```
   - `KEY_ALIAS` = `upload`
   - `KEY_PASSWORD` / `STORE_PASSWORD` = die vergebenen Passwörter
   - (Der Store-Pfad `keystore/upload-keystore.jks` ist in der Pipeline fest
     verdrahtet – kein Secret nötig.)
   > Empfohlen: In der Play Console **Play App Signing** aktivieren – dann ist
   > obiger Keystore nur der *Upload*-Key.
4. **Service-Account für die API** (für Fastlane `supply`):
   - Play Console → Einstellungen → **API-Zugriff** → Google-Cloud-Projekt
     verknüpfen → Service-Account erstellen → JSON-Key herunterladen.
   - Im Play Console dem Service-Account **Release-Rechte** geben.
   - `base64 -i service-account.json | pbcopy` → Secret `PLAY_STORE_JSON_KEY`.
5. **Erster Upload:** Google verlangt für eine neue App i. d. R. das **erste
   App Bundle manuell** (Play Console → Test → Interner Test → Release erstellen,
   `app-release.aab` hochladen). Danach übernimmt der Workflow alle weiteren
   Uploads automatisch.
   - Ein signiertes Bundle lokal erzeugen: `fvm flutter build appbundle --release`
     (mit lokal vorhandener `android/key.properties`).

---

## 4. Apple App Store einrichten

Der App-Datensatz in App Store Connect ist bereits angelegt (Bundle-ID
`app.lernwichtel`). Noch nötig:

1. **App-Store-Connect-API-Key** (App Store Connect → Benutzer und Zugriff →
   Integrationen → Team-Keys → „+"). Rolle „App Manager" genügt.
   - `.p8`-Datei laden, dann:
     - `APP_STORE_CONNECT_KEY_ID` = die Key-ID
     - `APP_STORE_CONNECT_ISSUER_ID` = die Issuer-ID (oben auf der Seite)
     - `APP_STORE_CONNECT_KEY_CONTENT` = `base64 -i AuthKey_XXXX.p8 | pbcopy`
2. **`match`-Zertifikate-Repo** (verschlüsselter Git-Store für Zertifikate/Profile):
   - Vorhandenes Org-Repo `VonRehbergConsulting/ios-certificates` nutzen **oder**
     ein privates Repo anlegen.
   - **Zugriff per SSH-Deploy-Key:** `MATCH_GIT_URL` als **SSH-URL**
     (`git@github.com:VonRehbergConsulting/ios-certificates.git`) und den
     privaten Deploy-Key als `MATCH_GIT_PRIVATE_KEY` hinterlegen (die CI richtet
     den Key ein). Der Deploy-Key braucht Lesezugriff aufs Repo.
   - `MATCH_PASSWORD` = Passphrase zum Ver-/Entschlüsseln des Stores.
   - Zertifikate/Profile **einmalig lokal erzeugen** (schreibt in das match-Repo):
     ```bash
     cd ios && bundle install
     APP_STORE_CONNECT_KEY_ID=… APP_STORE_CONNECT_ISSUER_ID=… \
     APP_STORE_CONNECT_KEY_CONTENT=… MATCH_PASSWORD=… \
     MATCH_GIT_URL=… bundle exec fastlane renew_certs
     ```
     Danach läuft der CI-Deploy mit `MATCH_READONLY=true`.
3. **Team-IDs prüfen** (in `ios/fastlane/Appfile`/`Matchfile` als Fallback
   hinterlegt – bitte für dieses Konto verifizieren):
   - `TEAM_ID` (Developer Portal), `ITC_TEAM_ID` (App Store Connect), `APPLE_ID`.
4. In App Store Connect eine **TestFlight**-Test­gruppe einrichten, damit die
   hochgeladenen Builds testbar sind.

---

## 5. Benötigte GitHub-Secrets & -Variablen

**Repository → Settings → Secrets and variables → Actions.**

### Secrets – allgemein
| Name | Inhalt |
|---|---|
| `GH_PAT` | Personal Access Token (repo-Scope) für semantic-release + Merge-back |

### Secrets – Android
| Name | Inhalt |
|---|---|
| `PLAY_STORE_JSON_KEY` | Play-Service-Account-JSON als Base64 |
| `ANDROID_SIGNING_KEY` | Upload-Keystore als Base64 |
| `KEY_ALIAS` | Alias (z. B. `upload`) |
| `KEY_PASSWORD` | Key-Passwort |
| `STORE_PASSWORD` | Keystore-Passwort |

> ⚠️ Für den **signierten** AAB werden die vier Keystore-Secrets (`ANDROID_SIGNING_KEY`,
> `KEY_ALIAS`, `KEY_PASSWORD`, `STORE_PASSWORD`) benötigt.
> `PLAY_STORE_JSON_KEY` **allein lädt nur hoch, signiert aber nicht.**
> (Der Store-Pfad `keystore/upload-keystore.jks` ist fest verdrahtet, kein Secret.)

### Secrets – iOS
| Name | Inhalt |
|---|---|
| `APP_STORE_CONNECT_KEY_ID` | API-Key-ID |
| `APP_STORE_CONNECT_ISSUER_ID` | API-Issuer-ID |
| `APP_STORE_CONNECT_KEY_CONTENT` | `.p8`-Inhalt als Base64 |
| `MATCH_PASSWORD` | Passphrase des match-Stores |
| `MATCH_GIT_URL` | SSH-URL des Zertifikate-Repos (`git@github.com:…`) |
| `MATCH_GIT_PRIVATE_KEY` | privater SSH-Deploy-Key mit Zugriff aufs Zertifikate-Repo |
| `IOS_APP_IDENTIFIER` | `app.lernwichtel` |
| `TEAM_ID` | Developer-Portal-Team-ID |
| `ITC_TEAM_ID` | App-Store-Connect-Team-ID |
| `APPLE_ID` | Apple-Login der Deploy-Identität |
| `KEYCHAIN_NAME` | (optional) z. B. `fastlane_keychain` |
| `KEYCHAIN_PASSWORD` | (optional) temporäres Keychain-Passwort |

### Variables
| Name | Wert |
|---|---|
| `MATCH_READONLY` | `true` (CI erzeugt keine neuen Zertifikate) |

---

## 6. Commits & Versionierung (Conventional Commits)

semantic-release bestimmt die neue Version aus den Commit-Präfixen:

| Präfix | Wirkung | Beispiel |
|---|---|---|
| `fix:` | Patch (0.0.**x**) | `fix: Absturz beim Foto-Speichern behoben` |
| `feat:` | Minor (0.**x**.0) | `feat: Foto-Fundstücke pro Laut` |
| `feat!:` / `BREAKING CHANGE:` | Major (**x**.0.0) | `feat!: neues Datenmodell` |
| `chore:`, `docs:`, `refactor:`, `test:` … | kein Release | `docs: Store-Anleitung` |

Die **Build-Nummer** (`+N` in der Version) wird bei jedem Release automatisch
um 1 erhöht ([`.github/scripts/update-version.sh`](../.github/scripts/update-version.sh)).

---

## 7. Einen Release auslösen

1. Feature-Branches → PR nach `develop` (CI läuft: analyze/test/build).
2. Wenn `develop` release-reif ist: **PR `develop` → `main`** und mergen.
3. Der Push auf `main` startet „Release": Version, Changelog, Tag, GitHub-Release
   und der automatische Upload in **Play internal** + **TestFlight**.
4. **Produktion:** In Play Console bzw. App Store Connect den Build aus der
   Testspur zur Produktion **manuell** freigeben (bewusste Entscheidung).

### Deploy manuell nachziehen
GitHub → **Actions** → „Deploy Android" bzw. „Deploy iOS" → **Run workflow**
(nutzt jeweils den aktuellen Stand von `main`).

---

## 8. Lokal bauen (zum Testen)

```bash
# Android (braucht android/key.properties + Keystore lokal)
fvm flutter build appbundle --release

# iOS (Zertifikate via match)
cd ios && bundle install && bundle exec fastlane build_and_deploy skip_deploy:true
```

---

## 9. Troubleshooting

- **Release-Job pusht nicht / 403:** `PAT_TOKEN` fehlt/abgelaufen oder hat keinen
  `repo`-Scope; bei geschützten Branches muss der Token pushen dürfen.
- **Kein neuer Release, obwohl gemergt:** Es gab nur Commits ohne `feat:`/`fix:`
  (z. B. nur `chore:`). Das ist gewollt.
- **Play „APK/AAB nicht signiert" / Upload abgelehnt:** `key.properties`/Keystore-
  Secrets prüfen; für die *allererste* App zuerst manuell hochladen (Abschnitt 3.5).
- **iOS „no matching provisioning profile":** `match` wurde noch nicht befüllt
  (`renew_certs` lokal ausführen) oder `MATCH_*`-Secrets/Team-IDs stimmen nicht.
- **`npm install`-Fehler im Release-Job:** Node-Version 20 nötig – ist im Workflow
  gesetzt.
