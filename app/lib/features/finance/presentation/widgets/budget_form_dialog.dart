import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/utils/decimal_text_input_formatter.dart';
import '../../data/database/tables/budgets_table.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/budget.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/create_budget.dart';
import '../../domain/usecases/get_all_accounts.dart';
import '../../domain/usecases/get_all_categories.dart';
import '../../domain/usecases/update_budget.dart';

/// Dialog zum Erstellen/Bearbeiten von Budgets
class BudgetFormDialog extends StatefulWidget {
  const BudgetFormDialog({super.key, this.budget});

  final Budget? budget;

  @override
  State<BudgetFormDialog> createState() => _BudgetFormDialogState();
}

class _BudgetFormDialogState extends State<BudgetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _getAllAccounts = getIt<GetAllAccounts>();
  final _getAllCategories = getIt<GetAllCategories>();
  final _createBudget = getIt<CreateBudget>();
  final _updateBudget = getIt<UpdateBudget>();

  late final TextEditingController _nameController;
  late final TextEditingController _amountController;

  int? _selectedCategoryId;
  int? _selectedAccountId;
  late BudgetPeriod _period;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _isActive;

  List<Account> _accounts = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();

    final budget = widget.budget;
    if (budget != null) {
      _nameController = TextEditingController(text: budget.name);
      _amountController =
          TextEditingController(text: budget.amount.toStringAsFixed(2));
      _selectedCategoryId = budget.categoryId;
      _selectedAccountId = budget.accountId;
      _period = budget.period;
      _startDate = budget.startDate;
      _endDate = budget.endDate;
      _isActive = budget.isActive;
    } else {
      _nameController = TextEditingController();
      _amountController = TextEditingController(text: '0.00');
      _period = BudgetPeriod.monthly;
      _startDate = DateTime.now();
      _isActive = true;
    }

    _loadData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final accounts = await _getAllAccounts();
    final categories = await _getAllCategories();

    setState(() {
      _accounts = accounts;
      _categories = categories;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final name = _nameController.text;

    try {
      if (widget.budget == null) {
        await _createBudget(
          name: name,
          categoryId: _selectedCategoryId,
          accountId: _selectedAccountId,
          amount: amount,
          period: _period,
          startDate: _startDate,
          endDate: _endDate,
          isActive: _isActive,
        );
      } else {
        await _updateBudget(
          widget.budget!.copyWith(
            name: name,
            categoryId: _selectedCategoryId,
            accountId: _selectedAccountId,
            amount: amount,
            period: _period,
            startDate: _startDate,
            endDate: _endDate,
            isActive: _isActive,
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
    final isEdit = widget.budget != null;

    return AlertDialog(
      title: Text(isEdit ? l10n.editBudget : l10n.createBudget),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.name,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterName;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Betrag
                TextFormField(
                  controller: _amountController,
                  decoration: InputDecoration(
                    labelText: l10n.amount,
                    border: const OutlineInputBorder(),
                    suffixText: '€',
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    DecimalTextInputFormatter(decimalDigits: 2),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterAmount;
                    }
                    final amount = double.tryParse(value);
                    if (amount == null || amount <= 0) {
                      return l10n.pleaseEnterValidAmount;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Kategorie (optional)
                DropdownButtonFormField<int?>(
                  value: _selectedCategoryId,
                  decoration: InputDecoration(
                    labelText: l10n.category,
                    border: const OutlineInputBorder(),
                    helperText: l10n.budgetCategoryHelper,
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(l10n.allCategories),
                    ),
                    ..._categories.map((category) => DropdownMenuItem(
                          value: category.id,
                          child: Text(category.name),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Konto (optional)
                DropdownButtonFormField<int?>(
                  value: _selectedAccountId,
                  decoration: InputDecoration(
                    labelText: l10n.account,
                    border: const OutlineInputBorder(),
                    helperText: l10n.budgetAccountHelper,
                  ),
                  items: [
                    DropdownMenuItem<int?>(
                      value: null,
                      child: Text(l10n.allAccounts),
                    ),
                    ..._accounts.map((account) => DropdownMenuItem(
                          value: account.id,
                          child: Text(account.name),
                        )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountId = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Zeitraum
                DropdownButtonFormField<BudgetPeriod>(
                  value: _period,
                  decoration: InputDecoration(
                    labelText: l10n.period,
                    border: const OutlineInputBorder(),
                  ),
                  items: BudgetPeriod.values
                      .map((period) => DropdownMenuItem(
                            value: period,
                            child: Text(_getPeriodLabel(l10n, period)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _period = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Startdatum
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.startDate),
                  subtitle: Text(DateFormat.yMd().format(_startDate)),
                  trailing: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() {
                          _startDate = date;
                        });
                      }
                    },
                  ),
                ),

                // Enddatum (optional)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.endDate),
                  subtitle: Text(
                    _endDate != null
                        ? DateFormat.yMd().format(_endDate!)
                        : l10n.noEndDate,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_endDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _endDate = null;
                            });
                          },
                        ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate:
                                _endDate ?? _startDate.add(const Duration(days: 365)),
                            firstDate: _startDate,
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            setState(() {
                              _endDate = date;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Aktiv
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.active),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
              ],
            ),
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

  String _getPeriodLabel(AppLocalizations l10n, BudgetPeriod period) {
    if (period == BudgetPeriod.weekly) return l10n.weekly;
    if (period == BudgetPeriod.monthly) return l10n.monthly;
    if (period == BudgetPeriod.quarterly) return l10n.quarterly;
    return l10n.yearly;
  }
}
