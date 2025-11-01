import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/library_management_service.dart';
import '../../../shared/constants/app_constants.dart';
import '../providers/library_management_provider.dart';

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  final TextEditingController _nameController = TextEditingController();
  String _selectedColor = '#2196F3';

  final List<String> _availableColors = [
    '#2196F3', // Blue
    '#4CAF50', // Green
    '#FF9800', // Orange
    '#F44336', // Red
    '#9C27B0', // Purple
    '#00BCD4', // Cyan
    '#FFC107', // Amber
    '#795548', // Brown
    '#607D8B', // Blue Grey
    '#E91E63', // Pink
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoryManagementProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateCategoryDialog(),
          ),
        ],
      ),
      body: categoriesState.when(
        data: (categories) => _buildCategoriesList(categories, theme),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(error, theme),
      ),
    );
  }

  Widget _buildCategoriesList(List<LibraryCategory> categories, ThemeData theme) {
    if (categories.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _buildCategoryCard(category, theme);
      },
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            'No Categories Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'Create categories to organize your library',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingL),
          ElevatedButton.icon(
            onPressed: () => _showCreateCategoryDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Create Category'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(dynamic error, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: theme.colorScheme.error,
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'Failed to Load Categories',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            error.toString(),
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.spacingM),
          ElevatedButton(
            onPressed: () => ref.read(categoryManagementProvider.notifier).refreshCategories(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(LibraryCategory category, ThemeData theme) {
    final color = Color(int.parse(category.color.replaceFirst('#', '0xFF')));
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(
            Icons.category,
            color: color,
          ),
        ),
        title: Text(
          category.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${category.novelIds.length} novels',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleCategoryAction(value, category),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
        onTap: () => _showCategoryDetails(category),
      ),
    );
  }

  void _handleCategoryAction(String action, LibraryCategory category) {
    switch (action) {
      case 'edit':
        _showEditCategoryDialog(category);
        break;
      case 'delete':
        _showDeleteCategoryDialog(category);
        break;
    }
  }

  void _showCreateCategoryDialog() {
    _nameController.clear();
    _selectedColor = '#2196F3';
    
    showDialog(
      context: context,
      builder: (context) => _buildCategoryDialog('Create Category', null),
    );
  }

  void _showEditCategoryDialog(LibraryCategory category) {
    _nameController.text = category.name;
    _selectedColor = category.color;
    
    showDialog(
      context: context,
      builder: (context) => _buildCategoryDialog('Edit Category', category),
    );
  }

  Widget _buildCategoryDialog(String title, LibraryCategory? category) {
    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'Choose Color',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: AppConstants.spacingS),
          Wrap(
            spacing: AppConstants.spacingS,
            children: _availableColors.map((color) {
              final isSelected = _selectedColor == color;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedColor = color;
                  });
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(int.parse(color.replaceFirst('#', '0xFF'))),
                    shape: BoxShape.circle,
                    border: isSelected
                        ? Border.all(color: Colors.white, width: 3)
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => _saveCategory(category),
          child: Text(category == null ? 'Create' : 'Update'),
        ),
      ],
    );
  }

  void _saveCategory(LibraryCategory? category) {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    if (category == null) {
      ref.read(categoryManagementProvider.notifier).createCategory(name, _selectedColor);
    } else {
      ref.read(categoryManagementProvider.notifier).updateCategory(category.id, name, _selectedColor);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(category == null ? 'Category created' : 'Category updated'),
      ),
    );
  }

  void _showDeleteCategoryDialog(LibraryCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(categoryManagementProvider.notifier).deleteCategory(category.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Category deleted')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showCategoryDetails(LibraryCategory category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(category.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Novels: ${category.novelIds.length}'),
            Text('Created: ${_formatDate(category.createdAt)}'),
            Text('Updated: ${_formatDate(category.updatedAt)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
