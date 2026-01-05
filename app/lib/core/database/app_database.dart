import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import 'connection/connection.dart';
import 'tables/app_settings_table.dart';

part 'app_database.g.dart';

/// Haupt-Datenbank für Personal Tracker
///
/// Diese Datenbank enthält alle Tabellen für die verschiedenen Features.
/// Verwendet Drift für typsichere SQL-Queries und automatische Code-Generierung.
/// Unterstützt sowohl native Plattformen (SQLite) als auch Web (IndexedDB).
@lazySingleton
@DriftDatabase(tables: [
  AppSettingsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Für Tests kann eine In-Memory-Datenbank übergeben werden
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Migrations werden hier implementiert, wenn schemaVersion erhöht wird
          // Beispiel:
          // if (from < 2) {
          //   await m.addColumn(appSettings, appSettings.newColumn);
          // }
        },
      );
}
