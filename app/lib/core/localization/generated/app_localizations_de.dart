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

  @override
  String get manageYourCategories => 'Verwalten Sie Ihre Kategorien';

  @override
  String get createCategory => 'Kategorie erstellen';

  @override
  String get editCategory => 'Kategorie bearbeiten';

  @override
  String get deleteCategory => 'Kategorie löschen';

  @override
  String deleteCategoryConfirmation(String name) {
    return 'Möchten Sie die Kategorie \'$name\' wirklich löschen?';
  }

  @override
  String get noCategoriesYet => 'Noch keine Kategorien';

  @override
  String get createYourFirstCategory =>
      'Erstellen Sie Ihre erste Kategorie, um zu beginnen';

  @override
  String get parentCategory => 'Übergeordnete Kategorie';

  @override
  String get noParent => 'Keine (Hauptkategorie)';

  @override
  String get icon => 'Symbol';

  @override
  String get color => 'Farbe';

  @override
  String get expenses => 'Ausgaben';

  @override
  String get income => 'Einnahmen';

  @override
  String get manageYourTransactions => 'Verwalten Sie Ihre Buchungen';

  @override
  String get createTransaction => 'Buchung erstellen';

  @override
  String get editTransaction => 'Buchung bearbeiten';

  @override
  String get deleteTransaction => 'Buchung löschen';

  @override
  String get deleteTransactionConfirmation =>
      'Möchten Sie diese Buchung wirklich löschen?';

  @override
  String get noTransactionsYet => 'Noch keine Buchungen';

  @override
  String get createYourFirstTransaction =>
      'Erstellen Sie Ihre erste Buchung, um zu beginnen';

  @override
  String get amount => 'Betrag';

  @override
  String get account => 'Konto';

  @override
  String get toAccount => 'Zielkonto';

  @override
  String get category => 'Kategorie';

  @override
  String get date => 'Datum';

  @override
  String get payee => 'Empfänger';

  @override
  String get description => 'Beschreibung';

  @override
  String get transfer => 'Umbuchung';

  @override
  String get pleaseSelectAccount => 'Bitte wählen Sie ein Konto aus';

  @override
  String get expense => 'Ausgabe';

  @override
  String get fromAccount => 'Von Konto';

  @override
  String get pleaseSelectCategory => 'Bitte wählen Sie eine Kategorie aus';

  @override
  String get pleaseEnterDescription => 'Bitte geben Sie eine Beschreibung ein';

  @override
  String get pleaseEnterValidAmount =>
      'Bitte geben Sie einen gültigen Betrag ein';

  @override
  String get pleaseSelectToAccount => 'Bitte wählen Sie ein Zielkonto aus';

  @override
  String get recurringTransactions => 'Daueraufträge';

  @override
  String get createRecurringTransaction => 'Dauerauftrag erstellen';

  @override
  String get editRecurringTransaction => 'Dauerauftrag bearbeiten';

  @override
  String get deleteRecurringTransaction => 'Dauerauftrag löschen';

  @override
  String get deleteRecurringTransactionConfirm =>
      'Möchten Sie diesen Dauerauftrag wirklich löschen?';

  @override
  String get noRecurringTransactions => 'Noch keine Daueraufträge';

  @override
  String get interval => 'Intervall';

  @override
  String get daily => 'Täglich';

  @override
  String get weekly => 'Wöchentlich';

  @override
  String get biweekly => 'Alle 2 Wochen';

  @override
  String get monthly => 'Monatlich';

  @override
  String get quarterly => 'Vierteljährlich';

  @override
  String get semiannually => 'Halbjährlich';

  @override
  String get yearly => 'Jährlich';

  @override
  String get dayOfMonth => 'Tag des Monats';

  @override
  String get dayOfMonthHelper => 'Tag des Monats (1-31)';

  @override
  String get pleaseEnterDayOfMonth => 'Bitte geben Sie einen Tag ein';

  @override
  String get pleaseEnterValidDay =>
      'Bitte geben Sie einen gültigen Tag ein (1-31)';

  @override
  String get startDate => 'Startdatum';

  @override
  String get endDate => 'Enddatum';

  @override
  String get noEndDate => 'Kein Enddatum';

  @override
  String get until => 'Bis';

  @override
  String get nextDue => 'Nächste Fälligkeit';

  @override
  String get ended => 'Beendet';

  @override
  String get active => 'Aktiv';
}
