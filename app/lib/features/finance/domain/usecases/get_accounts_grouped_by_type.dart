import 'package:injectable/injectable.dart';

import '../entities/account.dart';
import '../entities/account_type.dart';
import '../repositories/account_repository.dart';

@injectable
class GetAccountsGroupedByType {
  GetAccountsGroupedByType(this._repository);

  final AccountRepository _repository;

  Future<Map<AccountType, List<Account>>> call() =>
      _repository.getAccountsGroupedByType();
}
