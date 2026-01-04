#!/bin/bash

# Test Coverage Script for Personal Tracker
# Generiert einen Test-Coverage-Report mit lcov

set -e

echo "📊 Starte Test-Coverage-Analyse..."

# Führe Tests mit Coverage aus
flutter test --coverage

# Prüfe ob lcov installiert ist
if ! command -v lcov &> /dev/null; then
    echo "⚠️  lcov ist nicht installiert."
    echo "Installation (Ubuntu/Debian): sudo apt-get install lcov"
    echo "Installation (macOS): brew install lcov"
    exit 1
fi

# Entferne generierte Dateien aus Coverage
echo "🧹 Bereinige Coverage-Daten..."
lcov --remove coverage/lcov.info \
    '**/*.g.dart' \
    '**/*.freezed.dart' \
    '**/generated/**' \
    '**/l10n/**' \
    '**/injection.config.dart' \
    -o coverage/lcov_filtered.info

# Generiere HTML-Report
echo "📄 Generiere HTML-Report..."
genhtml coverage/lcov_filtered.info -o coverage/html

echo "✅ Coverage-Report erfolgreich generiert!"
echo "📂 HTML-Report: coverage/html/index.html"
echo ""
echo "Öffne den Report mit:"
echo "  xdg-open coverage/html/index.html  # Linux"
echo "  open coverage/html/index.html      # macOS"
