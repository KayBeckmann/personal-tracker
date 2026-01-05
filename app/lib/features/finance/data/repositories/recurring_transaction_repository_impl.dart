import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/recurring_transaction.dart' as domain;
import '../../domain/repositories/recurring_transaction_repository.dart';
import '../database/tables/recurring_transactions_table.dart';
import '../database/tables/transactions_table.dart';
import '../mappers/recurring_transaction_mapper.dart';

/// Implementierung des RecurringTransactionRepository
@LazySingleton(as: RecurringTransactionRepository)
class RecurringTransactionRepositoryImpl
    implements RecurringTransactionRepository {
  RecurringTransactionRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<domain.RecurringTransaction>>
      getAllRecurringTransactions() async {
    final transactions =
        await _db.recurringTransactionsDao.getAllRecurringTransactions();
    return RecurringTransactionMapper.toEntityList(transactions);
  }

  @override
  Stream<List<domain.RecurringTransaction>>
      watchAllRecurringTransactions() {
    return _db.recurringTransactionsDao
        .watchAllRecurringTransactions()
        .map(RecurringTransactionMapper.toEntityList);
  }

  @override
  Future<List<domain.RecurringTransaction>>
      getActiveRecurringTransactions() async {
    final transactions =
        await _db.recurringTransactionsDao.getActiveRecurringTransactions();
    return RecurringTransactionMapper.toEntityList(transactions);
  }

  @override
  Stream<List<domain.RecurringTransaction>>
      watchActiveRecurringTransactions() {
    return _db.recurringTransactionsDao
        .watchActiveRecurringTransactions()
        .map(RecurringTransactionMapper.toEntityList);
  }

  @override
  Future<List<domain.RecurringTransaction>> getDueRecurringTransactions(
      DateTime date) async {
    final transactions =
        await _db.recurringTransactionsDao.getDueRecurringTransactions(date);
    return RecurringTransactionMapper.toEntityList(transactions);
  }

  @override
  Future<domain.RecurringTransaction?> getRecurringTransactionById(
      int id) async {
    final transaction =
        await _db.recurringTransactionsDao.getRecurringTransactionById(id);
    return transaction != null
        ? RecurringTransactionMapper.toEntity(transaction)
        : null;
  }

  @override
  Stream<domain.RecurringTransaction?> watchRecurringTransactionById(int id) {
    return _db.recurringTransactionsDao.watchRecurringTransactionById(id).map(
          (transaction) => transaction != null
              ? RecurringTransactionMapper.toEntity(transaction)
              : null,
        );
  }

  @override
  Future<int> createRecurringTransaction({
    required TransactionType type,
    required int accountId,
    int? toAccountId,
    int? categoryId,
    required double amount,
    String currency = 'EUR',
    String? payee,
    String? description,
    required RecurrenceInterval interval,
    required int dayOfMonth,
    required DateTime startDate,
    DateTime? endDate,
    bool isActive = true,
  }) {
    return _db.recurringTransactionsDao.createRecurringTransaction(
      RecurringTransactionsTableCompanion.insert(
        type: type,
        accountId: accountId,
        toAccountId: Value(toAccountId),
        categoryId: Value(categoryId),
        amount: amount,
        currency: Value(currency),
        payee: Value(payee),
        description: Value(description),
        interval: interval,
        dayOfMonth: dayOfMonth,
        startDate: startDate,
        endDate: Value(endDate),
        isActive: Value(isActive),
      ),
    );
  }

  @override
  Future<void> updateRecurringTransaction(
      domain.RecurringTransaction transaction) async {
    final data = RecurringTransactionMapper.toData(transaction);
    await _db.recurringTransactionsDao.updateRecurringTransaction(data);
  }

  @override
  Future<void> deleteRecurringTransaction(int id) async {
    await _db.recurringTransactionsDao.deleteRecurringTransaction(id);
  }

  @override
  Future<void> markAsExecuted(int id, DateTime executedDate) {
    return _db.recurringTransactionsDao.markAsExecuted(id, executedDate);
  }

  @override
  DateTime? getNextDueDate(domain.RecurringTransaction transaction) {
    final data = RecurringTransactionMapper.toData(transaction);
    return _db.recurringTransactionsDao.getNextDueDate(data);
  }
}
