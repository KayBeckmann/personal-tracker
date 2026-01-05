import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/components.dart';
import '../../domain/entities/budget.dart';
import '../../domain/usecases/delete_budget.dart';
import '../../domain/usecases/get_all_budgets.dart';
import '../widgets/budget_form_dialog.dart';

/// Seite für Budgetverwaltung
class BudgetsPage extends StatefulWidget {
  const BudgetsPage({super.key});

  @override
  State<BudgetsPage> createState() => _BudgetsPageState();
}

class _BudgetsPageState extends State<BudgetsPage> {
  final _getAllBudgets = getIt<GetAllBudgets>();
  final _deleteBudget = getIt<DeleteBudget>();

  Future<void> _loadData() async {
    setState(() {});
  }

  Future<void> _showBudgetForm({Budget? budget}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => BudgetFormDialog(budget: budget),
    );

    if (result == true && mounted) {
      _loadData();
    }
  }

  Future<void> _deleteBudgetConfirm(Budget budget) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteBudget),
        content: Text(l10n.deleteBudgetConfirmation),
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
        await _deleteBudget(budget.id);
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
        title: Text(l10n.budgets),
      ),
      body: FutureBuilder<List<Budget>>(
        future: _getAllBudgets(),
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

          final budgets = snapshot.data ?? [];

          if (budgets.isEmpty) {
            return EmptyState(
              icon: Icons.savings,
              title: l10n.noBudgetsYet,
              message: l10n.createYourFirstBudget,
              action: FilledButton.icon(
                onPressed: () => _showBudgetForm(),
                icon: const Icon(Icons.add),
                label: Text(l10n.createBudget),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: budgets.length,
            itemBuilder: (context, index) {
              final budget = budgets[index];
              return _BudgetTile(
                budget: budget,
                onTap: () => _showBudgetForm(budget: budget),
                onDelete: () => _deleteBudgetConfirm(budget),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBudgetForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _BudgetTile extends StatelessWidget {
  const _BudgetTile({
    required this.budget,
    required this.onTap,
    required this.onDelete,
  });

  final Budget budget;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // Bestimme Farbe basierend auf Budgetnutzung
    final Color progressColor;
    if (budget.percentage < 80) {
      progressColor = Colors.green;
    } else if (budget.percentage < 100) {
      progressColor = Colors.orange;
    } else {
      progressColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Name und Löschen-Button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      budget.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: onDelete,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // SOLL/IST Beträge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${l10n.actual}: ${budget.actualSpending.toStringAsFixed(2)} €',
                    style: theme.textTheme.bodyMedium,
                  ),
                  Text(
                    '${l10n.budget}: ${budget.amount.toStringAsFixed(2)} €',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Fortschrittsbalken
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: budget.percentage / 100,
                  minHeight: 20,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              const SizedBox(height: 4),

              // Prozent und verbleibender Betrag
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${budget.percentage.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: progressColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    budget.remaining >= 0
                        ? '${l10n.remaining}: ${budget.remaining.toStringAsFixed(2)} €'
                        : '${l10n.exceeded}: ${(-budget.remaining).toStringAsFixed(2)} €',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: budget.remaining >= 0
                          ? theme.colorScheme.onSurface
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
