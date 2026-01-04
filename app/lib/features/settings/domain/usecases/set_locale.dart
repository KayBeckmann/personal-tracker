import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../repositories/settings_repository.dart';

/// Use Case zum Setzen der Sprache
///
/// Speichert die gewählte Locale in den Einstellungen.
@injectable
class SetLocale {
  const SetLocale(this._repository);

  final SettingsRepository _repository;

  static const _localeKey = 'locale';

  /// Setzt die Locale
  ///
  /// [locale] kann null sein für System-Standard oder eine Locale wie Locale('de')
  Future<void> call(Locale? locale) async {
    if (locale == null) {
      await _repository.deleteSetting(_localeKey);
    } else {
      await _repository.setSetting(_localeKey, locale.languageCode);
    }
  }
}
