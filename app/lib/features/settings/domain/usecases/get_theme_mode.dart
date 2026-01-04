import 'package:injectable/injectable.dart';

import '../repositories/settings_repository.dart';

/// Use Case zum Abrufen des Theme-Modus
///
/// Beispiel für einen Use Case, der das Repository verwendet.
/// Kapselt die Business-Logik für das Abrufen des Theme-Modus.
@injectable
class GetThemeMode {
  const GetThemeMode(this._repository);

  final SettingsRepository _repository;

  /// Holt den gespeicherten Theme-Modus
  ///
  /// Returns: 'light', 'dark' oder 'system' (default)
  Future<String> call() async {
    final themeMode = await _repository.getSetting('theme_mode');
    return themeMode ?? 'system';
  }

  /// Stream der Änderungen am Theme-Modus beobachtet
  Stream<String> watch() =>
      _repository.watchSetting('theme_mode').map((mode) => mode ?? 'system');
}
