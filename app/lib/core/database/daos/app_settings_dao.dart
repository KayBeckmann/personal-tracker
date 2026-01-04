import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../app_database.dart';
import '../tables/app_settings_table.dart';

part 'app_settings_dao.g.dart';

/// Data Access Object für App-Einstellungen
///
/// Bietet typsichere Methoden zum Lesen und Schreiben von Einstellungen.
/// Verwendet Drift's DAO-Pattern für Clean Code.
@lazySingleton
@DriftAccessor(tables: [AppSettingsTable])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  /// Holt eine Einstellung anhand ihres Schlüssels
  ///
  /// Returns null wenn der Schlüssel nicht existiert.
  Future<AppSetting?> getSetting(String key) =>
      (select(appSettingsTable)..where((tbl) => tbl.key.equals(key)))
          .getSingleOrNull();

  /// Speichert oder aktualisiert eine Einstellung
  ///
  /// Wenn der Schlüssel bereits existiert, wird der Wert aktualisiert.
  /// Sonst wird ein neuer Eintrag erstellt.
  Future<void> setSetting(String key, String value) => into(appSettingsTable)
      .insertOnConflictUpdate(
        AppSettingsTableCompanion.insert(
          key: key,
          value: value,
          updatedAt: Value(DateTime.now()),
        ),
      );

  /// Löscht eine Einstellung
  Future<int> deleteSetting(String key) =>
      (delete(appSettingsTable)..where((tbl) => tbl.key.equals(key))).go();

  /// Holt alle Einstellungen
  Future<List<AppSetting>> getAllSettings() => select(appSettingsTable).get();

  /// Stream der alle Einstellungen beobachtet
  Stream<List<AppSetting>> watchAllSettings() =>
      select(appSettingsTable).watch();

  /// Stream der eine bestimmte Einstellung beobachtet
  Stream<AppSetting?> watchSetting(String key) =>
      (select(appSettingsTable)..where((tbl) => tbl.key.equals(key)))
          .watchSingleOrNull();
}
