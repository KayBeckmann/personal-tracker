# Datenbank

Personal Tracker verwendet **Drift** (früher Moor) für die lokale Datenbankanbindung mit SQLite.

## Überblick

- **ORM:** Drift - typsichere SQL-Queries mit Code-Generierung
- **Datenbank:** SQLite via `sqlite3_flutter_libs`
- **Pattern:** Repository-Pattern nach Clean Architecture
- **Testing:** In-Memory Datenbank für Tests

## Struktur

```
lib/core/database/
├── app_database.dart         # Haupt-Datenbank-Klasse
├── tables/                   # Tabellen-Definitionen
│   └── app_settings_table.dart
└── daos/                     # Data Access Objects
    └── app_settings_dao.dart
```

## Neue Tabelle hinzufügen

### 1. Tabellen-Klasse erstellen

Erstelle eine neue Datei in `tables/`:

```dart
import 'package:drift/drift.dart';

@DataClassName('User')
class UsersTable extends Table {
  @override
  String get tableName => 'users';

  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get email => text().unique()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
```

### 2. Tabelle in Datenbank registrieren

Füge die Tabelle zu `app_database.dart` hinzu:

```dart
@DriftDatabase(tables: [
  AppSettingsTable,
  UsersTable, // Neu
])
class AppDatabase extends _$AppDatabase {
  // ...
}
```

### 3. Code-Generierung ausführen

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. (Optional) DAO erstellen

Für komplexere Queries erstelle ein DAO in `daos/`:

```dart
import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../app_database.dart';
import '../tables/users_table.dart';

part 'users_dao.g.dart';

@lazySingleton
@DriftAccessor(tables: [UsersTable])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  Future<List<User>> getAllUsers() => select(usersTable).get();

  Future<User?> getUserById(int id) =>
      (select(usersTable)..where((u) => u.id.equals(id))).getSingleOrNull();

  Future<int> createUser(UsersTableCompanion user) =>
      into(usersTable).insert(user);
}
```

Nach dem Erstellen erneut Code-Generierung ausführen.

### 5. Repository implementieren

Implementiere das Repository-Pattern:

**Domain-Layer** (`features/user/domain/repositories/user_repository.dart`):
```dart
abstract class UserRepository {
  Future<User?> getUser(int id);
  Future<void> createUser(String name, String email);
}
```

**Data-Layer** (`features/user/data/repositories/user_repository_impl.dart`):
```dart
@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  const UserRepositoryImpl(this._dao);

  final UsersDao _dao;

  @override
  Future<User?> getUser(int id) => _dao.getUserById(id);

  @override
  Future<void> createUser(String name, String email) {
    final user = UsersTableCompanion.insert(name: name, email: email);
    return _dao.createUser(user);
  }
}
```

## Migrations

Wenn sich das Schema ändert:

1. Erhöhe `schemaVersion` in `app_database.dart`
2. Implementiere Migration in `onUpgrade`:

```dart
@override
MigrationStrategy get migration => MigrationStrategy(
  onCreate: (Migrator m) async {
    await m.createAll();
  },
  onUpgrade: (Migrator m, int from, int to) async {
    if (from < 2) {
      // Migration von Version 1 zu 2
      await m.addColumn(usersTable, usersTable.phoneNumber);
    }
    if (from < 3) {
      // Migration von Version 2 zu 3
      await m.createTable(ordersTable);
    }
  },
);
```

## Testing

Verwende In-Memory Datenbank für Tests:

```dart
void main() {
  late AppDatabase database;
  late UsersDao dao;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dao = UsersDao(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('should create user', () async {
    final user = UsersTableCompanion.insert(
      name: 'Test User',
      email: 'test@example.com',
    );

    final id = await dao.createUser(user);
    final result = await dao.getUserById(id);

    expect(result?.name, equals('Test User'));
  });
}
```

## Drift Queries

### Einfache Queries

```dart
// SELECT * FROM users
final users = await select(usersTable).get();

// SELECT * FROM users WHERE id = ?
final user = await (select(usersTable)
  ..where((u) => u.id.equals(42))
).getSingleOrNull();

// SELECT * FROM users WHERE name LIKE ?
final results = await (select(usersTable)
  ..where((u) => u.name.like('%John%'))
).get();
```

### Joins

```dart
final query = select(ordersTable).join([
  innerJoin(usersTable, usersTable.id.equalsExp(ordersTable.userId)),
]);

final results = await query.get();
for (final row in results) {
  final order = row.readTable(ordersTable);
  final user = row.readTable(usersTable);
}
```

### Streams (Reactive)

```dart
// Stream der sich aktualisiert wenn Daten ändern
Stream<List<User>> watchAllUsers() => select(usersTable).watch();

// In UI verwenden mit StreamBuilder
StreamBuilder<List<User>>(
  stream: dao.watchAllUsers(),
  builder: (context, snapshot) {
    final users = snapshot.data ?? [];
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) => Text(users[index].name),
    );
  },
)
```

## Tipps

- **Typsicherheit:** Drift generiert typsichere Klassen für alle Tabellen
- **Validierung:** Nutze Constraints wie `withLength()`, `unique()`, etc.
- **Performance:** Nutze Indizes für häufig genutzte WHERE-Clauses
- **Reactive UI:** Nutze `watch()` statt `get()` für automatische Updates

## Ressourcen

- [Drift Dokumentation](https://drift.simonbinder.eu/)
- [SQL in Drift](https://drift.simonbinder.eu/docs/getting-started/writing_queries/)
- [Advanced Drift Features](https://drift.simonbinder.eu/docs/advanced-features/)
