/// Repository Interface für App-Einstellungen
///
/// Definiert das Contract für den Zugriff auf Einstellungen.
/// Implementierungen kümmern sich um die tatsächliche Datenhaltung.
abstract class SettingsRepository {
  /// Holt eine Einstellung anhand des Schlüssels
  Future<String?> getSetting(String key);

  /// Speichert eine Einstellung
  Future<void> setSetting(String key, String value);

  /// Löscht eine Einstellung
  Future<void> deleteSetting(String key);

  /// Holt alle Einstellungen als Map
  Future<Map<String, String>> getAllSettings();

  /// Stream der Änderungen an einer Einstellung beobachtet
  Stream<String?> watchSetting(String key);

  /// Stream der alle Einstellungen beobachtet
  Stream<Map<String, String>> watchAllSettings();
}
