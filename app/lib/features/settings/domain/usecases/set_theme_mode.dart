import 'package:injectable/injectable.dart';

import '../repositories/settings_repository.dart';

/// Use Case zum Setzen des Theme-Modus
///
/// Beispiel für einen Use Case, der das Repository verwendet.
/// Kapselt die Business-Logik für das Speichern des Theme-Modus.
@injectable
class SetThemeMode {
  const SetThemeMode(this._repository);

  final SettingsRepository _repository;

  /// Speichert den Theme-Modus
  ///
  /// [mode] kann sein: 'light', 'dark' oder 'system'
  Future<void> call(String mode) async {
    if (!['light', 'dark', 'system'].contains(mode)) {
      throw ArgumentError('Invalid theme mode: $mode');
    }

    await _repository.setSetting('theme_mode', mode);
  }
}
