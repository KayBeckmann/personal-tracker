import 'package:injectable/injectable.dart';

import '../../../../core/database/daos/app_settings_dao.dart';
import '../../domain/repositories/settings_repository.dart';

/// Implementierung des SettingsRepository mit Drift/SQLite
///
/// Verwendet den AppSettingsDao für Datenbankoperationen.
/// Diese Implementierung ist im Data-Layer und implementiert
/// das Interface aus dem Domain-Layer.
@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._dao);

  final AppSettingsDao _dao;

  @override
  Future<String?> getSetting(String key) async {
    final setting = await _dao.getSetting(key);
    return setting?.value;
  }

  @override
  Future<void> setSetting(String key, String value) =>
      _dao.setSetting(key, value);

  @override
  Future<void> deleteSetting(String key) async {
    await _dao.deleteSetting(key);
  }

  @override
  Future<Map<String, String>> getAllSettings() async {
    final settings = await _dao.getAllSettings();
    return {for (final setting in settings) setting.key: setting.value};
  }

  @override
  Stream<String?> watchSetting(String key) =>
      _dao.watchSetting(key).map((setting) => setting?.value);

  @override
  Stream<Map<String, String>> watchAllSettings() => _dao
      .watchAllSettings()
      .map((settings) => {for (final s in settings) s.key: s.value});
}
