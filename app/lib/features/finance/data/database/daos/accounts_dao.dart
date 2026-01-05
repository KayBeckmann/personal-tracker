import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../tables/accounts_table.dart';
import '../tables/account_types_table.dart';

part 'accounts_dao.g.dart';

/// DAO für Konten
///
/// Verwaltet CRUD-Operationen für Konten.
@DriftAccessor(tables: [AccountsTable, AccountTypesTable])
class AccountsDao extends DatabaseAccessor<AppDatabase>
    with _$AccountsDaoMixin {
  AccountsDao(super.db);

  /// Gibt alle Konten zurück, sortiert nach sortOrder
  Future<List<AccountData>> getAllAccounts() {
    return (select(accountsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Gibt Konten gruppiert nach Typ zurück
  Future<Map<AccountTypeData, List<AccountData>>> getAccountsGroupedByType() async {
    final accounts = await getAllAccounts();
    final types = await db.accountTypesDao.getAllAccountTypes();

    final Map<AccountTypeData, List<AccountData>> grouped = {};

    for (final type in types) {
      final accountsForType = accounts.where((a) => a.accountTypeId == type.id).toList();
      if (accountsForType.isNotEmpty) {
        grouped[type] = accountsForType;
      }
    }

    return grouped;
  }

  /// Gibt ein Konto anhand seiner ID zurück
  Future<AccountData?> getAccountById(int id) {
    return (select(accountsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Gibt das Default-Konto zurück
  Future<AccountData?> getDefaultAccount() {
    return (select(accountsTable)..where((t) => t.isDefault.equals(true)))
        .getSingleOrNull();
  }

  /// Gibt alle Konten zurück, die in der Übersicht angezeigt werden sollen
  Future<List<AccountData>> getAccountsForOverview() {
    return (select(accountsTable)
          ..where((t) => t.includeInOverview.equals(true))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Erstellt ein neues Konto
  Future<int> createAccount(AccountsTableCompanion account) async {
    // Wenn das neue Konto als Default markiert ist, entferne Default-Flag von anderen
    if (account.isDefault.present && account.isDefault.value == true) {
      await _clearDefaultFlag();
    }
    return into(accountsTable).insert(account);
  }

  /// Aktualisiert ein Konto
  Future<bool> updateAccount(AccountData account) async {
    // Wenn dieses Konto als Default markiert wird, entferne Default-Flag von anderen
    if (account.isDefault) {
      await _clearDefaultFlag(exceptId: account.id);
    }
    return update(accountsTable).replace(account);
  }

  /// Löscht ein Konto
  Future<int> deleteAccount(int id) {
    return (delete(accountsTable)..where((t) => t.id.equals(id))).go();
  }

  /// Beobachtet alle Konten
  Stream<List<AccountData>> watchAllAccounts() {
    return (select(accountsTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  /// Beobachtet ein einzelnes Konto
  Stream<AccountData?> watchAccountById(int id) {
    return (select(accountsTable)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Beobachtet Konten für die Übersicht
  Stream<List<AccountData>> watchAccountsForOverview() {
    return (select(accountsTable)
          ..where((t) => t.includeInOverview.equals(true))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  /// Entfernt das Default-Flag von allen Konten (außer optionalem excludeId)
  Future<void> _clearDefaultFlag({int? exceptId}) async {
    final query = update(accountsTable)
      ..where((t) => t.isDefault.equals(true));

    if (exceptId != null) {
      query.where((t) => t.id.equals(exceptId).not());
    }

    await query.write(const AccountsTableCompanion(
      isDefault: Value(false),
    ));
  }
}
