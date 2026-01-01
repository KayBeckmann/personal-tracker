# Personal Tracker

Eine modulare App zur Erfassung und Verwaltung persönlicher Daten - lokal und mit optionaler Backend-Synchronisation.

## Features

| Modul | Beschreibung |
|-------|--------------|
| **Haushaltsbuch** | Konten, Buchungen, Kategorien, Budgets, Daueraufträge |
| **Notizen** | Markdown-Editor mit Verlinkungen und Tags |
| **Aufgaben** | Task-Management mit Prioritäten und Fälligkeiten |
| **Gewohnheiten** | Habit-Tracking mit verschiedenen Intervallen |
| **Journal** | Tagebuch mit Trackern und Vorlagen |
| **Zeiterfassung** | Stempeln, Überstunden, Urlaub |
| **Dashboard** | Zentrale Übersicht aller Module |

## Tech Stack

- **Frontend:** Flutter (Cross-Platform)
- **Backend:** Dart
- **Datenbank:** SQLite (lokal) / PostgreSQL (Backend)
- **Deployment:** Docker

## Plattformen

- Linux
- Windows
- Android
- iOS
- Web

## Sprachen

- Englisch (Default)
- Deutsch
- Französisch
- Spanisch
- Schwedisch
- Norwegisch

## Projekt-Status

Siehe [Roadmap](roadmap.md) für den aktuellen Entwicklungsstand.

## Self-Hosting

```bash
# Repository klonen
git clone https://github.com/username/personal-tracker.git
cd personal-tracker

# Konfiguration anpassen
cp .env.example .env

# Container starten
docker-compose up -d
```

## Entwicklung

```bash
# Flutter Abhängigkeiten installieren
flutter pub get

# App starten (Development)
flutter run

# Tests ausführen
flutter test
```

## Projektstruktur

```
personal-tracker/
├── lib/                    # Flutter App
│   ├── core/               # Gemeinsame Komponenten
│   ├── features/           # Feature-Module
│   │   ├── budget/         # Haushaltsbuch
│   │   ├── notes/          # Notizen
│   │   ├── tasks/          # Aufgaben
│   │   ├── habits/         # Gewohnheiten
│   │   ├── journal/        # Journal
│   │   ├── timetracking/   # Zeiterfassung
│   │   └── dashboard/      # Dashboard
│   └── l10n/               # Übersetzungen
├── backend/                # Dart Backend
├── docker/                 # Docker Konfiguration
├── docs/                   # Dokumentation
└── test/                   # Tests
```

## Lizenz

MIT License

## Unterstützen

- BTC: `12QBn6eba71FtAUM4HFmSGgTY9iTPfRKLx`
- [Buy Me a Coffee](https://www.buymeacoffee.com/snuppedelua)
