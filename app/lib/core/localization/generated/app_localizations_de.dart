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
  String get theme => 'Farbschema';

  @override
  String get selectTheme => 'Farbschema auswählen';

  @override
  String get lightTheme => 'Hell';

  @override
  String get darkTheme => 'Dunkel';

  @override
  String get systemTheme => 'Systemeinstellung';

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

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get manageYourFinances => 'Verwalten Sie Ihre Finanzen';

  @override
  String get accounts => 'Konten';

  @override
  String get transactions => 'Buchungen';

  @override
  String get categories => 'Kategorien';

  @override
  String get budgets => 'Budgets';

  @override
  String get manageYourAccounts => 'Verwalten Sie Ihre Konten';

  @override
  String get noAccountsYet => 'Noch keine Konten';

  @override
  String get createYourFirstAccount =>
      'Erstellen Sie Ihr erstes Konto, um zu beginnen';

  @override
  String get createAccount => 'Konto erstellen';

  @override
  String get editAccount => 'Konto bearbeiten';

  @override
  String get deleteAccount => 'Konto löschen';

  @override
  String deleteAccountConfirmation(Object name) {
    return 'Möchten Sie das Konto \'$name\' wirklich löschen?';
  }

  @override
  String get name => 'Name';

  @override
  String get accountType => 'Kontotyp';

  @override
  String get initialBalance => 'Anfangssaldo';

  @override
  String get includeInOverview => 'In Übersicht anzeigen';

  @override
  String get defaultAccount => 'Standard-Konto';

  @override
  String get pleaseEnterName => 'Bitte geben Sie einen Namen ein';

  @override
  String get pleaseEnterAmount => 'Bitte geben Sie einen Betrag ein';

  @override
  String get pleaseEnterValidNumber => 'Bitte geben Sie eine gültige Zahl ein';

  @override
  String get pleaseSelectAccountType => 'Bitte wählen Sie einen Kontotyp aus';
}
