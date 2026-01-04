# Dependency Injection

Dieses Projekt verwendet **get_it** mit **injectable** für Dependency Injection.

## Verwendung

### Services/Repositories registrieren

Verwende die `@injectable` Annotation, um eine Klasse für DI zu registrieren:

```dart
import 'package:injectable/injectable.dart';

@injectable
class MyService {
  void doSomething() {
    print('Service called!');
  }
}
```

### Verschiedene Registrierungs-Typen

#### Singleton (eine Instanz für die gesamte App)
```dart
@singleton
class DatabaseService {
  // Wird nur einmal erstellt
}
```

#### LazySingleton (wird erst bei erster Verwendung erstellt)
```dart
@lazySingleton
class ApiService {
  // Wird erst beim ersten getIt<ApiService>() erstellt
}
```

#### Factory (neue Instanz bei jedem Aufruf)
```dart
@injectable
class TempService {
  // Neue Instanz bei jedem getIt<TempService>()
}
```

### Interfaces implementieren

```dart
// Repository Interface (Domain Layer)
abstract class UserRepository {
  Future<User> getUser(String id);
}

// Repository Implementierung (Data Layer)
@Injectable(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  @override
  Future<User> getUser(String id) async {
    // Implementation
  }
}
```

### Dependencies injizieren

Dependencies werden automatisch über den Konstruktor injiziert:

```dart
@injectable
class AuthService {
  final UserRepository _userRepository;
  final ApiService _apiService;

  AuthService(this._userRepository, this._apiService);

  Future<void> login(String email, String password) async {
    // _userRepository und _apiService werden automatisch injiziert
  }
}
```

### Service abrufen

```dart
import 'package:personal_tracker/core/di/injection.dart';

// In einer Klasse außerhalb von DI
final authService = getIt<AuthService>();
await authService.login(email, password);
```

### Umgebungen (Environments)

Du kannst verschiedene Implementierungen für verschiedene Umgebungen registrieren:

```dart
@Injectable(as: ApiService, env: [Environment.dev])
class MockApiService implements ApiService { }

@Injectable(as: ApiService, env: [Environment.prod])
class RealApiService implements ApiService { }
```

Beim App-Start die Umgebung angeben:
```dart
await configureDependencies(environment: Environment.prod);
```

## Code generieren

Nach jeder Änderung an DI-Registrierungen, führe aus:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Oder für continuous watch während der Entwicklung:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Testen

Für Unit-Tests kannst du Mock-Implementierungen registrieren:

```dart
void main() {
  setUp(() {
    getIt.registerSingleton<UserRepository>(MockUserRepository());
  });

  tearDown(() {
    getIt.reset();
  });

  test('test with mocked dependency', () {
    final authService = getIt<AuthService>();
    // Test mit gemocktem UserRepository
  });
}
```
