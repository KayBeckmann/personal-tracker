# Personal Tracker - Architektur

## Überblick

Dieses Projekt folgt den Prinzipien der **Clean Architecture** mit einem **Feature-First** Ansatz. Die Architektur ermöglicht:

- Klare Trennung der Verantwortlichkeiten
- Testbarkeit auf allen Ebenen
- Unabhängigkeit von Frameworks und UI
- Einfache Wartbarkeit und Erweiterbarkeit
- Modulare Struktur (Features können einzeln aktiviert/deaktiviert werden)

## Projektstruktur

```
lib/
├── core/                  # Gemeinsame Funktionalität für alle Features
│   ├── di/               # Dependency Injection Setup (get_it + injectable)
│   ├── error/            # Error Handling & Exceptions
│   ├── navigation/       # App-weites Routing (go_router)
│   ├── theme/            # Theme & Styling (Material 3)
│   ├── localization/     # Internationalisierung (i18n)
│   └── utils/            # Hilfsfunktionen & Extensions
│
├── features/             # Feature-Module (jedes Feature folgt Clean Architecture)
│   ├── settings/         # Einstellungen (Theme, Sprache, Module)
│   ├── finance/          # Haushaltsbuch (Meilenstein 2)
│   ├── notes/            # Notizen (Meilenstein 3)
│   ├── tasks/            # Aufgaben (Meilenstein 3)
│   ├── habits/           # Gewohnheiten (Meilenstein 4)
│   ├── journal/          # Journal (Meilenstein 4)
│   ├── time_tracking/    # Zeiterfassung (Meilenstein 5)
│   └── dashboard/        # Dashboard (Meilenstein 6)
│
└── main.dart             # App Entry Point
```

## Clean Architecture Layer

Jedes Feature ist in drei Schichten unterteilt:

### 1. Presentation Layer (`presentation/`)
**Verantwortung:** UI und State Management

```
presentation/
├── bloc/        # BLoC/Cubit für State Management
├── pages/       # Vollständige Screens/Pages
└── widgets/     # Wiederverwendbare UI-Komponenten
```

**Abhängigkeiten:** Domain Layer (Use Cases, Entities)

**Keine Abhängigkeiten zu:** Data Layer

### 2. Domain Layer (`domain/`)
**Verantwortung:** Business Logic (Framework-unabhängig)

```
domain/
├── entities/      # Business Objekte (Plain Dart Classes)
├── repositories/  # Repository Interfaces (Contracts)
└── usecases/      # Anwendungsfälle (Business Logic)
```

**Abhängigkeiten:** Keine (100% Framework-unabhängig)

**Prinzipien:**
- Enthält nur Plain Dart Code
- Keine Flutter-Dependencies
- Definiert Contracts (Repository Interfaces), die vom Data Layer implementiert werden

### 3. Data Layer (`data/`)
**Verantwortung:** Datenbeschaffung und -persistierung

```
data/
├── models/        # Data Transfer Objects (DTOs)
├── datasources/   # Datenquellen (Local DB, Remote API)
└── repositories/  # Repository Implementierungen
```

**Abhängigkeiten:** Domain Layer (implementiert Repository Interfaces)

**Datenquellen:**
- **Local:** SQLite/Drift für lokale Persistierung
- **Remote:** REST API für Backend-Synchronisation (Meilenstein 7)

## Dependency Flow

```
Presentation → Domain ← Data
```

- **Presentation** nutzt **Domain** (Use Cases, Entities)
- **Data** implementiert **Domain** (Repository Interfaces)
- **Domain** ist vollständig unabhängig

## State Management

**BLoC Pattern** (Business Logic Component)

- Klare Trennung von UI und Business Logic
- Testbare Business Logic
- Reaktive Streams für State Updates
- Verwendung von `flutter_bloc` Package

## Dependency Injection

**get_it + injectable**

- Service Locator Pattern
- Automatische Code-Generierung für DI
- Singleton, Factory und LazySingleton Support
- Einfaches Testen durch Mock-Injection

## Navigation

**go_router**

- Deklaratives Routing
- Deep Linking Support
- Type-Safe Navigation
- Unterstützung für Web-URLs

## Feature-Modularität

Jedes Feature kann unabhängig:
- Entwickelt werden
- Getestet werden
- Aktiviert/deaktiviert werden (via Settings)
- Zu späteren Zeitpunkten hinzugefügt werden

## Naming Conventions

### Dateien
- `snake_case.dart` für alle Dart-Dateien
- Suffix für Typen: `_bloc.dart`, `_page.dart`, `_widget.dart`, `_repository.dart`

### Klassen
- `PascalCase` für Klassennamen
- Suffix für Typen: `Bloc`, `Cubit`, `Page`, `Widget`, `Repository`, `UseCase`

### Beispiele
```dart
// Use Case
class GetAccountBalance { }

// Repository Interface
abstract class AccountRepository { }

// Repository Implementation
class AccountRepositoryImpl implements AccountRepository { }

// BLoC
class AccountBloc extends Bloc<AccountEvent, AccountState> { }

// Page
class AccountDetailsPage extends StatelessWidget { }
```

## Testing Strategie

```
test/
├── unit/              # Unit Tests (Domain Layer, Business Logic)
├── widget/            # Widget Tests (Presentation Layer)
└── integration/       # Integration Tests (End-to-End)
```

**Testabdeckung Ziel:** 80%+

## Zukünftige Erweiterungen

Die Architektur ist vorbereitet für:

- **Backend-Integration** (Meilenstein 7)
  - Remote Data Sources im Data Layer
  - Sync-Mechanismus
  - Offline-First Strategie

- **Multi-Platform**
  - Web (bereits supported)
  - Mobile (Android, iOS)
  - Desktop (Linux, Windows, macOS)

- **Feature Plugins**
  - Dynamisches Laden von Features
  - Third-Party Feature-Erweiterungen

## Weiterführende Ressourcen

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter BLoC Pattern](https://bloclibrary.dev/)
- [Dart/Flutter Style Guide](https://dart.dev/guides/language/effective-dart/style)
