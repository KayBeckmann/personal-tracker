import '../../data/database/daos/transactions_dao.dart';
import '../../data/database/tables/transactions_table.dart';
import '../entities/transaction.dart';

/// Repository-Interface für Buchungen
abstract class TransactionRepository {
  /// Gibt alle Buchungen zurück
  Future<List<Transaction>> getAllTransactions({
    TransactionFilter? filter,
  });

  /// Stream aller Buchungen
  Stream<List<Transaction>> watchAllTransactions({
    TransactionFilter? filter,
  });

  /// Gibt eine einzelne Buchung zurück
  Future<Transaction?> getTransactionById(int id);

  /// Stream einer einzelnen Buchung
  Stream<Transaction?> watchTransactionById(int id);

  /// Gibt Vorlagen zurück
  Future<List<Transaction>> getTemplates();

  /// Stream der Vorlagen
  Stream<List<Transaction>> watchTemplates();

  /// Gibt geplante Buchungen zurück
  Future<List<Transaction>> getPlannedTransactions();

  /// Stream der geplanten Buchungen
  Stream<List<Transaction>> watchPlannedTransactions();

  /// Gibt Buchungen für ein Konto zurück
  Future<List<Transaction>> getTransactionsByAccount(int accountId);

  /// Gibt Buchungen für eine Kategorie zurück
  Future<List<Transaction>> getTransactionsByCategory(int categoryId);

  /// Erstellt eine neue Buchung
  Future<int> createTransaction({
    required TransactionType type,
    required int accountId,
    int? toAccountId,
    int? categoryId,
    required double amount,
    String currency = 'EUR',
    required DateTime date,
    String? payee,
    String? description,
    bool isPlanned = false,
    bool isTemplate = false,
    String? templateName,
    bool isBooked = true,
  });

  /// Aktualisiert eine Buchung
  Future<void> updateTransaction(Transaction transaction);

  /// Löscht eine Buchung
  Future<void> deleteTransaction(int id);

  /// Erstellt eine Buchung aus einer Vorlage
  Future<int> createFromTemplate(int templateId, DateTime date);

  /// Bucht eine geplante Buchung
  Future<bool> bookPlannedTransaction(int id);
}
