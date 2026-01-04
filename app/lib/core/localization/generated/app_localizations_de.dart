// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Personal Tracker';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get finance => 'Finanzen';

  @override
  String get finances => 'Finanzen';

  @override
  String get householdBook => 'Haushaltsbuch';

  @override
  String get notes => 'Notizen';

  @override
  String get tasks => 'Aufgaben';

  @override
  String get habits => 'Gewohnheiten';

  @override
  String get journal => 'Journal';

  @override
  String get timeTracking => 'Zeiterfassung';

  @override
  String get settings => 'Einstellungen';

  @override
  String get design => 'Design';

  @override
  String get designSubtitle => 'Theme, Farben, Schriftarten';

  @override
  String get language => 'Sprache';

  @override
  String get languageSubtitle => 'Anwendungssprache ändern';

  @override
  String get modules => 'Module';

  @override
  String get modulesSubtitle => 'Features aktivieren/deaktivieren';

  @override
  String get about => 'Über';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'English';

  @override
  String get selectLanguage => 'Sprache auswählen';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get ok => 'OK';

  @override
  String get scaffoldBeingBuilt => 'Grundgerüst wird aufgebaut';

  @override
  String milestone(String number) {
    return 'Meilenstein $number';
  }

  @override
  String implementedInMilestone(String number) {
    return 'Wird in Meilenstein $number implementiert';
  }
}
