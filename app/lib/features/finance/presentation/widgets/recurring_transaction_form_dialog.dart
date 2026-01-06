import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/utils/decimal_text_input_formatter.dart';
import '../../data/database/tables/categories_table.dart';
import '../../data/database/tables/recurring_transactions_table.dart';
import '../../data/database/tables/transactions_table.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/recurring_transaction.dart';
import '../../domain/usecases/create_recurring_transaction.dart';
import '../../domain/usecases/get_all_accounts.dart';
import '../../domain/usecases/get_categories_by_type.dart';
import '../../domain/usecases/update_recurring_transaction.dart';

/// Dialog zum Erstellen/Bearbeiten von Daueraufträgen
class RecurringTransactionFormDialog extends StatefulWidget {
  const RecurringTransactionFormDialog({
    super.key,
    this.transaction,
  });

  final RecurringTransaction? transaction;

  @override
  State<RecurringTransactionFormDialog> createState() =>
      _RecurringTransactionFormDialogState();
}

class _RecurringTransactionFormDialogState
    extends State<RecurringTransactionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _getAllAccounts = getIt<GetAllAccounts>();
  final _getCategoriesByType = getIt<GetCategoriesByType>();
  final _createRecurringTransaction = getIt<CreateRecurringTransaction>();
  final _updateRecurringTransaction = getIt<UpdateRecurringTransaction>();

  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _payeeController;
  late final TextEditingController _dayOfMonthController;

  late TransactionType _type;
  int? _selectedAccountId;
  int? _selectedToAccountId;
  int? _selectedCategoryId;
  late RecurrenceInterval _interval;
  late DateTime _startDate;
  DateTime? _endDate;
  late bool _isActive;

  List<Account> _accounts = [];
  List<Category> _categories = [];

  @override
  void initState() {
    super.initState();

    // Bestehenden Dauerauftrag laden
    final transaction = widget.transaction;
    if (transaction != null) {
      _type = transaction.type;
      _selectedAccountId = transaction.accountId;
      _selectedToAccountId = transaction.toAccountId;
      _selectedCategoryId = transaction.categoryId;
      _interval = transaction.interval;
      _startDate = transaction.startDate;
      _endDate = transaction.endDate;
      _isActive = transaction.isActive;

      _descriptionController = TextEditingController(text: transaction.description ?? '');
      _amountController =
          TextEditingController(text: transaction.amount.toStringAsFixed(2));
      _payeeController = TextEditingController(text: transaction.payee ?? '');
      _dayOfMonthController =
          TextEditingController(text: transaction.dayOfMonth.toString());
    } else {
      _type = TransactionType.expense;
      _interval = RecurrenceInterval.monthly;
      _startDate = DateTime.now();
      _isActive = true;

      _descriptionController = TextEditingController();
      _amountController = TextEditingController(text: '0.00');
      _payeeController = TextEditingController();
      _dayOfMonthController =
          TextEditingController(text: DateTime.now().day.toString());
    }

    _loadData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _payeeController.dispose();
    _dayOfMonthController.dispose();
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
    final description = _descriptionController.text;
    final payee = _payeeController.text.isEmpty ? null : _payeeController.text;
    final dayOfMonth = _interval.index >= RecurrenceInterval.monthly.index
        ? int.parse(_dayOfMonthController.text)
        : 1;

    try {
      if (widget.transaction == null) {
        // Neuen Dauerauftrag erstellen
        await _createRecurringTransaction(
          type: _type,
          description: description,
          amount: amount,
          categoryId: _selectedCategoryId,
          accountId: _selectedAccountId!,
          toAccountId: _selectedToAccountId,
          payee: payee,
          interval: _interval,
          dayOfMonth: dayOfMonth,
          startDate: _startDate,
          endDate: _endDate,
          isActive: _isActive,
        );
      } else {
        // Dauerauftrag aktualisieren
        await _updateRecurringTransaction(
          widget.transaction!.copyWith(
            type: _type,
            description: description,
            amount: amount,
            categoryId: _selectedCategoryId,
            accountId: _selectedAccountId,
            toAccountId: _selectedToAccountId,
            payee: payee,
            interval: _interval,
            dayOfMonth: dayOfMonth,
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
    final isEdit = widget.transaction != null;

    return AlertDialog(
      title: Text(
        isEdit ? l10n.editRecurringTransaction : l10n.createRecurringTransaction,
      ),
      content: SizedBox(
        width: 500,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Typ-Auswahl
                SegmentedButton<TransactionType>(
                  segments: [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text(l10n.expense),
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
                  onSelectionChanged: (Set<TransactionType> selection) {
                    setState(() {
                      _type = selection.first;
                      _loadData();
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Beschreibung
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: l10n.description,
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterDescription;
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

                // Kategorie (nur bei Einnahme/Ausgabe)
                if (_type != TransactionType.transfer) ...[
                  DropdownButtonFormField<int>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: l10n.category,
                      border: const OutlineInputBorder(),
                    ),
                    items: _categories
                        .map((category) => DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return l10n.pleaseSelectCategory;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Konto / Von Konto
                DropdownButtonFormField<int>(
                  value: _selectedAccountId,
                  decoration: InputDecoration(
                    labelText: _type == TransactionType.transfer
                        ? l10n.fromAccount
                        : l10n.account,
                    border: const OutlineInputBorder(),
                  ),
                  items: _accounts
                      .map((account) => DropdownMenuItem(
                            value: account.id,
                            child: Text(account.name),
                          ))
                      .toList(),
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

                // Nach Konto (nur bei Umbuchung)
                if (_type == TransactionType.transfer) ...[
                  DropdownButtonFormField<int?>(
                    value: _selectedToAccountId,
                    decoration: InputDecoration(
                      labelText: l10n.toAccount,
                      border: const OutlineInputBorder(),
                    ),
                    items: _accounts
                        .where((a) => a.id != _selectedAccountId)
                        .map((account) => DropdownMenuItem(
                              value: account.id,
                              child: Text(account.name),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedToAccountId = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return l10n.pleaseSelectToAccount;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

                // Empfänger (optional)
                TextFormField(
                  controller: _payeeController,
                  decoration: InputDecoration(
                    labelText: l10n.payee,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Intervall
                DropdownButtonFormField<RecurrenceInterval>(
                  value: _interval,
                  decoration: InputDecoration(
                    labelText: l10n.interval,
                    border: const OutlineInputBorder(),
                  ),
                  items: RecurrenceInterval.values
                      .map((interval) => DropdownMenuItem(
                            value: interval,
                            child: Text(_getIntervalLabel(l10n, interval)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _interval = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Tag des Monats (nur bei monthly und länger)
                if (_interval.index >= RecurrenceInterval.monthly.index) ...[
                  TextFormField(
                    controller: _dayOfMonthController,
                    decoration: InputDecoration(
                      labelText: l10n.dayOfMonth,
                      border: const OutlineInputBorder(),
                      helperText: l10n.dayOfMonthHelper,
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.pleaseEnterDayOfMonth;
                      }
                      final day = int.tryParse(value);
                      if (day == null || day < 1 || day > 31) {
                        return l10n.pleaseEnterValidDay;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                ],

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
                            initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
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

  String _getIntervalLabel(AppLocalizations l10n, RecurrenceInterval interval) {
    switch (interval) {
      case RecurrenceInterval.daily:
        return l10n.daily;
      case RecurrenceInterval.weekly:
        return l10n.weekly;
      case RecurrenceInterval.biweekly:
        return l10n.biweekly;
      case RecurrenceInterval.monthly:
        return l10n.monthly;
      case RecurrenceInterval.quarterly:
        return l10n.quarterly;
      case RecurrenceInterval.semiannually:
        return l10n.semiannually;
      case RecurrenceInterval.yearly:
        return l10n.yearly;
    }
  }
}
