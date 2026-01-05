import '../entities/account.dart';
import '../entities/account_type.dart';

/// Repository Interface für Konten
abstract class AccountRepository {
  /// Gibt alle Konten zurück
  Future<List<Account>> getAllAccounts();

  /// Gibt Konten gruppiert nach Typ zurück
  Future<Map<AccountType, List<Account>>> getAccountsGroupedByType();

  /// Gibt ein Konto anhand seiner ID zurück
  Future<Account?> getAccountById(int id);

  /// Gibt das Default-Konto zurück
  Future<Account?> getDefaultAccount();

  /// Gibt alle Konten zurück, die in der Übersicht angezeigt werden sollen
  Future<List<Account>> getAccountsForOverview();

  /// Erstellt ein neues Konto
  Future<int> createAccount({
    required int accountTypeId,
    required String name,
    String currency = 'EUR',
    double initialBalance = 0.0,
    bool includeInOverview = true,
    bool isDefault = false,
    String? color,
    String? notes,
    int sortOrder = 0,
  });

  /// Aktualisiert ein Konto
  Future<void> updateAccount(Account account);

  /// Löscht ein Konto
  Future<void> deleteAccount(int id);

  /// Berechnet den aktuellen Saldo eines Kontos
  Future<double> calculateBalance(int accountId);

  /// Berechnet den Gesamtsaldo aller Konten in der Übersicht
  Future<double> calculateTotalBalance();

  /// Beobachtet alle Konten
  Stream<List<Account>> watchAllAccounts();

  /// Beobachtet ein einzelnes Konto
  Stream<Account?> watchAccountById(int id);

  /// Beobachtet Konten für die Übersicht
  Stream<List<Account>> watchAccountsForOverview();
}
