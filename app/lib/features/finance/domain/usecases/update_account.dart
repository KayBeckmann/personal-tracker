import 'package:injectable/injectable.dart';

import '../entities/account.dart';
import '../repositories/account_repository.dart';

@injectable
class UpdateAccount {
  UpdateAccount(this._repository);

  final AccountRepository _repository;

  Future<void> call(Account account) => _repository.updateAccount(account);
}
