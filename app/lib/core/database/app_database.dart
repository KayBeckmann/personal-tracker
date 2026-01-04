import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables/app_settings_table.dart';

part 'app_database.g.dart';

/// Haupt-Datenbank für Personal Tracker
///
/// Diese Datenbank enthält alle Tabellen für die verschiedenen Features.
/// Verwendet Drift für typsichere SQL-Queries und automatische Code-Generierung.
@lazySingleton
@DriftDatabase(tables: [
  AppSettingsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

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

/// Öffnet die SQLite-Datenbank im App-Verzeichnis
LazyDatabase _openConnection() => LazyDatabase(() async {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'personal_tracker.db'));
      return NativeDatabase.createInBackground(file);
    });
