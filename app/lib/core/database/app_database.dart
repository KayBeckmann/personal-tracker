import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../features/finance/data/database/daos/account_types_dao.dart';
import '../../features/finance/data/database/daos/accounts_dao.dart';
import '../../features/finance/data/database/tables/account_types_table.dart';
import '../../features/finance/data/database/tables/accounts_table.dart';
import '../../features/finance/data/database/tables/budgets_table.dart';
import '../../features/finance/data/database/tables/categories_table.dart';
import '../../features/finance/data/database/tables/recurring_transactions_table.dart';
import '../../features/finance/data/database/tables/transactions_table.dart';
import 'connection/connection.dart';
import 'daos/app_settings_dao.dart';
import 'tables/app_settings_table.dart';

part 'app_database.g.dart';

/// Haupt-Datenbank für Personal Tracker
///
/// Diese Datenbank enthält alle Tabellen für die verschiedenen Features.
/// Verwendet Drift für typsichere SQL-Queries und automatische Code-Generierung.
/// Unterstützt sowohl native Plattformen (SQLite) als auch Web (IndexedDB).
@lazySingleton
@DriftDatabase(
  tables: [
    // Core
    AppSettingsTable,
    // Finance
    AccountTypesTable,
    AccountsTable,
    CategoriesTable,
    TransactionsTable,
    RecurringTransactionsTable,
    BudgetsTable,
  ],
  daos: [
    // Core
    AppSettingsDao,
    // Finance
    AccountTypesDao,
    AccountsDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Für Tests kann eine In-Memory-Datenbank übergeben werden
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _insertDefaultData();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Migration von Schema 1 zu 2: Haushaltsbuch-Tabellen hinzufügen
          if (from < 2) {
            await m.createTable(accountTypesTable);
            await m.createTable(accountsTable);
            await m.createTable(categoriesTable);
            await m.createTable(transactionsTable);
            await m.createTable(recurringTransactionsTable);
            await m.createTable(budgetsTable);
            await _insertDefaultData();
          }
        },
      );

  /// Fügt Standard-Daten in die Datenbank ein
  Future<void> _insertDefaultData() async {
    // Standard-Kontotypen
    await accountTypesDao.createAccountType(
      AccountTypesTableCompanion.insert(
        name: 'Bargeld',
        icon: 'payments',
        sortOrder: Value(1),
        isDefault: Value(true),
      ),
    );

    await accountTypesDao.createAccountType(
      AccountTypesTableCompanion.insert(
        name: 'Bankkonto',
        icon: 'account_balance',
        sortOrder: Value(2),
        isDefault: Value(true),
      ),
    );

    await accountTypesDao.createAccountType(
      AccountTypesTableCompanion.insert(
        name: 'Depot',
        icon: 'trending_up',
        sortOrder: Value(3),
        isDefault: Value(true),
      ),
    );

    await accountTypesDao.createAccountType(
      AccountTypesTableCompanion.insert(
        name: 'Anlagewert',
        icon: 'savings',
        sortOrder: Value(4),
        isDefault: Value(true),
      ),
    );

    await accountTypesDao.createAccountType(
      AccountTypesTableCompanion.insert(
        name: 'Krypto',
        icon: 'currency_bitcoin',
        sortOrder: Value(5),
        isDefault: Value(true),
      ),
    );
  }
}
