import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/utils/decimal_text_input_formatter.dart';
import '../../data/database/tables/categories_table.dart';
import '../../data/database/tables/transactions_table.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/get_all_accounts.dart';
import '../../domain/usecases/get_categories_by_type.dart';
import '../../domain/usecases/update_transaction.dart';

/// Dialog für Buchungs-Formular (Create/Edit)
class TransactionFormDialog extends StatefulWidget {
  const TransactionFormDialog({super.key, this.transaction});

  final Transaction? transaction;

  @override
  State<TransactionFormDialog> createState() => _TransactionFormDialogState();
}

class _TransactionFormDialogState extends State<TransactionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _getAllAccounts = getIt<GetAllAccounts>();
  final _getCategoriesByType = getIt<GetCategoriesByType>();
  final _createTransaction = getIt<CreateTransaction>();
  final _updateTransaction = getIt<UpdateTransaction>();

  late final TextEditingController _amountController;
  late final TextEditingController _payeeController;
  late final TextEditingController _descriptionController;

  late TransactionType _type;
  late DateTime _date;
  int? _selectedAccountId;
  int? _selectedToAccountId;
  int? _selectedCategoryId;

  List<Account> _accounts = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction?.amount.toStringAsFixed(2) ?? '0.00',
    );
    _payeeController = TextEditingController(text: widget.transaction?.payee);
    _descriptionController =
        TextEditingController(text: widget.transaction?.description);

    _type = widget.transaction?.type ?? TransactionType.expense;
    _date = widget.transaction?.date ?? DateTime.now();
    _selectedAccountId = widget.transaction?.accountId;
    _selectedToAccountId = widget.transaction?.toAccountId;
    _selectedCategoryId = widget.transaction?.categoryId;

    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _payeeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final accounts = await _getAllAccounts();
    final categories = await _getCategoriesByType(
      _type == TransactionType.income
          ? CategoryType.income
          : CategoryType.expense,
    );

    setState(() {
      _accounts = accounts;
      _categories = categories;
      _selectedAccountId ??= accounts.firstOrNull?.id;
      _selectedCategoryId ??= categories.firstOrNull?.id;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountId == null) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;

    try {
      if (widget.transaction == null) {
        await _createTransaction(
          type: _type,
          accountId: _selectedAccountId!,
          toAccountId: _selectedToAccountId,
          categoryId: _selectedCategoryId,
          amount: amount,
          date: _date,
          payee: _payeeController.text.isEmpty ? null : _payeeController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
        );
      } else {
        await _updateTransaction(
          widget.transaction!.copyWith(
            type: _type,
            accountId: _selectedAccountId,
            toAccountId: _selectedToAccountId,
            categoryId: _selectedCategoryId,
            amount: amount,
            date: _date,
            payee: _payeeController.text.isEmpty ? null : _payeeController.text,
            description: _descriptionController.text.isEmpty
                ? null
                : _descriptionController.text,
            updatedAt: DateTime.now(),
          ),
        );
      }

      if (mounted) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEdit = widget.transaction != null;

    return AlertDialog(
      title: Text(isEdit ? l10n.editTransaction : l10n.createTransaction),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Type
              SegmentedButton<TransactionType>(
                segments: [
                  ButtonSegment(
                    value: TransactionType.expense,
                    label: Text(l10n.expenses),
                    icon: const Icon(Icons.arrow_upward),
                  ),
                  ButtonSegment(
                    value: TransactionType.income,
                    label: Text(l10n.income),
                    icon: const Icon(Icons.arrow_downward),
                  ),
                  ButtonSegment(
                    value: TransactionType.transfer,
                    label: Text(l10n.transfer),
                    icon: const Icon(Icons.swap_horiz),
                  ),
                ],
                selected: {_type},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _type = newSelection.first;
                    _loadData();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: l10n.amount,
                  suffixText: 'EUR',
                ),
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  DecimalTextInputFormatter(decimalDigits: 2),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterAmount;
                  }
                  if (double.tryParse(value) == null) {
                    return l10n.pleaseEnterValidNumber;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Account
              DropdownButtonFormField<int>(
                value: _selectedAccountId,
                decoration: InputDecoration(
                  labelText: l10n.account,
                ),
                items: _accounts.map((account) {
                  return DropdownMenuItem(
                    value: account.id,
                    child: Text(account.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAccountId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return l10n.pleaseSelectAccount;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category (only for income/expense)
              if (_type != TransactionType.transfer)
                DropdownButtonFormField<int?>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: l10n.category,
                  ),
                  items: _categories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ),
              if (_type != TransactionType.transfer) const SizedBox(height: 16),

              // To Account (only for transfers)
              if (_type == TransactionType.transfer)
                DropdownButtonFormField<int?>(
                  value: _selectedToAccountId,
                  decoration: InputDecoration(
                    labelText: l10n.toAccount,
                  ),
                  items: _accounts
                      .where((a) => a.id != _selectedAccountId)
                      .map((account) {
                    return DropdownMenuItem(
                      value: account.id,
                      child: Text(account.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedToAccountId = value;
                    });
                  },
                ),
              if (_type == TransactionType.transfer) const SizedBox(height: 16),

              // Date
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.date),
                subtitle: Text(
                  '${_date.day}.${_date.month}.${_date.year}',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() {
                      _date = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Payee
              TextFormField(
                controller: _payeeController,
                decoration: InputDecoration(
                  labelText: l10n.payee,
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _save,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
