// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/finance/data/repositories/account_repository_impl.dart'
    as _i460;
import '../../features/finance/data/repositories/account_type_repository_impl.dart'
    as _i44;
import '../../features/finance/data/repositories/budget_repository_impl.dart'
    as _i182;
import '../../features/finance/data/repositories/category_repository_impl.dart'
    as _i816;
import '../../features/finance/data/repositories/recurring_transaction_repository_impl.dart'
    as _i1031;
import '../../features/finance/data/repositories/transaction_repository_impl.dart'
    as _i1045;
import '../../features/finance/domain/repositories/account_repository.dart'
    as _i835;
import '../../features/finance/domain/repositories/account_type_repository.dart'
    as _i436;
import '../../features/finance/domain/repositories/budget_repository.dart'
    as _i348;
import '../../features/finance/domain/repositories/category_repository.dart'
    as _i228;
import '../../features/finance/domain/repositories/recurring_transaction_repository.dart'
    as _i943;
import '../../features/finance/domain/repositories/transaction_repository.dart'
    as _i761;
import '../../features/finance/domain/services/recurring_transaction_scheduler.dart'
    as _i292;
import '../../features/finance/domain/usecases/create_account.dart' as _i33;
import '../../features/finance/domain/usecases/create_budget.dart' as _i984;
import '../../features/finance/domain/usecases/create_category.dart' as _i24;
import '../../features/finance/domain/usecases/create_recurring_transaction.dart'
    as _i401;
import '../../features/finance/domain/usecases/create_transaction.dart'
    as _i781;
import '../../features/finance/domain/usecases/delete_account.dart' as _i615;
import '../../features/finance/domain/usecases/delete_budget.dart' as _i160;
import '../../features/finance/domain/usecases/delete_category.dart' as _i878;
import '../../features/finance/domain/usecases/delete_recurring_transaction.dart'
    as _i977;
import '../../features/finance/domain/usecases/delete_transaction.dart'
    as _i437;
import '../../features/finance/domain/usecases/get_account_balance.dart'
    as _i683;
import '../../features/finance/domain/usecases/get_accounts_grouped_by_type.dart'
    as _i74;
import '../../features/finance/domain/usecases/get_all_account_types.dart'
    as _i107;
import '../../features/finance/domain/usecases/get_all_accounts.dart' as _i1053;
import '../../features/finance/domain/usecases/get_all_budgets.dart' as _i776;
import '../../features/finance/domain/usecases/get_all_categories.dart'
    as _i936;
import '../../features/finance/domain/usecases/get_all_recurring_transactions.dart'
    as _i479;
import '../../features/finance/domain/usecases/get_all_transactions.dart'
    as _i1038;
import '../../features/finance/domain/usecases/get_categories_by_type.dart'
    as _i277;
import '../../features/finance/domain/usecases/get_main_categories.dart'
    as _i1002;
import '../../features/finance/domain/usecases/get_planned_transactions.dart'
    as _i402;
import '../../features/finance/domain/usecases/get_projected_end_of_month_capital.dart'
    as _i939;
import '../../features/finance/domain/usecases/get_subcategories.dart' as _i630;
import '../../features/finance/domain/usecases/get_templates.dart' as _i589;
import '../../features/finance/domain/usecases/get_total_capital.dart' as _i320;
import '../../features/finance/domain/usecases/get_upcoming_recurring_transactions.dart'
    as _i511;
import '../../features/finance/domain/usecases/process_due_recurring_transactions.dart'
    as _i455;
import '../../features/finance/domain/usecases/update_account.dart' as _i255;
import '../../features/finance/domain/usecases/update_budget.dart' as _i108;
import '../../features/finance/domain/usecases/update_category.dart' as _i511;
import '../../features/finance/domain/usecases/update_recurring_transaction.dart'
    as _i326;
import '../../features/finance/domain/usecases/update_transaction.dart'
    as _i306;
import '../../features/settings/data/repositories/settings_repository_impl.dart'
    as _i955;
import '../../features/settings/domain/repositories/settings_repository.dart'
    as _i674;
import '../../features/settings/domain/usecases/get_locale.dart' as _i514;
import '../../features/settings/domain/usecases/get_theme_mode.dart' as _i867;
import '../../features/settings/domain/usecases/set_locale.dart' as _i729;
import '../../features/settings/domain/usecases/set_theme_mode.dart' as _i743;
import '../database/app_database.dart' as _i982;
import '../database/daos/app_settings_dao.dart' as _i16;
import '../navigation/app_router.dart' as _i630;
import '../navigation/module_service.dart' as _i261;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i982.AppDatabase>(() => _i982.AppDatabase());
    gh.lazySingleton<_i630.AppRouter>(() => _i630.AppRouter());
    gh.lazySingleton<_i436.AccountTypeRepository>(
      () => _i44.AccountTypeRepositoryImpl(gh<_i982.AppDatabase>()),
    );
    gh.lazySingleton<_i835.AccountRepository>(
      () => _i460.AccountRepositoryImpl(gh<_i982.AppDatabase>()),
    );
    gh.lazySingleton<_i943.RecurringTransactionRepository>(
      () => _i1031.RecurringTransactionRepositoryImpl(gh<_i982.AppDatabase>()),
    );
    gh.lazySingleton<_i228.CategoryRepository>(
      () => _i816.CategoryRepositoryImpl(gh<_i982.AppDatabase>()),
    );
    gh.lazySingleton<_i320.GetTotalCapital>(
      () => _i320.GetTotalCapital(gh<_i835.AccountRepository>()),
    );
    gh.factory<_i33.CreateAccount>(
      () => _i33.CreateAccount(gh<_i835.AccountRepository>()),
    );
    gh.factory<_i615.DeleteAccount>(
      () => _i615.DeleteAccount(gh<_i835.AccountRepository>()),
    );
    gh.factory<_i683.GetAccountBalance>(
      () => _i683.GetAccountBalance(gh<_i835.AccountRepository>()),
    );
    gh.factory<_i74.GetAccountsGroupedByType>(
      () => _i74.GetAccountsGroupedByType(gh<_i835.AccountRepository>()),
    );
    gh.factory<_i1053.GetAllAccounts>(
      () => _i1053.GetAllAccounts(gh<_i835.AccountRepository>()),
    );
    gh.factory<_i255.UpdateAccount>(
      () => _i255.UpdateAccount(gh<_i835.AccountRepository>()),
    );
    gh.lazySingleton<_i348.BudgetRepository>(
      () => _i182.BudgetRepositoryImpl(gh<_i982.AppDatabase>()),
    );
    gh.lazySingleton<_i761.TransactionRepository>(
      () => _i1045.TransactionRepositoryImpl(gh<_i982.AppDatabase>()),
    );
    gh.lazySingleton<_i984.CreateBudget>(
      () => _i984.CreateBudget(gh<_i348.BudgetRepository>()),
    );
    gh.lazySingleton<_i160.DeleteBudget>(
      () => _i160.DeleteBudget(gh<_i348.BudgetRepository>()),
    );
    gh.lazySingleton<_i776.GetAllBudgets>(
      () => _i776.GetAllBudgets(gh<_i348.BudgetRepository>()),
    );
    gh.lazySingleton<_i108.UpdateBudget>(
      () => _i108.UpdateBudget(gh<_i348.BudgetRepository>()),
    );
    gh.factory<_i107.GetAllAccountTypes>(
      () => _i107.GetAllAccountTypes(gh<_i436.AccountTypeRepository>()),
    );
    gh.lazySingleton<_i16.AppSettingsDao>(
      () => _i16.AppSettingsDao(gh<_i982.AppDatabase>()),
    );
    gh.lazySingleton<_i939.GetProjectedEndOfMonthCapital>(
      () => _i939.GetProjectedEndOfMonthCapital(
        gh<_i320.GetTotalCapital>(),
        gh<_i761.TransactionRepository>(),
        gh<_i943.RecurringTransactionRepository>(),
      ),
    );
    gh.lazySingleton<_i24.CreateCategory>(
      () => _i24.CreateCategory(gh<_i228.CategoryRepository>()),
    );
    gh.lazySingleton<_i878.DeleteCategory>(
      () => _i878.DeleteCategory(gh<_i228.CategoryRepository>()),
    );
    gh.lazySingleton<_i936.GetAllCategories>(
      () => _i936.GetAllCategories(gh<_i228.CategoryRepository>()),
    );
    gh.lazySingleton<_i277.GetCategoriesByType>(
      () => _i277.GetCategoriesByType(gh<_i228.CategoryRepository>()),
    );
    gh.lazySingleton<_i1002.GetMainCategories>(
      () => _i1002.GetMainCategories(gh<_i228.CategoryRepository>()),
    );
    gh.lazySingleton<_i630.GetSubcategories>(
      () => _i630.GetSubcategories(gh<_i228.CategoryRepository>()),
    );
    gh.lazySingleton<_i511.UpdateCategory>(
      () => _i511.UpdateCategory(gh<_i228.CategoryRepository>()),
    );
    gh.lazySingleton<_i781.CreateTransaction>(
      () => _i781.CreateTransaction(gh<_i761.TransactionRepository>()),
    );
    gh.lazySingleton<_i437.DeleteTransaction>(
      () => _i437.DeleteTransaction(gh<_i761.TransactionRepository>()),
    );
    gh.lazySingleton<_i1038.GetAllTransactions>(
      () => _i1038.GetAllTransactions(gh<_i761.TransactionRepository>()),
    );
    gh.lazySingleton<_i402.GetPlannedTransactions>(
      () => _i402.GetPlannedTransactions(gh<_i761.TransactionRepository>()),
    );
    gh.lazySingleton<_i589.GetTemplates>(
      () => _i589.GetTemplates(gh<_i761.TransactionRepository>()),
    );
    gh.lazySingleton<_i306.UpdateTransaction>(
      () => _i306.UpdateTransaction(gh<_i761.TransactionRepository>()),
    );
    gh.lazySingleton<_i401.CreateRecurringTransaction>(
      () => _i401.CreateRecurringTransaction(
        gh<_i943.RecurringTransactionRepository>(),
      ),
    );
    gh.lazySingleton<_i977.DeleteRecurringTransaction>(
      () => _i977.DeleteRecurringTransaction(
        gh<_i943.RecurringTransactionRepository>(),
      ),
    );
    gh.lazySingleton<_i479.GetAllRecurringTransactions>(
      () => _i479.GetAllRecurringTransactions(
        gh<_i943.RecurringTransactionRepository>(),
      ),
    );
    gh.lazySingleton<_i511.GetUpcomingRecurringTransactions>(
      () => _i511.GetUpcomingRecurringTransactions(
        gh<_i943.RecurringTransactionRepository>(),
      ),
    );
    gh.lazySingleton<_i326.UpdateRecurringTransaction>(
      () => _i326.UpdateRecurringTransaction(
        gh<_i943.RecurringTransactionRepository>(),
      ),
    );
    gh.lazySingleton<_i455.ProcessDueRecurringTransactions>(
      () => _i455.ProcessDueRecurringTransactions(
        gh<_i943.RecurringTransactionRepository>(),
        gh<_i761.TransactionRepository>(),
      ),
    );
    gh.lazySingleton<_i292.RecurringTransactionScheduler>(
      () => _i292.RecurringTransactionScheduler(
        gh<_i455.ProcessDueRecurringTransactions>(),
      ),
    );
    gh.lazySingleton<_i674.SettingsRepository>(
      () => _i955.SettingsRepositoryImpl(gh<_i16.AppSettingsDao>()),
    );
    gh.lazySingleton<_i261.ModuleService>(
      () => _i261.ModuleService(gh<_i674.SettingsRepository>()),
    );
    gh.factory<_i514.GetLocale>(
      () => _i514.GetLocale(gh<_i674.SettingsRepository>()),
    );
    gh.factory<_i867.GetThemeMode>(
      () => _i867.GetThemeMode(gh<_i674.SettingsRepository>()),
    );
    gh.factory<_i729.SetLocale>(
      () => _i729.SetLocale(gh<_i674.SettingsRepository>()),
    );
    gh.factory<_i743.SetThemeMode>(
      () => _i743.SetThemeMode(gh<_i674.SettingsRepository>()),
    );
    return this;
  }
}
