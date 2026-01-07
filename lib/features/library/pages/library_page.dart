import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tachomi_novel/const.dart';
import '../../../core/models/novel.dart';
import '../../../shared/widgets/novel_card.dart';
import '../../../shared/widgets/filter_chip.dart' as custom;
import '../../../shared/constants/app_constants.dart';
import '../providers/library_provider.dart';

class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = AppConstants.filterAll;
  String _selectedSort = AppConstants.sortPopular;

  @override
  void initState() {
    super.initState();
    // Load novels when page initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(libraryNotifierProvider.notifier).loadNovels();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch library changes to refresh when novels are added/removed
    ref.watch(libraryNotifierProvider);
    final libraryState = ref.watch(libraryNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
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
                  label: AppConstants.filterCompleted,
                  isSelected: _selectedFilter == AppConstants.filterCompleted,
                  onTap: () => _onFilterChanged(AppConstants.filterCompleted),
                ),
                const SizedBox(width: AppConstants.spacingS),
                custom.FilterChip(
                  label: AppConstants.filterOngoing,
                  isSelected: _selectedFilter == AppConstants.filterOngoing,
                  onTap: () => _onFilterChanged(AppConstants.filterOngoing),
                ),
              ],
            ),
          ),
          
          // Novels Grid
          Expanded(
            child: libraryState.when(
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
                        ref.invalidate(libraryNotifierProvider);
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
              Icons.library_books_outlined,
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
            onTap: () => gAds.rewardInstance.showRewardAd(() {
              _navigateToNovelDetails(novel.id);
            }),
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
    ref.read(libraryNotifierProvider.notifier).filterNovels(filter);
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
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: Text(novel.isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
              onTap: () {
                Navigator.pop(context);
                ref.read(libraryNotifierProvider.notifier).toggleFavorite(novel.id);
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: Text(novel.isDownloaded ? 'Remove Download' : 'Download'),
              onTap: () {
                Navigator.pop(context);
                ref.read(libraryNotifierProvider.notifier).toggleDownload(novel.id);
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
              ref.read(libraryNotifierProvider.notifier).searchNovels(_searchController.text);
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
                ref.read(libraryNotifierProvider.notifier).sortNovels(value!);
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
                ref.read(libraryNotifierProvider.notifier).sortNovels(value!);
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
                ref.read(libraryNotifierProvider.notifier).sortNovels(value!);
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
                ref.read(libraryNotifierProvider.notifier).sortNovels(value!);
              },
            ),
          ],
        ),
      ),
    );
  }
}
