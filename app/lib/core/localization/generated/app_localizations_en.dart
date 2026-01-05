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

  @override
  String get manageYourCategories => 'Manage your categories';

  @override
  String get createCategory => 'Create Category';

  @override
  String get editCategory => 'Edit Category';

  @override
  String get deleteCategory => 'Delete Category';

  @override
  String deleteCategoryConfirmation(String name) {
    return 'Are you sure you want to delete the category \'$name\'?';
  }

  @override
  String get noCategoriesYet => 'No categories yet';

  @override
  String get createYourFirstCategory =>
      'Create your first category to get started';

  @override
  String get parentCategory => 'Parent Category';

  @override
  String get noParent => 'No parent (main category)';

  @override
  String get icon => 'Icon';

  @override
  String get color => 'Color';

  @override
  String get expenses => 'Expenses';

  @override
  String get income => 'Income';

  @override
  String get manageYourTransactions => 'Manage your transactions';

  @override
  String get createTransaction => 'Create Transaction';

  @override
  String get editTransaction => 'Edit Transaction';

  @override
  String get deleteTransaction => 'Delete Transaction';

  @override
  String get deleteTransactionConfirmation =>
      'Are you sure you want to delete this transaction?';

  @override
  String get noTransactionsYet => 'No transactions yet';

  @override
  String get createYourFirstTransaction =>
      'Create your first transaction to get started';

  @override
  String get amount => 'Amount';

  @override
  String get account => 'Account';

  @override
  String get toAccount => 'To Account';

  @override
  String get category => 'Category';

  @override
  String get date => 'Date';

  @override
  String get payee => 'Payee';

  @override
  String get description => 'Description';

  @override
  String get transfer => 'Transfer';

  @override
  String get pleaseSelectAccount => 'Please select an account';

  @override
  String get expense => 'Expense';

  @override
  String get fromAccount => 'From Account';

  @override
  String get pleaseSelectCategory => 'Please select a category';

  @override
  String get pleaseEnterDescription => 'Please enter a description';

  @override
  String get pleaseEnterValidAmount => 'Please enter a valid amount';

  @override
  String get pleaseSelectToAccount => 'Please select a destination account';

  @override
  String get recurringTransactions => 'Recurring Transactions';

  @override
  String get createRecurringTransaction => 'Create Recurring Transaction';

  @override
  String get editRecurringTransaction => 'Edit Recurring Transaction';

  @override
  String get deleteRecurringTransaction => 'Delete Recurring Transaction';

  @override
  String get deleteRecurringTransactionConfirm =>
      'Are you sure you want to delete this recurring transaction?';

  @override
  String get noRecurringTransactions => 'No recurring transactions yet';

  @override
  String get interval => 'Interval';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get biweekly => 'Every 2 weeks';

  @override
  String get monthly => 'Monthly';

  @override
  String get quarterly => 'Quarterly';

  @override
  String get semiannually => 'Semi-annually';

  @override
  String get yearly => 'Yearly';

  @override
  String get dayOfMonth => 'Day of Month';

  @override
  String get dayOfMonthHelper => 'Day of the month (1-31)';

  @override
  String get pleaseEnterDayOfMonth => 'Please enter a day';

  @override
  String get pleaseEnterValidDay => 'Please enter a valid day (1-31)';

  @override
  String get startDate => 'Start Date';

  @override
  String get endDate => 'End Date';

  @override
  String get noEndDate => 'No end date';

  @override
  String get until => 'Until';

  @override
  String get nextDue => 'Next due';

  @override
  String get ended => 'Ended';

  @override
  String get active => 'Active';

  @override
  String get noBudgetsYet => 'No budgets yet';

  @override
  String get createYourFirstBudget =>
      'Create your first budget to track spending';

  @override
  String get createBudget => 'Create Budget';

  @override
  String get editBudget => 'Edit Budget';

  @override
  String get deleteBudget => 'Delete Budget';

  @override
  String get deleteBudgetConfirmation =>
      'Are you sure you want to delete this budget?';

  @override
  String get actual => 'Actual';

  @override
  String get budget => 'Budget';

  @override
  String get remaining => 'Remaining';

  @override
  String get exceeded => 'Exceeded';

  @override
  String get period => 'Period';

  @override
  String get allCategories => 'All categories';

  @override
  String get allAccounts => 'All accounts';

  @override
  String get budgetCategoryHelper => 'Leave empty for all categories';

  @override
  String get budgetAccountHelper => 'Leave empty for all accounts';
}
