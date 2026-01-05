import 'package:injectable/injectable.dart';

import '../repositories/account_repository.dart';

@injectable
class DeleteAccount {
  DeleteAccount(this._repository);

  final AccountRepository _repository;

  Future<void> call(int id) => _repository.deleteAccount(id);
}
