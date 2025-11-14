import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/novel.dart';
import '../../../core/services/library_service.dart';
import '../../../shared/widgets/novel_card.dart';
import '../../../shared/widgets/filter_chip.dart' as custom;
import '../../../shared/constants/app_constants.dart';
import '../providers/browse_provider.dart';

class BrowsePage extends ConsumerStatefulWidget {
  const BrowsePage({super.key});

  @override
  ConsumerState<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends ConsumerState<BrowsePage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = AppConstants.filterAll;
  String _selectedSort = AppConstants.sortPopular;

  @override
  void initState() {
    super.initState();
    // Load novels when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('BrowsePage: Initializing and loading novels...');
      ref.read(browseNotifierProvider.notifier).loadNovels();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final browseState = ref.watch(browseNotifierProvider);
    final theme = Theme.of(context);

    print('BrowsePage: Building with state: $browseState');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.cloud_download),
          //   tooltip: 'Scrape Novels',
          //   onPressed: () async {
          //     final novel = await Navigator.push<Novel>(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const ScrapeNovelsPage(),
          //       ),
          //     );
          //     // Handle selected novel if returned
          //     if (novel != null && context.mounted) {
          //       // Could add to library or navigate to details
          //       context.push('/novel-details/${novel.id}');
          //     }
          //   },
          // ),
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
      body: Column(
        children: [
          // Filter Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
              children: [
                custom.FilterChip(
                  label: AppConstants.filterAll,
                  isSelected: _selectedFilter == AppConstants.filterAll,
                  onTap: () => _onFilterChanged(AppConstants.filterAll),
                ),
                const SizedBox(width: AppConstants.spacingS),
                custom.FilterChip(
                  label: AppConstants.filterRomance,
                  isSelected: _selectedFilter == AppConstants.filterRomance,
                  onTap: () => _onFilterChanged(AppConstants.filterRomance),
                ),
                const SizedBox(width: AppConstants.spacingS),
                custom.FilterChip(
                  label: AppConstants.filterAction,
                  isSelected: _selectedFilter == AppConstants.filterAction,
                  onTap: () => _onFilterChanged(AppConstants.filterAction),
                ),
                const SizedBox(width: AppConstants.spacingS),
                custom.FilterChip(
                  label: AppConstants.filterSliceOfLife,
                  isSelected: _selectedFilter == AppConstants.filterSliceOfLife,
                  onTap: () => _onFilterChanged(AppConstants.filterSliceOfLife),
                ),
                const SizedBox(width: AppConstants.spacingS),
                custom.FilterChip(
                  label: AppConstants.filterFantasy,
                  isSelected: _selectedFilter == AppConstants.filterFantasy,
                  onTap: () => _onFilterChanged(AppConstants.filterFantasy),
                ),
              ],
            ),
          ),
          
          // Novels Grid
          Expanded(
            child: browseState.when(
              data: (novels) => _buildNovelsGrid(novels),
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
                      'Failed to load novels',
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
                        ref.invalidate(browseNotifierProvider);
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNovelsGrid(List<Novel> novels) {
    if (novels.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: AppConstants.spacingM),
            Text(
              'No novels found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: AppConstants.spacingS),
            Text(
              'Try adjusting your filters or search terms',
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

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    ref.read(browseNotifierProvider.notifier).filterNovels(filter);
  }

  void _navigateToNovelDetails(String novelId) {
    // Navigation will be handled by the router
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
            Consumer(
              builder: (context, ref, child) {
                final isInLibraryAsync = ref.watch(isNovelInLibraryProvider(novel.id));
                return isInLibraryAsync.when(
                  data: (isInLibrary) => ListTile(
                    leading: Icon(isInLibrary ? Icons.remove_circle : Icons.library_add),
                    title: Text(isInLibrary ? 'Remove from Library' : 'Add to Library'),
                    onTap: () {
                      Navigator.pop(context);
                      if (isInLibrary) {
                        _removeFromLibrary(novel);
                      } else {
                        _addToLibrary(novel);
                      }
                    },
                  ),
                  loading: () => ListTile(
                    leading: const CircularProgressIndicator(),
                    title: const Text('Loading...'),
                  ),
                  error: (error, stack) => ListTile(
                    leading: const Icon(Icons.error),
                    title: const Text('Error'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: Text(novel.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () {
                Navigator.pop(context);
                ref.read(browseNotifierProvider.notifier).toggleFavorite(novel.id);
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

  void _addToLibrary(Novel novel) {
    // Add novel to library
    ref.read(browseNotifierProvider.notifier).addToLibrary(novel);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${novel.title} added to library'),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'View Library',
          onPressed: () {
            context.go(AppConstants.routeLibrary);
          },
        ),
      ),
    );
  }

  void _removeFromLibrary(Novel novel) {
    // Remove novel from library
    ref.read(browseNotifierProvider.notifier).removeFromLibrary(novel);
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${novel.title} removed from library'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Novels'),
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
              ref.read(browseNotifierProvider.notifier).searchNovels(_searchController.text);
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
              title: const Text('Popular'),
              value: AppConstants.sortPopular,
              groupValue: _selectedSort,
              onChanged: (value) {
                setState(() {
                  _selectedSort = value!;
                });
                Navigator.pop(context);
                ref.read(browseNotifierProvider.notifier).sortNovels(value!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Latest'),
              value: AppConstants.sortLatest,
              groupValue: _selectedSort,
              onChanged: (value) {
                setState(() {
                  _selectedSort = value!;
                });
                Navigator.pop(context);
                ref.read(browseNotifierProvider.notifier).sortNovels(value!);
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
                ref.read(browseNotifierProvider.notifier).sortNovels(value!);
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
                ref.read(browseNotifierProvider.notifier).sortNovels(value!);
              },
            ),
          ],
        ),
      ),
    );
  }
}