import 'package:injectable/injectable.dart';

import '../repositories/account_repository.dart';

@injectable
class CreateAccount {
  CreateAccount(this._repository);

  final AccountRepository _repository;

  Future<int> call({
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
    return _repository.createAccount(
      accountTypeId: accountTypeId,
      name: name,
      currency: currency,
      initialBalance: initialBalance,
      includeInOverview: includeInOverview,
      isDefault: isDefault,
      color: color,
      notes: notes,
      sortOrder: sortOrder,
    );
  }
}
