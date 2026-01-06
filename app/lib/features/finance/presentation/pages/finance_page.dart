import 'package:flutter/material.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/components.dart';
import '../widgets/account_form_dialog.dart';
import '../widgets/budget_overview_card.dart';
import '../widgets/capital_summary_card.dart';
import '../widgets/category_form_dialog.dart';
import '../widgets/planned_transactions_card.dart';
import '../widgets/projected_capital_card.dart';
import '../widgets/recurring_transaction_form_dialog.dart';
import '../widgets/transaction_form_dialog.dart';
import '../widgets/upcoming_recurring_card.dart';
import 'accounts_page.dart';
import 'budgets_page.dart';
import 'categories_page.dart';
import 'recurring_transactions_page.dart';
import 'transactions_page.dart';

/// Haushaltsbuch / Finanzen
class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  bool _isSpeedDialOpen = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.finances)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Finanzübersicht
          SectionHeader(
            title: 'Finanzübersicht',
            subtitle: 'Ihr finanzieller Status auf einen Blick',
          ),
          const SizedBox(height: 16),
          const CapitalSummaryCard(),
          const SizedBox(height: 8),
          const ProjectedCapitalCard(),
          const SizedBox(height: 8),
          const UpcomingRecurringCard(),
          const SizedBox(height: 8),
          const PlannedTransactionsCard(),
          const SizedBox(height: 8),
          const BudgetOverviewCard(),
          const SizedBox(height: 24),

          // Verwaltung
          SectionHeader(
            title: l10n.householdBook,
            subtitle: l10n.manageYourFinances,
          ),
          const SizedBox(height: 16),
          InfoCard(
            icon: Icons.account_balance_wallet,
            title: l10n.accounts,
            subtitle: l10n.manageYourAccounts,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AccountsPage(),
                ),
              );
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          InfoCard(
            icon: Icons.receipt_long,
            title: l10n.transactions,
            subtitle: l10n.manageYourTransactions,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TransactionsPage(),
                ),
              );
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          InfoCard(
            icon: Icons.repeat,
            title: l10n.recurringTransactions,
            subtitle: l10n.manageYourTransactions,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const RecurringTransactionsPage(),
                ),
              );
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          InfoCard(
            icon: Icons.category,
            title: l10n.categories,
            subtitle: l10n.manageYourCategories,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CategoriesPage(),
                ),
              );
            },
            trailing: const Icon(Icons.chevron_right),
          ),
          InfoCard(
            icon: Icons.savings,
            title: l10n.budgets,
            subtitle: l10n.manageYourFinances,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BudgetsPage(),
                ),
              );
            },
            trailing: const Icon(Icons.chevron_right),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Speed Dial Optionen
          if (_isSpeedDialOpen) ...[
            _buildSpeedDialOption(
              context,
              icon: Icons.category,
              label: 'Neue Kategorie',
              onTap: () {
                setState(() => _isSpeedDialOpen = false);
                showDialog(
                  context: context,
                  builder: (context) => const CategoryFormDialog(),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSpeedDialOption(
              context,
              icon: Icons.account_balance_wallet,
              label: 'Neues Konto',
              onTap: () {
                setState(() => _isSpeedDialOpen = false);
                showDialog(
                  context: context,
                  builder: (context) => const AccountFormDialog(),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSpeedDialOption(
              context,
              icon: Icons.repeat,
              label: 'Neuer Dauerauftrag',
              onTap: () {
                setState(() => _isSpeedDialOpen = false);
                showDialog(
                  context: context,
                  builder: (context) => const RecurringTransactionFormDialog(),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildSpeedDialOption(
              context,
              icon: Icons.receipt_long,
              label: 'Neue Buchung',
              onTap: () {
                setState(() => _isSpeedDialOpen = false);
                showDialog(
                  context: context,
                  builder: (context) => const TransactionFormDialog(),
                );
              },
            ),
            const SizedBox(height: 12),
          ],
          // Haupt-FAB
          FloatingActionButton(
            onPressed: () {
              setState(() => _isSpeedDialOpen = !_isSpeedDialOpen);
            },
            child: AnimatedRotation(
              turns: _isSpeedDialOpen ? 0.125 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Icon(_isSpeedDialOpen ? Icons.close : Icons.add),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpeedDialOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FloatingActionButton.small(
          onPressed: onTap,
          heroTag: label,
          child: Icon(icon),
        ),
      ],
    );
  }
}
