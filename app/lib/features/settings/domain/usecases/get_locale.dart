import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

import '../repositories/settings_repository.dart';

/// Use Case zum Abrufen der gespeicherten Sprache
///
/// Gibt die gespeicherte Locale zurück oder null für System-Standard.
@injectable
class GetLocale {
  const GetLocale(this._repository);

  final SettingsRepository _repository;

  static const _localeKey = 'locale';

  /// Holt die gespeicherte Locale
  ///
  /// Returns: Locale oder null für System-Standard
  Future<Locale?> call() async {
    final localeCode = await _repository.getSetting(_localeKey);

    if (localeCode == null || localeCode.isEmpty) {
      return null; // System-Standard
    }

    return Locale(localeCode);
  }

  /// Stream der Änderungen an der Locale beobachtet
  Stream<Locale?> watch() => _repository.watchSetting(_localeKey).map(
        (localeCode) {
          if (localeCode == null || localeCode.isEmpty) {
            return null;
          }
          return Locale(localeCode);
        },
      );
}
