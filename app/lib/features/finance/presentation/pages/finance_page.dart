import 'package:flutter/material.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/components.dart';
import '../widgets/budget_overview_card.dart';
import '../widgets/capital_summary_card.dart';
import '../widgets/planned_transactions_card.dart';
import '../widgets/projected_capital_card.dart';
import '../widgets/upcoming_recurring_card.dart';
import 'accounts_page.dart';
import 'budgets_page.dart';
import 'categories_page.dart';
import 'recurring_transactions_page.dart';
import 'transactions_page.dart';

/// Haushaltsbuch / Finanzen
class FinancePage extends StatelessWidget {
  const FinancePage({super.key});

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
    );
  }
}
