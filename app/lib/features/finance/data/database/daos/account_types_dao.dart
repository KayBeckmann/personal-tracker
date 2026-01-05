import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../tables/account_types_table.dart';

part 'account_types_dao.g.dart';

/// DAO für Kontotypen
///
/// Verwaltet CRUD-Operationen für Kontotypen.
@DriftAccessor(tables: [AccountTypesTable])
class AccountTypesDao extends DatabaseAccessor<AppDatabase>
    with _$AccountTypesDaoMixin {
  AccountTypesDao(super.db);

  /// Gibt alle Kontotypen zurück, sortiert nach sortOrder
  Future<List<AccountTypeData>> getAllAccountTypes() {
    return (select(accountTypesTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .get();
  }

  /// Gibt einen Kontotyp anhand seiner ID zurück
  Future<AccountTypeData?> getAccountTypeById(int id) {
    return (select(accountTypesTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Erstellt einen neuen Kontotyp
  Future<int> createAccountType(AccountTypesTableCompanion accountType) {
    return into(accountTypesTable).insert(accountType);
  }

  /// Aktualisiert einen Kontotyp
  Future<bool> updateAccountType(AccountTypeData accountType) {
    return update(accountTypesTable).replace(accountType);
  }

  /// Löscht einen Kontotyp (nur wenn nicht als Default markiert)
  Future<int> deleteAccountType(int id) async {
    final accountType = await getAccountTypeById(id);
    if (accountType?.isDefault == true) {
      throw Exception('Default account types cannot be deleted');
    }
    return (delete(accountTypesTable)..where((t) => t.id.equals(id))).go();
  }

  /// Beobachtet alle Kontotypen
  Stream<List<AccountTypeData>> watchAllAccountTypes() {
    return (select(accountTypesTable)
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.name),
          ]))
        .watch();
  }

  /// Beobachtet einen einzelnen Kontotyp
  Stream<AccountTypeData?> watchAccountTypeById(int id) {
    return (select(accountTypesTable)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }
}
