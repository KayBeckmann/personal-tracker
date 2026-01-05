import '../../../../core/database/app_database.dart';
import '../../domain/entities/account_type.dart';

/// Mapper zwischen AccountTypeData (Drift) und AccountType (Domain)
extension AccountTypeMapper on AccountTypeData {
  /// Konvertiert AccountTypeData zu AccountType
  AccountType toEntity() {
    return AccountType(
      id: id,
      name: name,
      icon: icon,
      sortOrder: sortOrder,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Mapper zwischen AccountType (Domain) und AccountTypeData (Drift)
extension AccountTypeEntityMapper on AccountType {
  /// Konvertiert AccountType zu AccountTypeData
  AccountTypeData toData() {
    return AccountTypeData(
      id: id,
      name: name,
      icon: icon,
      sortOrder: sortOrder,
      isDefault: isDefault,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
