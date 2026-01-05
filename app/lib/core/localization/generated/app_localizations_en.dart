// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Personal Tracker';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get finance => 'Finance';

  @override
  String get finances => 'Finances';

  @override
  String get householdBook => 'Household Book';

  @override
  String get notes => 'Notes';

  @override
  String get tasks => 'Tasks';

  @override
  String get habits => 'Habits';

  @override
  String get journal => 'Journal';

  @override
  String get timeTracking => 'Time Tracking';

  @override
  String get settings => 'Settings';

  @override
  String get design => 'Design';

  @override
  String get designSubtitle => 'Theme, colors, fonts';

  @override
  String get theme => 'Theme';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get lightTheme => 'Light';

  @override
  String get darkTheme => 'Dark';

  @override
  String get systemTheme => 'System Default';

  @override
  String get language => 'Language';

  @override
  String get languageSubtitle => 'Change application language';

  @override
  String get modules => 'Modules';

  @override
  String get modulesSubtitle => 'Enable/disable features';

  @override
  String get about => 'About';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get german => 'Deutsch';

  @override
  String get english => 'English';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get cancel => 'Cancel';

  @override
  String get ok => 'OK';

  @override
  String get scaffoldBeingBuilt => 'Scaffold is being built';

  @override
  String milestone(String number) {
    return 'Milestone $number';
  }

  @override
  String implementedInMilestone(String number) {
    return 'Will be implemented in Milestone $number';
  }

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get manageYourFinances => 'Manage your finances';

  @override
  String get accounts => 'Accounts';

  @override
  String get transactions => 'Transactions';

  @override
  String get categories => 'Categories';

  @override
  String get budgets => 'Budgets';

  @override
  String get manageYourAccounts => 'Manage your accounts';

  @override
  String get noAccountsYet => 'No accounts yet';

  @override
  String get createYourFirstAccount =>
      'Create your first account to get started';

  @override
  String get createAccount => 'Create Account';

  @override
  String get editAccount => 'Edit Account';

  @override
  String get deleteAccount => 'Delete Account';

  @override
  String deleteAccountConfirmation(Object name) {
    return 'Are you sure you want to delete the account \'$name\'?';
  }

  @override
  String get name => 'Name';

  @override
  String get accountType => 'Account Type';

  @override
  String get initialBalance => 'Initial Balance';

  @override
  String get includeInOverview => 'Include in Overview';

  @override
  String get defaultAccount => 'Default Account';

  @override
  String get pleaseEnterName => 'Please enter a name';

  @override
  String get pleaseEnterAmount => 'Please enter an amount';

  @override
  String get pleaseEnterValidNumber => 'Please enter a valid number';

  @override
  String get pleaseSelectAccountType => 'Please select an account type';
}
