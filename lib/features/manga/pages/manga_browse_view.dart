import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tachomi_novel/const.dart';
import '../../../core/models/manga.dart';
import '../../../core/services/library_service.dart';
import '../../../core/services/favorites_service.dart';
import '../../../shared/widgets/manga_card.dart';
import '../../../shared/widgets/filter_chip.dart' as custom;
import '../../../shared/constants/app_constants.dart';
import '../providers/manga_providers.dart';

/// Manga grid with genre filter chips, shown inside BrowsePage when
/// the content type toggle is set to Manga.
class MangaBrowseView extends ConsumerStatefulWidget {
  const MangaBrowseView({super.key});

  @override
  ConsumerState<MangaBrowseView> createState() => _MangaBrowseViewState();
}

class _MangaBrowseViewState extends ConsumerState<MangaBrowseView> {
  String _selectedFilter = AppConstants.filterAll;

  static const List<String> _genreFilters = [
    AppConstants.filterAll,
    'Action',
    'Fantasy',
    'Martial Arts',
    'Murim',
    'Drama',
    'Shounen',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mangaBrowseNotifierProvider.notifier).loadMangas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mangaState = ref.watch(mangaBrowseNotifierProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        // Genre Filter Chips
        Container(
          height: 60,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingS),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
            itemCount: _genreFilters.length,
            separatorBuilder: (context, index) => const SizedBox(width: AppConstants.spacingS),
            itemBuilder: (context, index) {
              final filter = _genreFilters[index];
              return custom.FilterChip(
                label: filter,
                isSelected: _selectedFilter == filter,
                onTap: () => _onFilterChanged(filter),
              );
            },
          ),
        ),

        // Manga Grid
        Expanded(
          child: mangaState.when(
            data: (mangas) => _buildMangaGrid(mangas),
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
                    'Failed to load manga',
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
                      ref.read(mangaBrowseNotifierProvider.notifier).loadMangas();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMangaGrid(List<Manga> mangas) {
    if (mangas.isEmpty) {
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
              'No manga found',
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
        itemCount: mangas.length,
        itemBuilder: (context, index) {
          final manga = mangas[index];
          return MangaCard(
            manga: manga,
            onTap: () {
              gAds.interInstance.showInterstitialAd();
              context.push('/manga-details/${manga.id}');
            },
            onLongPress: () => _showMangaOptions(manga),
          );
        },
      ),
    );
  }

  void _onFilterChanged(String filter) {
    setState(() {
      _selectedFilter = filter;
    });
    ref.read(mangaBrowseNotifierProvider.notifier).filterMangas(filter);
  }

  void _showMangaOptions(Manga manga) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Consumer(
              builder: (context, ref, child) {
                final isInLibraryAsync = ref.watch(isNovelInLibraryProvider(manga.id));
                final isInLibrary = isInLibraryAsync.valueOrNull ?? false;
                return ListTile(
                  leading: Icon(isInLibrary ? Icons.remove_circle : Icons.library_add),
                  title: Text(isInLibrary ? 'Remove from Library' : 'Add to Library'),
                  onTap: () async {
                    Navigator.pop(context);
                    await LibraryService.toggleLibrary(manga.id);
                    ref.invalidate(isNovelInLibraryProvider(manga.id));
                    ref.invalidate(mangaLibraryProvider);
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        SnackBar(
                          content: Text(isInLibrary
                              ? '${manga.title} removed from library'
                              : '${manga.title} added to library'),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                );
              },
            ),
            Consumer(
              builder: (context, ref, child) {
                final isFavoriteAsync = ref.watch(isNovelFavoriteProvider(manga.id));
                final isFavorite = isFavoriteAsync.valueOrNull ?? false;
                return ListTile(
                  leading: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                  title: Text(isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                  onTap: () async {
                    Navigator.pop(context);
                    await FavoritesService.toggleFavorite(manga.id);
                    ref.invalidate(isNovelFavoriteProvider(manga.id));
                    ref.invalidate(mangaFavoritesProvider);
                  },
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('View Details'),
              onTap: () {
                Navigator.pop(context);
                context.push('/manga-details/${manga.id}');
              },
            ),
          ],
        ),
      ),
    );
  }
}
