import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/repositories/account_repository.dart';
import '../mappers/account_mapper.dart';
import '../mappers/account_type_mapper.dart';

@LazySingleton(as: AccountRepository)
class AccountRepositoryImpl implements AccountRepository {
  AccountRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<Account>> getAllAccounts() async {
    final data = await _db.accountsDao.getAllAccounts();
    return data.map((e) => e.toEntity()).toList();
  }

  @override
  Future<Map<AccountType, List<Account>>> getAccountsGroupedByType() async {
    final data = await _db.accountsDao.getAccountsGroupedByType();
    final Map<AccountType, List<Account>> result = {};

    for (final entry in data.entries) {
      result[entry.key.toEntity()] =
          entry.value.map((e) => e.toEntity()).toList();
    }

    return result;
  }

  @override
  Future<Account?> getAccountById(int id) async {
    final data = await _db.accountsDao.getAccountById(id);
    return data?.toEntity();
  }

  @override
  Future<Account?> getDefaultAccount() async {
    final data = await _db.accountsDao.getDefaultAccount();
    return data?.toEntity();
  }

  @override
  Future<List<Account>> getAccountsForOverview() async {
    final data = await _db.accountsDao.getAccountsForOverview();
    return data.map((e) => e.toEntity()).toList();
  }

  @override
  Future<int> createAccount({
    required int accountTypeId,
    required String name,
    String currency = 'EUR',
    double initialBalance = 0.0,
    bool includeInOverview = true,
    bool isDefault = false,
    String? color,
    String? notes,
    int sortOrder = 0,
  }) {
    return _db.accountsDao.createAccount(
      AccountsTableCompanion.insert(
        accountTypeId: accountTypeId,
        name: name,
        currency: Value(currency),
        initialBalance: Value(initialBalance),
        includeInOverview: Value(includeInOverview),
        isDefault: Value(isDefault),
        color: Value(color),
        notes: Value(notes),
        sortOrder: Value(sortOrder),
      ),
    );
  }

  @override
  Future<void> updateAccount(Account account) async {
    await _db.accountsDao.updateAccount(account.toData());
  }

  @override
  Future<void> deleteAccount(int id) async {
    await _db.accountsDao.deleteAccount(id);
  }

  @override
  Future<double> calculateBalance(int accountId) async {
    final account = await _db.accountsDao.getAccountById(accountId);
    if (account == null) return 0.0;

    // Starte mit dem Anfangssaldo
    double balance = account.initialBalance;

    // TODO: Buchungen berücksichtigen (wird in späteren Meilensteinen implementiert)
    // Hier würden wir alle Transaktionen für dieses Konto abrufen und
    // - Einnahmen addieren
    // - Ausgaben subtrahieren
    // - Umbuchungen entsprechend berücksichtigen

    return balance;
  }

  @override
  Future<double> calculateTotalBalance() async {
    final accounts = await _db.accountsDao.getAccountsForOverview();
    double total = 0.0;

    for (final account in accounts) {
      total += await calculateBalance(account.id);
    }

    return total;
  }

  @override
  Stream<List<Account>> watchAllAccounts() {
    return _db.accountsDao
        .watchAllAccounts()
        .map((list) => list.map((e) => e.toEntity()).toList());
  }

  @override
  Stream<Account?> watchAccountById(int id) {
    return _db.accountsDao.watchAccountById(id).map((data) => data?.toEntity());
  }

  @override
  Stream<List<Account>> watchAccountsForOverview() {
    return _db.accountsDao
        .watchAccountsForOverview()
        .map((list) => list.map((e) => e.toEntity()).toList());
  }
}
