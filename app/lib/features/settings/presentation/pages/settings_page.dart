import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/usecases/get_locale.dart';
import '../../domain/usecases/get_theme_mode.dart';
import '../../domain/usecases/set_locale.dart';
import '../../domain/usecases/set_theme_mode.dart';

/// Einstellungen
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _getLocale = getIt<GetLocale>();
  final _setLocale = getIt<SetLocale>();
  final _getThemeMode = getIt<GetThemeMode>();
  final _setThemeMode = getIt<SetThemeMode>();

  Locale? _currentLocale;
  ThemeMode _currentThemeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadLocale();
    _loadThemeMode();
  }

  Future<void> _loadLocale() async {
    final locale = await _getLocale();
    if (mounted) {
      setState(() {
        _currentLocale = locale;
      });
    }
  }

  Future<void> _loadThemeMode() async {
    final themeModeString = await _getThemeMode();
    if (mounted) {
      setState(() {
        _currentThemeMode = _parseThemeMode(themeModeString);
      });
    }
  }

  ThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  String _getLocaleName(BuildContext context, Locale? locale) {
    final l10n = AppLocalizations.of(context)!;
    if (locale == null) {
      return l10n.english; // System default - currently shows English as fallback
    }
    switch (locale.languageCode) {
      case 'de':
        return l10n.german;
      case 'en':
        return l10n.english;
      default:
        return locale.languageCode;
    }
  }

  String _getThemeModeName(BuildContext context, ThemeMode themeMode) {
    final l10n = AppLocalizations.of(context)!;
    switch (themeMode) {
      case ThemeMode.light:
        return l10n.lightTheme;
      case ThemeMode.dark:
        return l10n.darkTheme;
      case ThemeMode.system:
        return l10n.systemTheme;
    }
  }

  Future<void> _showThemeDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final selectedTheme = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: Text(l10n.lightTheme),
              value: ThemeMode.light,
              groupValue: _currentThemeMode,
              onChanged: (value) => Navigator.of(context).pop(value),
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.darkTheme),
              value: ThemeMode.dark,
              groupValue: _currentThemeMode,
              onChanged: (value) => Navigator.of(context).pop(value),
            ),
            RadioListTile<ThemeMode>(
              title: Text(l10n.systemTheme),
              value: ThemeMode.system,
              groupValue: _currentThemeMode,
              onChanged: (value) => Navigator.of(context).pop(value),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (selectedTheme != null) {
      await _setThemeMode(_themeModeToString(selectedTheme));
      if (mounted) {
        setState(() {
          _currentThemeMode = selectedTheme;
        });
      }
    }
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final selectedLocale = await showDialog<Locale?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String?>(
              title: Text(l10n.german),
              value: 'de',
              groupValue: _currentLocale?.languageCode,
              onChanged: (value) => Navigator.of(context).pop(const Locale('de')),
            ),
            RadioListTile<String?>(
              title: Text(l10n.english),
              value: 'en',
              groupValue: _currentLocale?.languageCode,
              onChanged: (value) => Navigator.of(context).pop(const Locale('en')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );

    if (selectedLocale != null) {
      await _setLocale(selectedLocale);
      if (mounted) {
        setState(() {
          _currentLocale = selectedLocale;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.palette),
            title: Text(l10n.theme),
            subtitle: Text(_getThemeModeName(context, _currentThemeMode)),
            onTap: () => _showThemeDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            subtitle: Text(_getLocaleName(context, _currentLocale)),
            onTap: () => _showLanguageDialog(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.apps),
            title: Text(l10n.modules),
            subtitle: Text(l10n.modulesSubtitle),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(l10n.about),
            subtitle: Text(l10n.version('1.0.0+1')),
          ),
        ],
      ),
    );
  }
}
