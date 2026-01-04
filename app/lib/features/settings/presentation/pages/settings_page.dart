import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../domain/usecases/get_locale.dart';
import '../../domain/usecases/set_locale.dart';

/// Einstellungen
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _getLocale = getIt<GetLocale>();
  final _setLocale = getIt<SetLocale>();

  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final locale = await _getLocale();
    if (mounted) {
      setState(() {
        _currentLocale = locale;
      });
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
            title: Text(l10n.design),
            subtitle: Text(l10n.designSubtitle),
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
