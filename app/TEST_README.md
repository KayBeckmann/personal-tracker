# Testing Guide - Personal Tracker

Dieses Dokument beschreibt die Test-Strategie und wie Tests ausgeführt werden.

## Test-Struktur

Das Projekt verwendet drei Arten von Tests:

### 1. Unit-Tests (`test/unit/`)
Testen einzelne Komponenten isoliert (DAOs, Repositories, Use Cases).

**Beispiele:**
- `test/unit/core/database/app_settings_dao_test.dart`
- `test/unit/features/settings/domain/usecases/get_theme_mode_test.dart`

### 2. Widget-Tests (`test/widget/`)
Testen UI-Komponenten und deren Verhalten.

**Beispiele:**
- `test/widget/app_test.dart`

### 3. Integration-Tests (`integration_test/`)
Testen die gesamte App End-to-End mit Benutzerinteraktionen.

**Beispiele:**
- `integration_test/app_test.dart`

## Tests ausführen

### Alle Unit- und Widget-Tests
```bash
flutter test
```

### Einzelnen Test ausführen
```bash
flutter test test/unit/core/database/app_settings_dao_test.dart
```

### Integration-Tests
```bash
flutter test integration_test/app_test.dart
```

**Auf einem Gerät/Emulator:**
```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

## Test-Coverage

### Coverage-Report generieren
```bash
# Mit Helper-Script (empfohlen)
./test/test_coverage.sh

# Manuell
flutter test --coverage
```

### Coverage-Report anzeigen
Der HTML-Report wird unter `coverage/html/index.html` generiert.

**Linux:**
```bash
xdg-open coverage/html/index.html
```

**macOS:**
```bash
open coverage/html/index.html
```

**Windows:**
```bash
start coverage/html/index.html
```

### Coverage-Ziel
Wir streben eine Test-Coverage von **≥ 80%** an.

## Test-Konventionen

### Naming
- Unit-Tests: `<class_name>_test.dart`
- Widget-Tests: `<widget_name>_test.dart`
- Integration-Tests: `<feature>_test.dart`

### Struktur
Jeder Test sollte dem AAA-Pattern folgen:
1. **Arrange** - Setup und Vorbereitung
2. **Act** - Ausführung der zu testenden Aktion
3. **Assert** - Überprüfung der Ergebnisse

### Beispiel
```dart
test('should return theme mode from repository', () async {
  // Arrange
  when(mockRepository.getSetting('theme_mode'))
      .thenAnswer((_) async => 'dark');

  // Act
  final result = await getThemeMode();

  // Assert
  expect(result, 'dark');
});
```

## Mocking
Wir verwenden Mockito für Mocks, aber derzeit verwenden wir manuelle Mocks für einfache Fälle.

## CI/CD Integration
Tests werden automatisch in der CI-Pipeline ausgeführt (siehe `.github/workflows/test.yml`).

## Troubleshooting

### "Bad state: No element" Fehler
Stelle sicher, dass `configureDependencies()` in `setUpAll` aufgerufen wird.

### Integration-Tests schlagen fehl
Stelle sicher, dass ein Emulator läuft oder ein Gerät verbunden ist.

### Coverage-Script funktioniert nicht
Installiere lcov:
- **Ubuntu/Debian:** `sudo apt-get install lcov`
- **macOS:** `brew install lcov`
- **Windows:** Verwende WSL oder Git Bash

## Weitere Ressourcen
- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)
- [Test Coverage](https://docs.flutter.dev/testing/code-coverage)
