import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/novel.dart';
import '../../../shared/widgets/novel_card.dart';
import '../../../shared/constants/app_constants.dart';
import '../providers/favorites_provider.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedSort = AppConstants.sortLatest;

  @override
  void initState() {
    super.initState();
    // Load favorite novels when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(favoritesNotifierProvider.notifier).loadFavorites();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesState = ref.watch(favoritesNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showSearchDialog,
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortDialog,
          ),
        ],
      ),
      body: favoritesState.when(
        data: (novels) => _buildFavoritesGrid(novels),
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
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
                'Failed to load favorites',
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
                onPressed: () {
                  ref.invalidate(favoritesNotifierProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesGrid(List<Novel> novels) {
    if (novels.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.favorite_border,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: AppConstants.spacingM),
            Text(
              'No favorite novels yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: AppConstants.spacingS),
            Text(
              'Tap the heart icon on any novel to add it to favorites',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingS),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: AppConstants.gridCrossAxisCount,
          childAspectRatio: AppConstants.gridChildAspectRatio,
          crossAxisSpacing: AppConstants.gridSpacing,
          mainAxisSpacing: AppConstants.gridSpacing,
        ),
        itemCount: novels.length,
        itemBuilder: (context, index) {
          final novel = novels[index];
          return NovelCard(
            novel: novel,
            onTap: () => _navigateToNovelDetails(novel.id),
            onLongPress: () => _showNovelOptions(novel),
          );
        },
      ),
    );
  }

  void _navigateToNovelDetails(String novelId) {
    context.push('/novel-details/$novelId');
  }

  void _showNovelOptions(Novel novel) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: const Text('Remove from Favorites'),
              onTap: () {
                Navigator.pop(context);
                ref.read(favoritesNotifierProvider.notifier).removeFromFavorites(novel.id);
                _showRemovedSnackBar(novel.title);
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                _navigateToNovelDetails(novel.id);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRemovedSnackBar(String novelTitle) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$novelTitle removed from favorites'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Add back to favorites
            ref.read(favoritesNotifierProvider.notifier).addToFavorites(novelTitle);
          },
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Favorites'),
        content: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Enter novel title or author...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(favoritesNotifierProvider.notifier).searchFavorites(_searchController.text);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort By'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('Latest Added'),
              value: AppConstants.sortLatest,
              groupValue: _selectedSort,
              onChanged: (value) {
                setState(() {
                  _selectedSort = value!;
                });
                Navigator.pop(context);
                ref.read(favoritesNotifierProvider.notifier).sortFavorites(value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Title A-Z'),
              value: 'title',
              groupValue: _selectedSort,
              onChanged: (value) {
                setState(() {
                  _selectedSort = value!;
                });
                Navigator.pop(context);
                ref.read(favoritesNotifierProvider.notifier).sortFavorites(value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Rating'),
              value: AppConstants.sortRating,
              groupValue: _selectedSort,
              onChanged: (value) {
                setState(() {
                  _selectedSort = value!;
                });
                Navigator.pop(context);
                ref.read(favoritesNotifierProvider.notifier).sortFavorites(value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Views'),
              value: AppConstants.sortViews,
              groupValue: _selectedSort,
              onChanged: (value) {
                setState(() {
                  _selectedSort = value!;
                });
                Navigator.pop(context);
                ref.read(favoritesNotifierProvider.notifier).sortFavorites(value!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
