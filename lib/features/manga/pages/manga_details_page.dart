import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:tachomi_novel/const.dart';
import '../../../core/models/manga.dart';
import '../../../core/models/manga_chapter.dart';
import '../../../core/services/library_service.dart';
import '../../../core/services/favorites_service.dart';
import '../../../shared/constants/app_constants.dart';
import '../providers/manga_providers.dart';

class MangaDetailsPage extends ConsumerStatefulWidget {
  final String mangaId;

  const MangaDetailsPage({
    super.key,
    required this.mangaId,
  });

  @override
  ConsumerState<MangaDetailsPage> createState() => _MangaDetailsPageState();
}

class _MangaDetailsPageState extends ConsumerState<MangaDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final mangaAsync = ref.watch(mangaDetailsProvider(widget.mangaId));
    final chaptersAsync = ref.watch(mangaChaptersProvider(widget.mangaId));
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: mangaAsync.maybeWhen(
        data: (manga) => chaptersAsync.maybeWhen(
          data: (chapters) => manga != null && chapters.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: () {
                    gAds.interInstance.showInterstitialAd();
                    context.push('/manga-reader/${manga.id}/${chapters.first.id}');
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start Reading'),
                )
              : null,
          orElse: () => null,
        ),
        orElse: () => null,
      ),
      body: mangaAsync.when(
        data: (manga) {
          if (manga == null) {
            return const Center(child: Text('Manga not found'));
          }
          return _buildMangaDetails(manga, chaptersAsync);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
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
                'Failed to load manga details',
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
                  ref.invalidate(mangaDetailsProvider(widget.mangaId));
                  ref.invalidate(mangaChaptersProvider(widget.mangaId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMangaDetails(Manga manga, AsyncValue<List<MangaChapter>> chaptersAsync) {
    return CustomScrollView(
      slivers: [
        // App Bar with cover image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: CachedNetworkImage(
              imageUrl: manga.coverImage,
              fit: BoxFit.cover,
              httpHeaders: const {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
              },
              maxWidthDiskCache: 1000,
              maxHeightDiskCache: 1000,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image_not_supported, size: 64),
              ),
            ),
          ),
          actions: [
            Consumer(
              builder: (context, ref, child) {
                final isFavoriteAsync = ref.watch(isNovelFavoriteProvider(manga.id));
                final isFavorite = isFavoriteAsync.valueOrNull ?? false;
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () async {
                    await FavoritesService.toggleFavorite(manga.id);
                    ref.invalidate(isNovelFavoriteProvider(manga.id));
                    ref.invalidate(mangaFavoritesProvider);
                  },
                );
              },
            ),
          ],
        ),

        // Manga Info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Type
                Text(
                  manga.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  '${manga.type} • ${manga.status}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Rating
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber[600], size: 20),
                    const SizedBox(width: AppConstants.spacingXS),
                    Text(
                      manga.rating.toString(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Genres
                Wrap(
                  spacing: AppConstants.spacingS,
                  runSpacing: AppConstants.spacingS,
                  children: manga.genres.map((genre) => Chip(
                    label: Text(genre),
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  )).toList(),
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Description
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  manga.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),

                const SizedBox(height: AppConstants.spacingM),

                // Library Button
                Row(
                  children: [
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final isInLibraryAsync = ref.watch(isNovelInLibraryProvider(manga.id));
                          final isInLibrary = isInLibraryAsync.valueOrNull ?? false;
                          return ElevatedButton.icon(
                            onPressed: () async {
                              await LibraryService.toggleLibrary(manga.id);
                              ref.invalidate(isNovelInLibraryProvider(manga.id));
                              ref.invalidate(mangaLibraryProvider);
                            },
                            icon: Icon(isInLibrary ? Icons.remove : Icons.add),
                            label: Text(isInLibrary ? 'Remove from Library' : 'Add to Library'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isInLibrary
                                ? Theme.of(context).colorScheme.error
                                : Theme.of(context).colorScheme.primary,
                              foregroundColor: isInLibrary
                                ? Theme.of(context).colorScheme.onError
                                : Theme.of(context).colorScheme.onPrimary,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Chapters List
        chaptersAsync.when(
          data: (chapters) => SliverMainAxisGroup(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingM),
                  child: Text(
                    'Chapters (${chapters.length})',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final chapter = chapters[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        child: Text(
                          chapter.displayNumber,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      title: Text('Chapter ${chapter.displayNumber}'),
                      subtitle: Text(
                        '${chapter.pages.length} pages',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      onTap: () {
                        gAds.interInstance.showInterstitialAd();
                        context.push('/manga-reader/${manga.id}/${chapter.id}');
                      },
                    );
                  },
                  childCount: chapters.length,
                ),
              ),
            ],
          ),
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.spacingL),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, stack) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              child: Text(
                'Failed to load chapters',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),
        ),

        // Bottom spacing for floating button
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }
}
