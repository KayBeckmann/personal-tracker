import 'package:injectable/injectable.dart';

import '../entities/account_type.dart';
import '../repositories/account_type_repository.dart';

@injectable
class GetAllAccountTypes {
  GetAllAccountTypes(this._repository);

  final AccountTypeRepository _repository;

  Future<List<AccountType>> call() => _repository.getAllAccountTypes();

  Stream<List<AccountType>> watch() => _repository.watchAllAccountTypes();
}
