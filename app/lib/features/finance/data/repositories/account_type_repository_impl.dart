import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/repositories/account_type_repository.dart';
import '../mappers/account_type_mapper.dart';

@LazySingleton(as: AccountTypeRepository)
class AccountTypeRepositoryImpl implements AccountTypeRepository {
  AccountTypeRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<AccountType>> getAllAccountTypes() async {
    final data = await _db.accountTypesDao.getAllAccountTypes();
    return data.map((e) => e.toEntity()).toList();
  }

  @override
  Future<AccountType?> getAccountTypeById(int id) async {
    final data = await _db.accountTypesDao.getAccountTypeById(id);
    return data?.toEntity();
  }

  @override
  Future<int> createAccountType({
    required String name,
    required String icon,
    int sortOrder = 0,
    bool isDefault = false,
  }) {
    return _db.accountTypesDao.createAccountType(
      AccountTypesTableCompanion.insert(
        name: name,
        icon: icon,
        sortOrder: Value(sortOrder),
        isDefault: Value(isDefault),
      ),
    );
  }

  @override
  Future<void> updateAccountType(AccountType accountType) async {
    await _db.accountTypesDao.updateAccountType(accountType.toData());
  }

  @override
  Future<void> deleteAccountType(int id) async {
    await _db.accountTypesDao.deleteAccountType(id);
  }

  @override
  Stream<List<AccountType>> watchAllAccountTypes() {
    return _db.accountTypesDao
        .watchAllAccountTypes()
        .map((list) => list.map((e) => e.toEntity()).toList());
  }

  @override
  Stream<AccountType?> watchAccountTypeById(int id) {
    return _db.accountTypesDao
        .watchAccountTypeById(id)
        .map((data) => data?.toEntity());
  }
}
