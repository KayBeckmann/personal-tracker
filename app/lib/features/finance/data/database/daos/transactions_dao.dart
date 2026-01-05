import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../tables/transactions_table.dart';

part 'transactions_dao.g.dart';

/// Filter-Parameter für Buchungsabfragen
class TransactionFilter {
  const TransactionFilter({
    this.dateFrom,
    this.dateTo,
    this.categoryId,
    this.accountId,
    this.type,
    this.payee,
    this.searchText,
    this.isPlanned,
    this.isTemplate,
  });

  final DateTime? dateFrom;
  final DateTime? dateTo;
  final int? categoryId;
  final int? accountId;
  final TransactionType? type;
  final String? payee;
  final String? searchText;
  final bool? isPlanned;
  final bool? isTemplate;
}

/// DAO für Buchungen
@DriftAccessor(tables: [TransactionsTable])
class TransactionsDao extends DatabaseAccessor<AppDatabase>
    with _$TransactionsDaoMixin {
  TransactionsDao(super.db);

  /// Gibt alle Buchungen sortiert zurück
  Future<List<TransactionData>> getAllTransactions({
    TransactionFilter? filter,
  }) {
    final query = select(transactionsTable);
    _applyFilters(query, filter);
    query.orderBy([
      (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
      (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
    ]);
    return query.get();
  }

  /// Stream aller Buchungen
  Stream<List<TransactionData>> watchAllTransactions({
    TransactionFilter? filter,
  }) {
    final query = select(transactionsTable);
    _applyFilters(query, filter);
    query.orderBy([
      (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
      (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
    ]);
    return query.watch();
  }

  /// Wendet Filter auf eine Query an
  void _applyFilters(
    SimpleSelectStatement<$TransactionsTableTable, TransactionData> query,
    TransactionFilter? filter,
  ) {
    if (filter == null) return;

    if (filter.dateFrom != null) {
      query.where((t) => t.date.isBiggerOrEqualValue(filter.dateFrom!));
    }

    if (filter.dateTo != null) {
      query.where((t) => t.date.isSmallerOrEqualValue(filter.dateTo!));
    }

    if (filter.categoryId != null) {
      final categoryId = filter.categoryId!;
      query.where((t) => t.categoryId.equals(categoryId));
    }

    if (filter.accountId != null) {
      final accountId = filter.accountId!;
      query.where((t) =>
          t.accountId.equals(accountId) |
          t.toAccountId.equals(accountId));
    }

    if (filter.type != null) {
      query.where((t) => t.type.equals(filter.type!.index));
    }

    if (filter.payee != null && filter.payee!.isNotEmpty) {
      query.where((t) => t.payee.like('%${filter.payee}%'));
    }

    if (filter.searchText != null && filter.searchText!.isNotEmpty) {
      query.where((t) =>
          t.payee.like('%${filter.searchText}%') |
          t.description.like('%${filter.searchText}%'));
    }

    if (filter.isPlanned != null) {
      query.where((t) => t.isPlanned.equals(filter.isPlanned!));
    }

    if (filter.isTemplate != null) {
      query.where((t) => t.isTemplate.equals(filter.isTemplate!));
    }
  }

  /// Gibt eine einzelne Buchung zurück
  Future<TransactionData?> getTransactionById(int id) {
    return (select(transactionsTable)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Stream einer einzelnen Buchung
  Stream<TransactionData?> watchTransactionById(int id) {
    return (select(transactionsTable)..where((t) => t.id.equals(id)))
        .watchSingleOrNull();
  }

  /// Gibt Vorlagen zurück
  Future<List<TransactionData>> getTemplates() {
    return (select(transactionsTable)
          ..where((t) => t.isTemplate.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.templateName)]))
        .get();
  }

  /// Stream der Vorlagen
  Stream<List<TransactionData>> watchTemplates() {
    return (select(transactionsTable)
          ..where((t) => t.isTemplate.equals(true))
          ..orderBy([(t) => OrderingTerm(expression: t.templateName)]))
        .watch();
  }

  /// Gibt geplante Buchungen zurück
  Future<List<TransactionData>> getPlannedTransactions() {
    return (select(transactionsTable)
          ..where((t) => t.isPlanned.equals(true) & t.isBooked.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .get();
  }

  /// Stream der geplanten Buchungen
  Stream<List<TransactionData>> watchPlannedTransactions() {
    return (select(transactionsTable)
          ..where((t) => t.isPlanned.equals(true) & t.isBooked.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.date)]))
        .watch();
  }

  /// Gibt Buchungen für ein Konto zurück
  Future<List<TransactionData>> getTransactionsByAccount(int accountId) {
    return (select(transactionsTable)
          ..where((t) =>
              t.accountId.equals(accountId) |
              t.toAccountId.equals(accountId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Gibt Buchungen für eine Kategorie zurück
  Future<List<TransactionData>> getTransactionsByCategory(int categoryId) {
    return (select(transactionsTable)
          ..where((t) => t.categoryId.equals(categoryId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc),
          ]))
        .get();
  }

  /// Erstellt eine neue Buchung
  Future<int> createTransaction(TransactionsTableCompanion entry) {
    return into(transactionsTable).insert(entry);
  }

  /// Aktualisiert eine Buchung
  Future<bool> updateTransaction(TransactionData transaction) {
    return update(transactionsTable).replace(transaction);
  }

  /// Löscht eine Buchung
  Future<int> deleteTransaction(int id) {
    return (delete(transactionsTable)..where((t) => t.id.equals(id))).go();
  }

  /// Erstellt eine Buchung aus einer Vorlage
  Future<int> createFromTemplate(int templateId, DateTime date) async {
    final template = await getTransactionById(templateId);
    if (template == null || !template.isTemplate) {
      throw Exception('Template not found or invalid');
    }

    return createTransaction(
      TransactionsTableCompanion.insert(
        type: template.type,
        accountId: template.accountId,
        toAccountId: Value(template.toAccountId),
        categoryId: Value(template.categoryId),
        amount: template.amount,
        currency: Value(template.currency),
        date: date,
        payee: Value(template.payee),
        description: Value(template.description),
      ),
    );
  }

  /// Bucht eine geplante Buchung
  Future<bool> bookPlannedTransaction(int id) async {
    final transaction = await getTransactionById(id);
    if (transaction == null || !transaction.isPlanned) {
      return false;
    }

    return updateTransaction(
      transaction.copyWith(isBooked: true),
    );
  }
}
