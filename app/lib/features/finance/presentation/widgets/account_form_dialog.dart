import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/utils/decimal_text_input_formatter.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/usecases/create_account.dart';
import '../../domain/usecases/get_all_account_types.dart';
import '../../domain/usecases/update_account.dart';

/// Dialog für Konto-Formular (Create/Edit)
class AccountFormDialog extends StatefulWidget {
  const AccountFormDialog({super.key, this.account});

  final Account? account;

  @override
  State<AccountFormDialog> createState() => _AccountFormDialogState();
}

class _AccountFormDialogState extends State<AccountFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _getAllAccountTypes = getIt<GetAllAccountTypes>();
  final _createAccount = getIt<CreateAccount>();
  final _updateAccount = getIt<UpdateAccount>();

  late final TextEditingController _nameController;
  late final TextEditingController _initialBalanceController;
  late final TextEditingController _notesController;
  late bool _includeInOverview;
  late bool _isDefault;
  int? _selectedAccountTypeId;
  List<AccountType> _accountTypes = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.account?.name);
    _initialBalanceController = TextEditingController(
      text: widget.account?.initialBalance.toStringAsFixed(2) ?? '0.00',
    );
    _notesController = TextEditingController(text: widget.account?.notes);
    _includeInOverview = widget.account?.includeInOverview ?? true;
    _isDefault = widget.account?.isDefault ?? false;
    _selectedAccountTypeId = widget.account?.accountTypeId;
    _loadAccountTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAccountTypes() async {
    final types = await _getAllAccountTypes();
    setState(() {
      _accountTypes = types;
      _selectedAccountTypeId ??= types.firstOrNull?.id;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedAccountTypeId == null) return;

    final balance = double.tryParse(_initialBalanceController.text) ?? 0.0;

    try {
      if (widget.account == null) {
        // Create
        await _createAccount(
          accountTypeId: _selectedAccountTypeId!,
          name: _nameController.text,
          initialBalance: balance,
          includeInOverview: _includeInOverview,
          isDefault: _isDefault,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
      } else {
        // Update
        await _updateAccount(
          widget.account!.copyWith(
            name: _nameController.text,
            accountTypeId: _selectedAccountTypeId,
            initialBalance: balance,
            includeInOverview: _includeInOverview,
            isDefault: _isDefault,
            notes: _notesController.text.isEmpty ? null : _notesController.text,
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
    final isEdit = widget.account != null;

    return AlertDialog(
      title: Text(isEdit ? l10n.editAccount : l10n.createAccount),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Account Type
              DropdownButtonFormField<int>(
                value: _selectedAccountTypeId,
                decoration: InputDecoration(
                  labelText: l10n.accountType,
                ),
                items: _accountTypes.map((type) {
                  return DropdownMenuItem(
                    value: type.id,
                    child: Row(
                      children: [
                        Icon(Icons.account_balance_wallet),
                        const SizedBox(width: 8),
                        Text(type.name),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAccountTypeId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return l10n.pleaseSelectAccountType;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.name,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return l10n.pleaseEnterName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Initial Balance
              TextFormField(
                controller: _initialBalanceController,
                decoration: InputDecoration(
                  labelText: l10n.initialBalance,
                  suffixText: 'EUR',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

              // Notes
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: l10n.notes,
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Include in Overview
              SwitchListTile(
                title: Text(l10n.includeInOverview),
                value: _includeInOverview,
                onChanged: (value) {
                  setState(() {
                    _includeInOverview = value;
                  });
                },
              ),

              // Default Account
              SwitchListTile(
                title: Text(l10n.defaultAccount),
                value: _isDefault,
                onChanged: (value) {
                  setState(() {
                    _isDefault = value;
                  });
                },
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
