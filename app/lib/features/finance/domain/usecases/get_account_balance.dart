import 'package:injectable/injectable.dart';

import '../repositories/account_repository.dart';

@injectable
class GetAccountBalance {
  GetAccountBalance(this._repository);

  final AccountRepository _repository;

  Future<double> call(int accountId) =>
      _repository.calculateBalance(accountId);
}
