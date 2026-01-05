import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/components.dart';
import '../../data/database/daos/transactions_dao.dart';
import '../../data/database/tables/transactions_table.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_all_transactions.dart';
import '../widgets/transaction_form_dialog.dart';

/// Seite für Buchungenverwaltung
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final _getAllTransactions = getIt<GetAllTransactions>();
  final _deleteTransaction = getIt<DeleteTransaction>();

  TransactionFilter? _filter;

  Future<void> _loadData() async {
    setState(() {});
  }

  Future<void> _showTransactionForm({Transaction? transaction}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => TransactionFormDialog(transaction: transaction),
    );

    if (result == true && mounted) {
      _loadData();
    }
  }

  Future<void> _deleteTransactionConfirm(Transaction transaction) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTransaction),
        content: Text(l10n.deleteTransactionConfirmation),
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
        await _deleteTransaction(transaction.id);
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
        title: Text(l10n.transactions),
      ),
      body: FutureBuilder<List<Transaction>>(
        future: _getAllTransactions(filter: _filter),
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

          final transactions = snapshot.data ?? [];

          if (transactions.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long,
              title: l10n.noTransactionsYet,
              message: l10n.createYourFirstTransaction,
              action: FilledButton.icon(
                onPressed: () => _showTransactionForm(),
                icon: const Icon(Icons.add),
                label: Text(l10n.createTransaction),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return _TransactionTile(
                transaction: transaction,
                onTap: () => _showTransactionForm(transaction: transaction),
                onDelete: () => _deleteTransactionConfirm(transaction),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.transaction,
    required this.onTap,
    required this.onDelete,
  });

  final Transaction transaction;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd();

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
          transaction.payee ?? transaction.description ?? 'Transaction',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(dateFormat.format(transaction.date)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${transaction.amount.toStringAsFixed(2)} ${transaction.currency}',
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
}
