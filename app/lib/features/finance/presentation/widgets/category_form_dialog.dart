import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../data/database/tables/categories_table.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/create_category.dart';
import '../../domain/usecases/get_main_categories.dart';
import '../../domain/usecases/update_category.dart';

/// Dialog für Kategorie-Formular (Create/Edit)
class CategoryFormDialog extends StatefulWidget {
  const CategoryFormDialog({
    super.key,
    this.category,
    this.defaultType,
  });

  final Category? category;
  final CategoryType? defaultType;

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _getMainCategories = getIt<GetMainCategories>();
  final _createCategory = getIt<CreateCategory>();
  final _updateCategory = getIt<UpdateCategory>();

  late final TextEditingController _nameController;
  late CategoryType _type;
  int? _selectedParentId;
  String _selectedIcon = 'category';
  String? _selectedColor;
  List<Category> _parentCategories = [];

  final List<String> _availableIcons = [
    'category',
    'home',
    'shopping_cart',
    'directions_car',
    'movie',
    'local_hospital',
    'security',
    'checkroom',
    'school',
    'account_balance_wallet',
    'card_giftcard',
    'trending_up',
    'redeem',
    'more_horiz',
    'restaurant',
    'local_gas_station',
    'sports',
    'fitness_center',
    'pets',
    'child_care',
  ];

  final List<String> _availableColors = [
    '#F44336', // Red
    '#E91E63', // Pink
    '#9C27B0', // Purple
    '#673AB7', // Deep Purple
    '#3F51B5', // Indigo
    '#2196F3', // Blue
    '#03A9F4', // Light Blue
    '#00BCD4', // Cyan
    '#009688', // Teal
    '#4CAF50', // Green
    '#8BC34A', // Light Green
    '#CDDC39', // Lime
    '#FFEB3B', // Yellow
    '#FFC107', // Amber
    '#FF9800', // Orange
    '#FF5722', // Deep Orange
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name);
    _type = widget.category?.type ?? widget.defaultType ?? CategoryType.expense;
    _selectedParentId = widget.category?.parentId;
    _selectedIcon = widget.category?.icon ?? 'category';
    _selectedColor = widget.category?.color;
    _loadParentCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadParentCategories() async {
    final categories = await _getMainCategories(type: _type);
    setState(() {
      _parentCategories = categories
          .where((c) => widget.category == null || c.id != widget.category!.id)
          .toList();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      if (widget.category == null) {
        // Create
        await _createCategory(
          name: _nameController.text,
          type: _type,
          parentId: _selectedParentId,
          icon: _selectedIcon,
          color: _selectedColor,
        );
      } else {
        // Update
        await _updateCategory(
          widget.category!.copyWith(
            name: _nameController.text,
            type: _type,
            parentId: _selectedParentId,
            icon: _selectedIcon,
            color: _selectedColor,
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
    final isEdit = widget.category != null;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(isEdit ? l10n.editCategory : l10n.createCategory),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type (only for create)
              if (!isEdit)
                SegmentedButton<CategoryType>(
                  segments: [
                    ButtonSegment(
                      value: CategoryType.expense,
                      label: Text(l10n.expenses),
                      icon: const Icon(Icons.arrow_downward),
                    ),
                    ButtonSegment(
                      value: CategoryType.income,
                      label: Text(l10n.income),
                      icon: const Icon(Icons.arrow_upward),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (Set<CategoryType> newSelection) {
                    setState(() {
                      _type = newSelection.first;
                      _selectedParentId = null;
                      _loadParentCategories();
                    });
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

              // Parent Category
              DropdownButtonFormField<int?>(
                value: _selectedParentId,
                decoration: InputDecoration(
                  labelText: l10n.parentCategory,
                ),
                items: [
                  DropdownMenuItem<int?>(
                    value: null,
                    child: Text(l10n.noParent),
                  ),
                  ..._parentCategories.map((category) {
                    return DropdownMenuItem<int?>(
                      value: category.id,
                      child: Row(
                        children: [
                          Icon(_getIconData(category.icon)),
                          const SizedBox(width: 8),
                          Text(category.name),
                        ],
                      ),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedParentId = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Icon Selector
              Text(
                l10n.icon,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _availableIcons.map((icon) {
                  final isSelected = icon == _selectedIcon;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _getIconData(icon),
                        color: isSelected ? theme.colorScheme.primary : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Color Selector
              Text(
                l10n.color,
                style: theme.textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // No color option
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedColor = null;
                      });
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedColor == null
                              ? theme.colorScheme.primary
                              : Colors.grey,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.close),
                    ),
                  ),
                  ..._availableColors.map((color) {
                    final isSelected = color == _selectedColor;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _hexToColor(color),
                          border: Border.all(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }),
                ],
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

  IconData _getIconData(String iconName) {
    final iconMap = {
      'category': Icons.category,
      'home': Icons.home,
      'shopping_cart': Icons.shopping_cart,
      'directions_car': Icons.directions_car,
      'movie': Icons.movie,
      'local_hospital': Icons.local_hospital,
      'security': Icons.security,
      'checkroom': Icons.checkroom,
      'school': Icons.school,
      'account_balance_wallet': Icons.account_balance_wallet,
      'card_giftcard': Icons.card_giftcard,
      'trending_up': Icons.trending_up,
      'redeem': Icons.redeem,
      'more_horiz': Icons.more_horiz,
      'restaurant': Icons.restaurant,
      'local_gas_station': Icons.local_gas_station,
      'sports': Icons.sports,
      'fitness_center': Icons.fitness_center,
      'pets': Icons.pets,
      'child_care': Icons.child_care,
    };
    return iconMap[iconName] ?? Icons.category;
  }

  Color _hexToColor(String hex) {
    return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
  }
}
