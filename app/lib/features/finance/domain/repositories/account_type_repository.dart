import '../entities/account_type.dart';

/// Repository Interface für Kontotypen
abstract class AccountTypeRepository {
  /// Gibt alle Kontotypen zurück
  Future<List<AccountType>> getAllAccountTypes();

  /// Gibt einen Kontotyp anhand seiner ID zurück
  Future<AccountType?> getAccountTypeById(int id);

  /// Erstellt einen neuen Kontotyp
  Future<int> createAccountType({
    required String name,
    required String icon,
    int sortOrder = 0,
    bool isDefault = false,
  });

  /// Aktualisiert einen Kontotyp
  Future<void> updateAccountType(AccountType accountType);

  /// Löscht einen Kontotyp
  Future<void> deleteAccountType(int id);

  /// Beobachtet alle Kontotypen
  Stream<List<AccountType>> watchAllAccountTypes();

  /// Beobachtet einen einzelnen Kontotyp
  Stream<AccountType?> watchAccountTypeById(int id);
}
