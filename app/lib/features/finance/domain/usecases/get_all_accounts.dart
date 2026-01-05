import 'package:injectable/injectable.dart';

import '../entities/account.dart';
import '../repositories/account_repository.dart';

@injectable
class GetAllAccounts {
  GetAllAccounts(this._repository);

  final AccountRepository _repository;

  Future<List<Account>> call() => _repository.getAllAccounts();

  Stream<List<Account>> watch() => _repository.watchAllAccounts();
}
