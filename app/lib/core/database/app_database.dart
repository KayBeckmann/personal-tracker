import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../features/finance/data/database/daos/account_types_dao.dart';
import '../../features/finance/data/database/daos/accounts_dao.dart';
import '../../features/finance/data/database/daos/budgets_dao.dart';
import '../../features/finance/data/database/daos/categories_dao.dart';
import '../../features/finance/data/database/daos/recurring_transactions_dao.dart';
import '../../features/finance/data/database/daos/transactions_dao.dart';
import '../../features/finance/data/database/tables/account_types_table.dart';
import '../../features/finance/data/database/tables/accounts_table.dart';
import '../../features/finance/data/database/tables/budgets_table.dart';
import '../../features/finance/data/database/tables/categories_table.dart';
import '../../features/finance/data/database/tables/recurring_transactions_table.dart';
import '../../features/finance/data/database/tables/transactions_table.dart';
import '../../features/notes/data/database/daos/notes_dao.dart';
import '../../features/notes/data/database/tables/note_tags_table.dart';
import '../../features/notes/data/database/tables/notes_table.dart';
import '../../features/notes/data/database/tables/tags_table.dart';
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
    // Notes
    NotesTable,
    TagsTable,
    NoteTagsTable,
  ],
  daos: [
    // Core
    AppSettingsDao,
    // Finance
    AccountTypesDao,
    AccountsDao,
    CategoriesDao,
    TransactionsDao,
    RecurringTransactionsDao,
    BudgetsDao,
    // Notes
    NotesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openConnection());

  /// Für Tests kann eine In-Memory-Datenbank übergeben werden
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

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
          // Migration von Schema 2 zu 3: Notizen-Tabellen hinzufügen
          if (from < 3) {
            await m.createTable(notesTable);
            await m.createTable(tagsTable);
            await m.createTable(noteTagsTable);
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

    // Standard-Kategorien: Ausgaben
    await categoriesDao.createCategory(
      CategoriesTableCompanion.insert(
        name: 'Wohnen',
        type: CategoryType.expense,
        icon: 'home',
        sortOrder: Value(1),
        isDefault: Value(true),
      ),
    );

    await categoriesDao.createCategory(
      CategoriesTableCompanion.insert(
        name: 'Lebensmittel',
        type: CategoryType.expense,
        icon: 'shopping_cart',
        sortOrder: Value(2),
        isDefault: Value(true),
      ),
    );

    await categoriesDao.createCategory(
      CategoriesTableCompanion.insert(
        name: 'Mobilität',
        type: CategoryType.expense,
        icon: 'directions_car',
        sortOrder: Value(3),
        isDefault: Value(true),
      ),
    );

    await categoriesDao.createCategory(
      CategoriesTableCompanion.insert(
        name: 'Freizeit & Unterhaltung',
        type: CategoryType.expense,
        icon: 'movie',
        sortOrder: Value(4),
        isDefault: Value(true),
      ),
    );

    await categoriesDao.createCategory(
      CategoriesTableCompanion.insert(
        name: 'Gesundheit',
        type: CategoryType.expense,
        icon: 'local_hospital',
        sortOrder: Value(5),
        isDefault: Value(true),
      ),
    );

    await categoriesDao.createCategory(
      CategoriesTableCompanion.insert(
        name: 'Versicherungen',
        type: CategoryType.expense,
        icon: 'security',
        sortOrder: Value(6),
        isDefault: Value(true),
      ),
    );

    await categoriesDao.createCategory(
      CategoriesTableCompanion.insert(
        name: 'Kleidung',
        type: CategoryType.expense,
        icon: 'checkroom',
        sortOrder: Value(7),
        isDefault: Value(true),
      ),
    );

    await categoriesDao.createCategory(
      CategoriesTableCompanion.insert(
        name: 'Bildung',
        type: CategoryType.expense,
        icon: 'school',
        sortOrder: Value(8),
        isDefault: Value(true),
      ),
    );

    // Standard-Kategorien: Einnahmen
    await categoriesDao.createCategory(
      CategoriesTableCompanion.insert(
        name: 'Gehalt',
        type: CategoryType.income,
        icon: 'account_balance_wallet',
        sortOrder: Value(1),
        isDefault: Value(true),
      ),
    );

    await categoriesDao.createCategory(
      CategoriesTableCompanion.insert(
        name: 'Bonus',
        type: CategoryType.income,
        icon: 'card_giftcard',
        sortOrder: Value(2),
        isDefault: Value(true),
      ),
    );

    await categoriesDao.createCategory(
      CategoriesTableCompanion.insert(
        name: 'Investitionen',
        type: CategoryType.income,
        icon: 'trending_up',
        sortOrder: Value(3),
        isDefault: Value(true),
      ),
    );

    await categoriesDao.createCategory(
      CategoriesTableCompanion.insert(
        name: 'Geschenke',
        type: CategoryType.income,
        icon: 'redeem',
        sortOrder: Value(4),
        isDefault: Value(true),
      ),
    );

    await categoriesDao.createCategory(
      CategoriesTableCompanion.insert(
        name: 'Sonstiges',
        type: CategoryType.income,
        icon: 'more_horiz',
        sortOrder: Value(5),
        isDefault: Value(true),
      ),
    );
  }
}
