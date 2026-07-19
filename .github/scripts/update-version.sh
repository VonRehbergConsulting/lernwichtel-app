#!/usr/bin/env bash
#
# Setzt die von semantic-release ermittelte Version in die pubspec.yaml und
# erhoeht die Build-Nummer um 1. Android (versionCode/Name = flutter.*) und iOS
# (CFBundle* = $(FLUTTER_BUILD_*)) leiten ihre Werte automatisch aus der
# pubspec ab – deshalb muss nur diese eine Datei angefasst werden.
#
# Aufruf: bash .github/scripts/update-version.sh <version>   z. B. 1.2.0
set -euo pipefail

VERSION="$1"

# Aktuelle Build-Nummer (Teil nach dem "+") aus "version: X.Y.Z+N" lesen.
CURRENT_LINE="$(grep -E '^version:[[:space:]]*[0-9]+\.[0-9]+\.[0-9]+\+[0-9]+' pubspec.yaml)"
BUILD_NUMBER="${CURRENT_LINE##*+}"
NEW_BUILD_NUMBER="$((BUILD_NUMBER + 1))"

sed -i "s/^version:.*/version: ${VERSION}+${NEW_BUILD_NUMBER}/" pubspec.yaml

echo "Version aktualisiert auf ${VERSION}+${NEW_BUILD_NUMBER}"
