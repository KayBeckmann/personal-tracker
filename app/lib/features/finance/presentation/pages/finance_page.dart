import 'package:flutter/material.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/components.dart';
import 'accounts_page.dart';
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
            subtitle: l10n.implementedInMilestone('2.6'),
          ),
        ],
      ),
    );
  }
}
