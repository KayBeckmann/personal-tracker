import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../features/settings/domain/repositories/settings_repository.dart';
import 'app_module.dart';

/// Service zur Verwaltung aktivierter Module
///
/// Verwaltet welche Module aktiviert/deaktiviert sind und
/// persistiert dies in den Einstellungen.
@lazySingleton
class ModuleService {
  const ModuleService(this._settingsRepository);

  final SettingsRepository _settingsRepository;

  static const _enabledModulesKey = 'enabled_modules';

  /// Holt die Liste der aktivierten Module-IDs
  Future<Set<String>> getEnabledModuleIds() async {
    final json = await _settingsRepository.getSetting(_enabledModulesKey);

    if (json == null) {
      // Standardmäßig aktivierte Module
      return AppModules.all
          .where((m) => m.isEnabledByDefault)
          .map((m) => m.id)
          .toSet();
    }

    final list = jsonDecode(json) as List<dynamic>;
    return list.cast<String>().toSet();
  }

  /// Holt die Liste der aktivierten Module
  Future<List<AppModule>> getEnabledModules() async {
    final enabledIds = await getEnabledModuleIds();
    return AppModules.all.where((m) => enabledIds.contains(m.id)).toList();
  }

  /// Prüft ob ein Modul aktiviert ist
  Future<bool> isModuleEnabled(String moduleId) async {
    final enabledIds = await getEnabledModuleIds();
    return enabledIds.contains(moduleId);
  }

  /// Aktiviert ein Modul
  Future<void> enableModule(String moduleId) async {
    final enabledIds = await getEnabledModuleIds();
    enabledIds.add(moduleId);
    await _saveEnabledModules(enabledIds);
  }

  /// Deaktiviert ein Modul
  Future<void> disableModule(String moduleId) async {
    final enabledIds = await getEnabledModuleIds();
    enabledIds.remove(moduleId);
    await _saveEnabledModules(enabledIds);
  }

  /// Setzt den Aktivierungsstatus eines Moduls
  Future<void> setModuleEnabled(String moduleId, {required bool enabled}) async {
    if (enabled) {
      await enableModule(moduleId);
    } else {
      await disableModule(moduleId);
    }
  }

  /// Stream der Änderungen an aktivierten Modulen beobachtet
  Stream<List<AppModule>> watchEnabledModules() =>
      _settingsRepository.watchSetting(_enabledModulesKey).asyncMap(
        (json) async {
          if (json == null) {
            return AppModules.all
                .where((m) => m.isEnabledByDefault)
                .toList();
          }

          final list = jsonDecode(json) as List<dynamic>;
          final enabledIds = list.cast<String>().toSet();
          return AppModules.all
              .where((m) => enabledIds.contains(m.id))
              .toList();
        },
      );

  Future<void> _saveEnabledModules(Set<String> moduleIds) async {
    final json = jsonEncode(moduleIds.toList());
    await _settingsRepository.setSetting(_enabledModulesKey, json);
  }
}
