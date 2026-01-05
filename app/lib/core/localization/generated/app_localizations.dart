import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
  ];

  /// Der Titel der Anwendung
  ///
  /// In de, this message translates to:
  /// **'Personal Tracker'**
  String get appTitle;

  /// Dashboard-Modul
  ///
  /// In de, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// Finanz-Modul
  ///
  /// In de, this message translates to:
  /// **'Finanzen'**
  String get finance;

  /// Plural von Finanzen
  ///
  /// In de, this message translates to:
  /// **'Finanzen'**
  String get finances;

  /// Haushaltsbuch
  ///
  /// In de, this message translates to:
  /// **'Haushaltsbuch'**
  String get householdBook;

  /// Notizen-Modul
  ///
  /// In de, this message translates to:
  /// **'Notizen'**
  String get notes;

  /// Aufgaben-Modul
  ///
  /// In de, this message translates to:
  /// **'Aufgaben'**
  String get tasks;

  /// Gewohnheiten-Modul
  ///
  /// In de, this message translates to:
  /// **'Gewohnheiten'**
  String get habits;

  /// Journal-Modul
  ///
  /// In de, this message translates to:
  /// **'Journal'**
  String get journal;

  /// Zeiterfassungs-Modul
  ///
  /// In de, this message translates to:
  /// **'Zeiterfassung'**
  String get timeTracking;

  /// Einstellungen-Modul
  ///
  /// In de, this message translates to:
  /// **'Einstellungen'**
  String get settings;

  /// Design-Einstellungen
  ///
  /// In de, this message translates to:
  /// **'Design'**
  String get design;

  /// Untertitel für Design-Einstellungen
  ///
  /// In de, this message translates to:
  /// **'Theme, Farben, Schriftarten'**
  String get designSubtitle;

  /// Theme/Farbschema
  ///
  /// In de, this message translates to:
  /// **'Farbschema'**
  String get theme;

  /// Dialog-Titel für Theme-Auswahl
  ///
  /// In de, this message translates to:
  /// **'Farbschema auswählen'**
  String get selectTheme;

  /// Helles Theme
  ///
  /// In de, this message translates to:
  /// **'Hell'**
  String get lightTheme;

  /// Dunkles Theme
  ///
  /// In de, this message translates to:
  /// **'Dunkel'**
  String get darkTheme;

  /// System-Theme (folgt Geräteeinstellung)
  ///
  /// In de, this message translates to:
  /// **'Systemeinstellung'**
  String get systemTheme;

  /// Sprache
  ///
  /// In de, this message translates to:
  /// **'Sprache'**
  String get language;

  /// Untertitel für Sprach-Einstellungen
  ///
  /// In de, this message translates to:
  /// **'Anwendungssprache ändern'**
  String get languageSubtitle;

  /// Module
  ///
  /// In de, this message translates to:
  /// **'Module'**
  String get modules;

  /// Untertitel für Modul-Einstellungen
  ///
  /// In de, this message translates to:
  /// **'Features aktivieren/deaktivieren'**
  String get modulesSubtitle;

  /// Über-Bereich
  ///
  /// In de, this message translates to:
  /// **'Über'**
  String get about;

  /// Versions-Anzeige
  ///
  /// In de, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// Deutsche Sprache
  ///
  /// In de, this message translates to:
  /// **'Deutsch'**
  String get german;

  /// Englische Sprache
  ///
  /// In de, this message translates to:
  /// **'English'**
  String get english;

  /// Dialog-Titel für Sprachauswahl
  ///
  /// In de, this message translates to:
  /// **'Sprache auswählen'**
  String get selectLanguage;

  /// Abbrechen-Button
  ///
  /// In de, this message translates to:
  /// **'Abbrechen'**
  String get cancel;

  /// OK-Button
  ///
  /// In de, this message translates to:
  /// **'OK'**
  String get ok;

  /// Text während Aufbau
  ///
  /// In de, this message translates to:
  /// **'Grundgerüst wird aufgebaut'**
  String get scaffoldBeingBuilt;

  /// Meilenstein-Anzeige
  ///
  /// In de, this message translates to:
  /// **'Meilenstein {number}'**
  String milestone(String number);

  /// Hinweis auf zukünftigen Meilenstein
  ///
  /// In de, this message translates to:
  /// **'Wird in Meilenstein {number} implementiert'**
  String implementedInMilestone(String number);

  /// No description provided for @save.
  ///
  /// In de, this message translates to:
  /// **'Speichern'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In de, this message translates to:
  /// **'Löschen'**
  String get delete;

  /// No description provided for @manageYourFinances.
  ///
  /// In de, this message translates to:
  /// **'Verwalten Sie Ihre Finanzen'**
  String get manageYourFinances;

  /// No description provided for @accounts.
  ///
  /// In de, this message translates to:
  /// **'Konten'**
  String get accounts;

  /// No description provided for @transactions.
  ///
  /// In de, this message translates to:
  /// **'Buchungen'**
  String get transactions;

  /// No description provided for @categories.
  ///
  /// In de, this message translates to:
  /// **'Kategorien'**
  String get categories;

  /// No description provided for @budgets.
  ///
  /// In de, this message translates to:
  /// **'Budgets'**
  String get budgets;

  /// No description provided for @manageYourAccounts.
  ///
  /// In de, this message translates to:
  /// **'Verwalten Sie Ihre Konten'**
  String get manageYourAccounts;

  /// No description provided for @noAccountsYet.
  ///
  /// In de, this message translates to:
  /// **'Noch keine Konten'**
  String get noAccountsYet;

  /// No description provided for @createYourFirstAccount.
  ///
  /// In de, this message translates to:
  /// **'Erstellen Sie Ihr erstes Konto, um zu beginnen'**
  String get createYourFirstAccount;

  /// No description provided for @createAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto erstellen'**
  String get createAccount;

  /// No description provided for @editAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto bearbeiten'**
  String get editAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In de, this message translates to:
  /// **'Konto löschen'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirmation.
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie das Konto \'{name}\' wirklich löschen?'**
  String deleteAccountConfirmation(Object name);

  /// No description provided for @name.
  ///
  /// In de, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @accountType.
  ///
  /// In de, this message translates to:
  /// **'Kontotyp'**
  String get accountType;

  /// No description provided for @initialBalance.
  ///
  /// In de, this message translates to:
  /// **'Anfangssaldo'**
  String get initialBalance;

  /// No description provided for @includeInOverview.
  ///
  /// In de, this message translates to:
  /// **'In Übersicht anzeigen'**
  String get includeInOverview;

  /// No description provided for @defaultAccount.
  ///
  /// In de, this message translates to:
  /// **'Standard-Konto'**
  String get defaultAccount;

  /// No description provided for @pleaseEnterName.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie einen Namen ein'**
  String get pleaseEnterName;

  /// No description provided for @pleaseEnterAmount.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie einen Betrag ein'**
  String get pleaseEnterAmount;

  /// No description provided for @pleaseEnterValidNumber.
  ///
  /// In de, this message translates to:
  /// **'Bitte geben Sie eine gültige Zahl ein'**
  String get pleaseEnterValidNumber;

  /// No description provided for @pleaseSelectAccountType.
  ///
  /// In de, this message translates to:
  /// **'Bitte wählen Sie einen Kontotyp aus'**
  String get pleaseSelectAccountType;

  /// Untertitel für Kategorien
  ///
  /// In de, this message translates to:
  /// **'Verwalten Sie Ihre Kategorien'**
  String get manageYourCategories;

  /// Button zum Erstellen einer Kategorie
  ///
  /// In de, this message translates to:
  /// **'Kategorie erstellen'**
  String get createCategory;

  /// Dialog-Titel zum Bearbeiten einer Kategorie
  ///
  /// In de, this message translates to:
  /// **'Kategorie bearbeiten'**
  String get editCategory;

  /// Dialog-Titel zum Löschen einer Kategorie
  ///
  /// In de, this message translates to:
  /// **'Kategorie löschen'**
  String get deleteCategory;

  /// Bestätigungsdialog zum Löschen einer Kategorie
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie die Kategorie \'{name}\' wirklich löschen?'**
  String deleteCategoryConfirmation(String name);

  /// Leerer Zustand bei Kategorien
  ///
  /// In de, this message translates to:
  /// **'Noch keine Kategorien'**
  String get noCategoriesYet;

  /// Hinweistext für erste Kategorie
  ///
  /// In de, this message translates to:
  /// **'Erstellen Sie Ihre erste Kategorie, um zu beginnen'**
  String get createYourFirstCategory;

  /// Label für Eltern-Kategorie
  ///
  /// In de, this message translates to:
  /// **'Übergeordnete Kategorie'**
  String get parentCategory;

  /// Option für keine Eltern-Kategorie
  ///
  /// In de, this message translates to:
  /// **'Keine (Hauptkategorie)'**
  String get noParent;

  /// Label für Icon-Auswahl
  ///
  /// In de, this message translates to:
  /// **'Symbol'**
  String get icon;

  /// Label für Farb-Auswahl
  ///
  /// In de, this message translates to:
  /// **'Farbe'**
  String get color;

  /// Ausgaben-Tab
  ///
  /// In de, this message translates to:
  /// **'Ausgaben'**
  String get expenses;

  /// Einnahmen-Tab
  ///
  /// In de, this message translates to:
  /// **'Einnahmen'**
  String get income;

  /// Untertitel für Buchungen
  ///
  /// In de, this message translates to:
  /// **'Verwalten Sie Ihre Buchungen'**
  String get manageYourTransactions;

  /// Button zum Erstellen einer Buchung
  ///
  /// In de, this message translates to:
  /// **'Buchung erstellen'**
  String get createTransaction;

  /// Dialog-Titel zum Bearbeiten einer Buchung
  ///
  /// In de, this message translates to:
  /// **'Buchung bearbeiten'**
  String get editTransaction;

  /// Dialog-Titel zum Löschen einer Buchung
  ///
  /// In de, this message translates to:
  /// **'Buchung löschen'**
  String get deleteTransaction;

  /// Bestätigungsdialog zum Löschen einer Buchung
  ///
  /// In de, this message translates to:
  /// **'Möchten Sie diese Buchung wirklich löschen?'**
  String get deleteTransactionConfirmation;

  /// Leerer Zustand bei Buchungen
  ///
  /// In de, this message translates to:
  /// **'Noch keine Buchungen'**
  String get noTransactionsYet;

  /// Hinweistext für erste Buchung
  ///
  /// In de, this message translates to:
  /// **'Erstellen Sie Ihre erste Buchung, um zu beginnen'**
  String get createYourFirstTransaction;

  /// Label für Betrag
  ///
  /// In de, this message translates to:
  /// **'Betrag'**
  String get amount;

  /// Label für Konto
  ///
  /// In de, this message translates to:
  /// **'Konto'**
  String get account;

  /// Label für Zielkonto bei Umbuchungen
  ///
  /// In de, this message translates to:
  /// **'Zielkonto'**
  String get toAccount;

  /// Label für Kategorie
  ///
  /// In de, this message translates to:
  /// **'Kategorie'**
  String get category;

  /// Label für Datum
  ///
  /// In de, this message translates to:
  /// **'Datum'**
  String get date;

  /// Label für Zahlungsempfänger
  ///
  /// In de, this message translates to:
  /// **'Empfänger'**
  String get payee;

  /// Label für Beschreibung
  ///
  /// In de, this message translates to:
  /// **'Beschreibung'**
  String get description;

  /// Label für Umbuchung
  ///
  /// In de, this message translates to:
  /// **'Umbuchung'**
  String get transfer;

  /// Validierungsmeldung für Kontoauswahl
  ///
  /// In de, this message translates to:
  /// **'Bitte wählen Sie ein Konto aus'**
  String get pleaseSelectAccount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
