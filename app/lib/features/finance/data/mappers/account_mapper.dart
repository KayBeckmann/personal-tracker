import '../../../../core/database/app_database.dart';
import '../../domain/entities/account.dart';

/// Mapper zwischen AccountData (Drift) und Account (Domain)
extension AccountMapper on AccountData {
  /// Konvertiert AccountData zu Account
  Account toEntity() {
    return Account(
      id: id,
      accountTypeId: accountTypeId,
      name: name,
      currency: currency,
      initialBalance: initialBalance,
      includeInOverview: includeInOverview,
      isDefault: isDefault,
      color: color,
      notes: notes,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Mapper zwischen Account (Domain) und AccountData (Drift)
extension AccountEntityMapper on Account {
  /// Konvertiert Account zu AccountData
  AccountData toData() {
    return AccountData(
      id: id,
      accountTypeId: accountTypeId,
      name: name,
      currency: currency,
      initialBalance: initialBalance,
      includeInOverview: includeInOverview,
      isDefault: isDefault,
      color: color,
      notes: notes,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
