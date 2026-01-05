import 'package:drift/drift.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/transaction.dart' as domain;
import '../../domain/repositories/transaction_repository.dart';
import '../database/daos/transactions_dao.dart';
import '../database/tables/transactions_table.dart';
import '../mappers/transaction_mapper.dart';

/// Implementierung des TransactionRepository
@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._db);

  final AppDatabase _db;

  @override
  Future<List<domain.Transaction>> getAllTransactions({
    TransactionFilter? filter,
  }) async {
    final transactions =
        await _db.transactionsDao.getAllTransactions(filter: filter);
    return TransactionMapper.toEntityList(transactions);
  }

  @override
  Stream<List<domain.Transaction>> watchAllTransactions({
    TransactionFilter? filter,
  }) {
    return _db.transactionsDao
        .watchAllTransactions(filter: filter)
        .map(TransactionMapper.toEntityList);
  }

  @override
  Future<domain.Transaction?> getTransactionById(int id) async {
    final transaction = await _db.transactionsDao.getTransactionById(id);
    return transaction != null ? TransactionMapper.toEntity(transaction) : null;
  }

  @override
  Stream<domain.Transaction?> watchTransactionById(int id) {
    return _db.transactionsDao.watchTransactionById(id).map(
          (transaction) => transaction != null
              ? TransactionMapper.toEntity(transaction)
              : null,
        );
  }

  @override
  Future<List<domain.Transaction>> getTemplates() async {
    final templates = await _db.transactionsDao.getTemplates();
    return TransactionMapper.toEntityList(templates);
  }

  @override
  Stream<List<domain.Transaction>> watchTemplates() {
    return _db.transactionsDao
        .watchTemplates()
        .map(TransactionMapper.toEntityList);
  }

  @override
  Future<List<domain.Transaction>> getPlannedTransactions() async {
    final planned = await _db.transactionsDao.getPlannedTransactions();
    return TransactionMapper.toEntityList(planned);
  }

  @override
  Stream<List<domain.Transaction>> watchPlannedTransactions() {
    return _db.transactionsDao
        .watchPlannedTransactions()
        .map(TransactionMapper.toEntityList);
  }

  @override
  Future<List<domain.Transaction>> getTransactionsByAccount(
      int accountId) async {
    final transactions =
        await _db.transactionsDao.getTransactionsByAccount(accountId);
    return TransactionMapper.toEntityList(transactions);
  }

  @override
  Future<List<domain.Transaction>> getTransactionsByCategory(
      int categoryId) async {
    final transactions =
        await _db.transactionsDao.getTransactionsByCategory(categoryId);
    return TransactionMapper.toEntityList(transactions);
  }

  @override
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
  }) {
    return _db.transactionsDao.createTransaction(
      TransactionsTableCompanion.insert(
        type: type,
        accountId: accountId,
        toAccountId: Value(toAccountId),
        categoryId: Value(categoryId),
        amount: amount,
        currency: Value(currency),
        date: date,
        payee: Value(payee),
        description: Value(description),
        isPlanned: Value(isPlanned),
        isTemplate: Value(isTemplate),
        templateName: Value(templateName),
        isBooked: Value(isBooked),
      ),
    );
  }

  @override
  Future<void> updateTransaction(domain.Transaction transaction) async {
    final data = TransactionMapper.toData(transaction);
    await _db.transactionsDao.updateTransaction(data);
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await _db.transactionsDao.deleteTransaction(id);
  }

  @override
  Future<int> createFromTemplate(int templateId, DateTime date) {
    return _db.transactionsDao.createFromTemplate(templateId, date);
  }

  @override
  Future<bool> bookPlannedTransaction(int id) {
    return _db.transactionsDao.bookPlannedTransaction(id);
  }
}
