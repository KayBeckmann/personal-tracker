import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/components.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/usecases/delete_account.dart';
import '../../domain/usecases/get_account_balance.dart';
import '../../domain/usecases/get_accounts_grouped_by_type.dart';
import '../widgets/account_form_dialog.dart';

/// Seite für Kontenverwaltung
class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key});

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
  final _getAccountsGrouped = getIt<GetAccountsGroupedByType>();
  final _deleteAccount = getIt<DeleteAccount>();
  final _getBalance = getIt<GetAccountBalance>();

  Future<void> _loadData() async {
    setState(() {});
  }

  Future<void> _showAccountForm({Account? account}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AccountFormDialog(account: account),
    );

    if (result == true && mounted) {
      _loadData();
    }
  }

  Future<void> _deleteAccountConfirm(Account account) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteAccount),
        content: Text(l10n.deleteAccountConfirmation(account.name)),
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
      await _deleteAccount(account.id);
      if (mounted) {
        _loadData();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.accounts),
      ),
      body: FutureBuilder<Map<AccountType, List<Account>>>(
        future: _getAccountsGrouped(),
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

          final grouped = snapshot.data ?? {};

          if (grouped.isEmpty) {
            return EmptyState(
              icon: Icons.account_balance_wallet,
              title: l10n.noAccountsYet,
              message: l10n.createYourFirstAccount,
              action: FilledButton.icon(
                onPressed: () => _showAccountForm(),
                icon: const Icon(Icons.add),
                label: Text(l10n.createAccount),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final type = grouped.keys.elementAt(index);
              final accounts = grouped[type]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: type.name,
                    subtitle: '${accounts.length} ${l10n.accounts}',
                  ),
                  ...accounts.map((account) => _AccountTile(
                        account: account,
                        onTap: () => _showAccountForm(account: account),
                        onDelete: () => _deleteAccountConfirm(account),
                        getBalance: _getBalance,
                      )),
                  const SizedBox(height: 16),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAccountForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.account,
    required this.onTap,
    required this.onDelete,
    required this.getBalance,
  });

  final Account account;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final GetAccountBalance getBalance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<double>(
      future: getBalance(account.id),
      builder: (context, snapshot) {
        final balance = snapshot.data ?? account.initialBalance;
        final currencyFormat = '${balance.toStringAsFixed(2)} ${account.currency}';

        return Card(
          child: ListTile(
            title: Text(account.name),
            subtitle: account.notes != null ? Text(account.notes!) : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currencyFormat,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
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
      },
    );
  }
}
