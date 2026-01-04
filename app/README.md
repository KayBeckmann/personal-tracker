# Personal Tracker - Flutter App

Modulare Multi-Plattform-App für Haushaltsbuch, Notizen, Aufgaben, Gewohnheiten, Journal und Zeiterfassung.

## Architektur

Das Projekt folgt **Clean Architecture** mit einem **Feature-First** Ansatz.
Siehe [ARCHITECTURE.md](ARCHITECTURE.md) für Details zur Projektstruktur.

## Voraussetzungen

- Flutter SDK >= 3.10.1
- Dart SDK >= 3.10.1

## Setup

### 1. Dependencies installieren

```bash
make get
# oder
flutter pub get
```

### 2. Code-Generierung ausführen

Für Dependency Injection wird Code generiert:

```bash
make build-runner
# oder
flutter pub run build_runner build --delete-conflicting-outputs
```

## Entwicklung

### App starten

**Web:**
```bash
make run-web
# oder
flutter run -d chrome
```

**Linux:**
```bash
make run-linux
# oder
flutter run -d linux
```

**Windows:**
```bash
make run-windows
# oder
flutter run -d windows
```

**Android/iOS:**
```bash
flutter run
```

### Code-Qualität

**Code analysieren:**
```bash
make analyze
# oder
flutter analyze
```

**Code formatieren:**
```bash
make format
# oder
dart format lib/ test/
```

**Tests ausführen:**
```bash
make test
# oder
flutter test
```

**Test-Coverage:**
```bash
make coverage
# oder
flutter test --coverage
```

### Code-Generierung im Watch-Modus

Während der Entwicklung kann build_runner im Watch-Modus laufen:

```bash
make watch
# oder
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Pre-Commit Checks

Vor einem Commit sollten folgende Checks durchlaufen:

```bash
make pre-commit
```

Dies führt aus:
1. Code-Formatierung
2. Code-Analyse
3. Tests

## Projekt-Struktur

```
lib/
├── core/                 # Gemeinsame Funktionalität
│   ├── di/              # Dependency Injection
│   ├── error/           # Error Handling
│   ├── navigation/      # Routing
│   ├── theme/           # Theming
│   ├── localization/    # i18n
│   └── utils/           # Utilities
├── features/            # Feature-Module
│   ├── settings/
│   ├── finance/         # Haushaltsbuch
│   ├── notes/           # Notizen
│   ├── tasks/           # Aufgaben
│   ├── habits/          # Gewohnheiten
│   ├── journal/         # Journal
│   ├── time_tracking/   # Zeiterfassung
│   └── dashboard/       # Dashboard
└── main.dart

test/
├── unit/                # Unit Tests
├── widget/              # Widget Tests
└── integration/         # Integration Tests
```

Jedes Feature folgt Clean Architecture:
- `data/` - Datenbeschaffung, Repositories
- `domain/` - Business Logic, Entities, Use Cases
- `presentation/` - UI, BLoC/Cubit

## Technologie-Stack

- **Framework:** Flutter 3.x
- **State Management:** BLoC Pattern (geplant)
- **Dependency Injection:** get_it + injectable
- **Navigation:** go_router (geplant)
- **Database:** Drift/SQLite (geplant)
- **i18n:** flutter_localizations + intl (geplant)

## Aktueller Status

**Meilenstein 1.1 - Projekt-Setup** ✅

- [x] Flutter-Projekt initialisiert
- [x] Clean Architecture Struktur erstellt
- [x] Dependency Injection eingerichtet
- [x] Linting & Formatierung konfiguriert

**Nächste Schritte:**
- Meilenstein 1.2: Lokale Datenbank (SQLite/Drift)
- Meilenstein 1.3: Navigation & Shell
- Meilenstein 1.4: Mehrsprachigkeit
- Meilenstein 1.5: Theming
- Meilenstein 1.6: Test-Framework
- Meilenstein 1.7: Docker für Web-Frontend
- Meilenstein 1.8: Material Design

Siehe [../../roadmap.md](../../roadmap.md) für die vollständige Roadmap.

## Hilfreiche Befehle

Alle verfügbaren Make-Targets anzeigen:
```bash
make help
```

Projekt komplett neu aufbauen:
```bash
make rebuild
```

## Lizenz

Siehe [../../LICENSE](../../LICENSE)
