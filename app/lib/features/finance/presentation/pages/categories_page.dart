import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/theme/components.dart';
import '../../data/database/tables/categories_table.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/delete_category.dart';
import '../../domain/usecases/get_main_categories.dart';
import '../../domain/usecases/get_subcategories.dart';
import '../widgets/category_form_dialog.dart';

/// Seite für Kategorienverwaltung
class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage>
    with SingleTickerProviderStateMixin {
  final _getMainCategories = getIt<GetMainCategories>();
  final _getSubcategories = getIt<GetSubcategories>();
  final _deleteCategory = getIt<DeleteCategory>();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {});
  }

  Future<void> _showCategoryForm({Category? category, CategoryType? type}) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => CategoryFormDialog(
        category: category,
        defaultType: type,
      ),
    );

    if (result == true && mounted) {
      _loadData();
    }
  }

  Future<void> _deleteCategoryConfirm(Category category) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteCategory),
        content: Text(l10n.deleteCategoryConfirmation(category.name)),
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
        await _deleteCategory(category.id);
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
        title: Text(l10n.categories),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: l10n.expenses),
            Tab(text: l10n.income),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _CategoryList(
            type: CategoryType.expense,
            onEdit: (category) => _showCategoryForm(category: category),
            onDelete: _deleteCategoryConfirm,
            onAddSubcategory: (parent) => _showCategoryForm(
              type: parent.type,
            ),
          ),
          _CategoryList(
            type: CategoryType.income,
            onEdit: (category) => _showCategoryForm(category: category),
            onDelete: _deleteCategoryConfirm,
            onAddSubcategory: (parent) => _showCategoryForm(
              type: parent.type,
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final type = _tabController.index == 0
              ? CategoryType.expense
              : CategoryType.income;
          _showCategoryForm(type: type);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({
    required this.type,
    required this.onEdit,
    required this.onDelete,
    required this.onAddSubcategory,
  });

  final CategoryType type;
  final Function(Category) onEdit;
  final Function(Category) onDelete;
  final Function(Category) onAddSubcategory;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final getMainCategories = getIt<GetMainCategories>();

    return FutureBuilder<List<Category>>(
      future: getMainCategories(type: type),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingIndicator();
        }

        if (snapshot.hasError) {
          return ErrorView(
            message: snapshot.error.toString(),
            onRetry: () {},
          );
        }

        final categories = snapshot.data ?? [];

        if (categories.isEmpty) {
          return EmptyState(
            icon: Icons.category,
            title: l10n.noCategoriesYet,
            message: l10n.createYourFirstCategory,
            action: FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: Text(l10n.createCategory),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return _CategoryTile(
              category: category,
              onTap: () => onEdit(category),
              onDelete: () => onDelete(category),
              onAddSubcategory: () => onAddSubcategory(category),
            );
          },
        );
      },
    );
  }
}

class _CategoryTile extends StatefulWidget {
  const _CategoryTile({
    required this.category,
    required this.onTap,
    required this.onDelete,
    required this.onAddSubcategory,
    this.isSubcategory = false,
  });

  final Category category;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onAddSubcategory;
  final bool isSubcategory;

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final getSubcategories = getIt<GetSubcategories>();

    return Column(
      children: [
        Card(
          margin: widget.isSubcategory
              ? const EdgeInsets.only(left: 32, top: 4, bottom: 4)
              : const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: Icon(
              _getIconData(widget.category.icon),
              color: widget.category.color != null
                  ? _hexToColor(widget.category.color!)
                  : null,
            ),
            title: Text(widget.category.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!widget.isSubcategory && !widget.category.isDefault)
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Add subcategory',
                    onPressed: widget.onAddSubcategory,
                  ),
                if (!widget.category.isDefault)
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: widget.onDelete,
                  ),
                if (!widget.isSubcategory)
                  FutureBuilder<List<Category>>(
                    future: getSubcategories(widget.category.id),
                    builder: (context, snapshot) {
                      final hasSubcategories =
                          snapshot.data?.isNotEmpty ?? false;
                      if (!hasSubcategories) return const SizedBox.shrink();
                      return IconButton(
                        icon: Icon(
                          _expanded ? Icons.expand_less : Icons.expand_more,
                        ),
                        onPressed: () {
                          setState(() {
                            _expanded = !_expanded;
                          });
                        },
                      );
                    },
                  ),
              ],
            ),
            onTap: widget.onTap,
          ),
        ),
        if (_expanded && !widget.isSubcategory)
          FutureBuilder<List<Category>>(
            future: getSubcategories(widget.category.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              final subcategories = snapshot.data ?? [];
              return Column(
                children: subcategories
                    .map((sub) => _CategoryTile(
                          category: sub,
                          onTap: widget.onTap,
                          onDelete: widget.onDelete,
                          onAddSubcategory: widget.onAddSubcategory,
                          isSubcategory: true,
                        ))
                    .toList(),
              );
            },
          ),
      ],
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
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
    };
    return iconMap[iconName] ?? Icons.category;
  }

  Color? _hexToColor(String hex) {
    try {
      return Color(int.parse(hex.substring(1), radix: 16) + 0xFF000000);
    } catch (e) {
      return null;
    }
  }
}
