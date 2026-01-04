# Personal Tracker - Makefile
# Sammlung häufig verwendeter Befehle für die Entwicklung

.PHONY: help get clean analyze format test build-runner watch run-web run-linux run-windows coverage

# Default target: Zeige Hilfe
help:
	@echo "Personal Tracker - Verfügbare Make-Targets:"
	@echo ""
	@echo "  make get          - Dependencies installieren"
	@echo "  make clean        - Build-Artefakte löschen"
	@echo "  make analyze      - Code-Analyse durchführen"
	@echo "  make format       - Code formatieren"
	@echo "  make test         - Tests ausführen"
	@echo "  make coverage     - Test-Coverage generieren"
	@echo "  make build-runner - Code-Generierung ausführen"
	@echo "  make watch        - Code-Generierung im Watch-Modus"
	@echo "  make run-web      - App im Browser starten"
	@echo "  make run-linux    - App auf Linux starten"
	@echo "  make run-windows  - App auf Windows starten"
	@echo ""

# Dependencies installieren
get:
	flutter pub get

# Build-Artefakte löschen
clean:
	flutter clean
	rm -rf build/
	rm -rf .dart_tool/

# Code-Analyse durchführen
analyze:
	flutter analyze

# Code formatieren
format:
	dart format lib/ test/

# Tests ausführen
test:
	flutter test

# Test-Coverage generieren
coverage:
	flutter test --coverage
	@echo "Coverage-Report generiert in coverage/lcov.info"
	@echo "Um HTML-Report zu generieren: genhtml coverage/lcov.info -o coverage/html"

# Code-Generierung (injectable, etc.)
build-runner:
	flutter pub run build_runner build --delete-conflicting-outputs

# Code-Generierung im Watch-Modus
watch:
	flutter pub run build_runner watch --delete-conflicting-outputs

# App starten (verschiedene Plattformen)
run-web:
	flutter run -d chrome

run-linux:
	flutter run -d linux

run-windows:
	flutter run -d windows

# Kompletter Check (vor Commit)
pre-commit: format analyze test
	@echo "✅ Pre-Commit Checks erfolgreich!"

# Alles neu aufbauen
rebuild: clean get build-runner
	@echo "✅ Projekt neu aufgebaut!"
