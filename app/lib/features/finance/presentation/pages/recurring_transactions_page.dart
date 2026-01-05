import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/components.dart';
import '../../data/database/tables/recurring_transactions_table.dart';
import '../../data/database/tables/transactions_table.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/usecases/delete_recurring_transaction.dart';
import '../../domain/usecases/get_all_recurring_transactions.dart';
import '../widgets/recurring_transaction_form_dialog.dart';

/// Seite zur Verwaltung von Daueraufträgen
class RecurringTransactionsPage extends StatefulWidget {
  const RecurringTransactionsPage({super.key});

  @override
  State<RecurringTransactionsPage> createState() =>
      _RecurringTransactionsPageState();
}

class _RecurringTransactionsPageState
    extends State<RecurringTransactionsPage> {
  final _getAllRecurringTransactions = getIt<GetAllRecurringTransactions>();
  final _deleteRecurringTransaction = getIt<DeleteRecurringTransaction>();

  Future<void> _loadData() async {
    setState(() {});
  }

  Future<void> _showRecurringTransactionForm({
    RecurringTransaction? transaction,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => RecurringTransactionFormDialog(
        transaction: transaction,
      ),
    );

    if (result == true && mounted) {
      _loadData();
    }
  }

  Future<void> _deleteRecurringTransactionConfirm(
    RecurringTransaction transaction,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteRecurringTransaction),
        content: Text(l10n.deleteRecurringTransactionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _deleteRecurringTransaction(transaction.id);
        if (mounted) {
          _loadData();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recurringTransactions),
      ),
      body: FutureBuilder<List<RecurringTransaction>>(
        future: _getAllRecurringTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator();
          }

          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: _loadData,
            );
          }

          final recurringTransactions = snapshot.data ?? [];

          if (recurringTransactions.isEmpty) {
            return EmptyState(
              icon: Icons.repeat,
              title: l10n.noRecurringTransactions,
              message: l10n.createRecurringTransaction,
              action: FilledButton.icon(
                onPressed: () => _showRecurringTransactionForm(),
                icon: const Icon(Icons.add),
                label: Text(l10n.createRecurringTransaction),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: recurringTransactions.length,
            itemBuilder: (context, index) {
              final transaction = recurringTransactions[index];
              return _RecurringTransactionTile(
                transaction: transaction,
                onTap: () => _showRecurringTransactionForm(
                  transaction: transaction,
                ),
                onDelete: () => _deleteRecurringTransactionConfirm(transaction),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRecurringTransactionForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RecurringTransactionTile extends StatelessWidget {
  const _RecurringTransactionTile({
    required this.transaction,
    required this.onTap,
    required this.onDelete,
  });

  final RecurringTransaction transaction;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMd();

    // Intervall-Text
    final intervalText = _getIntervalText(l10n, transaction.interval);

    // Nächste Fälligkeit berechnen
    final nextDue = _calculateNextDue(transaction);
    final nextDueText = nextDue != null
        ? dateFormat.format(nextDue)
        : l10n.ended;

    final isIncome = transaction.type == TransactionType.income;
    final isTransfer = transaction.type == TransactionType.transfer;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: Icon(
          isTransfer
              ? Icons.swap_horiz
              : isIncome
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
          color: isTransfer
              ? Colors.blue
              : isIncome
                  ? Colors.green
                  : Colors.red,
        ),
        title: Text(
          transaction.description ?? transaction.payee ?? 'Recurring Transaction',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$intervalText • ${l10n.nextDue}: $nextDueText'),
            if (transaction.endDate != null)
              Text('${l10n.until}: ${dateFormat.format(transaction.endDate!)}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${transaction.amount.toStringAsFixed(2)} €',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isTransfer
                    ? Colors.blue
                    : isIncome
                        ? Colors.green
                        : Colors.red,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  String _getIntervalText(AppLocalizations l10n, RecurrenceInterval interval) {
    if (interval == RecurrenceInterval.daily) return l10n.daily;
    if (interval == RecurrenceInterval.weekly) return l10n.weekly;
    if (interval == RecurrenceInterval.biweekly) return l10n.biweekly;
    if (interval == RecurrenceInterval.monthly) return l10n.monthly;
    if (interval == RecurrenceInterval.quarterly) return l10n.quarterly;
    if (interval == RecurrenceInterval.semiannually) return l10n.semiannually;
    return l10n.yearly;
  }

  DateTime? _calculateNextDue(RecurringTransaction transaction) {
    final now = DateTime.now();
    final lastExecuted = transaction.lastExecuted ?? transaction.startDate;

    // Prüfen ob Dauerauftrag beendet ist
    if (transaction.endDate != null && now.isAfter(transaction.endDate!)) {
      return null;
    }

    DateTime nextDate;
    if (transaction.interval == RecurrenceInterval.daily) {
      nextDate = lastExecuted.add(const Duration(days: 1));
    } else if (transaction.interval == RecurrenceInterval.weekly) {
      nextDate = lastExecuted.add(const Duration(days: 7));
    } else if (transaction.interval == RecurrenceInterval.biweekly) {
      nextDate = lastExecuted.add(const Duration(days: 14));
    } else if (transaction.interval == RecurrenceInterval.monthly) {
      nextDate = DateTime(
        lastExecuted.year,
        lastExecuted.month + 1,
        transaction.dayOfMonth,
      );
    } else if (transaction.interval == RecurrenceInterval.quarterly) {
      nextDate = DateTime(
        lastExecuted.year,
        lastExecuted.month + 3,
        transaction.dayOfMonth,
      );
    } else if (transaction.interval == RecurrenceInterval.semiannually) {
      nextDate = DateTime(
        lastExecuted.year,
        lastExecuted.month + 6,
        transaction.dayOfMonth,
      );
    } else {
      // yearly
      nextDate = DateTime(
        lastExecuted.year + 1,
        lastExecuted.month,
        transaction.dayOfMonth,
      );
    }

    // Prüfen ob nächstes Datum nach Enddatum liegt
    if (transaction.endDate != null && nextDate.isAfter(transaction.endDate!)) {
      return null;
    }

    return nextDate;
  }
}
