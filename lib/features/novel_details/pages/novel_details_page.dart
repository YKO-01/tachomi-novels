import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/novel.dart';
import '../../../core/models/chapter.dart';
import '../../../core/services/library_service.dart';
import '../../../shared/constants/app_constants.dart';
import '../providers/novel_details_provider.dart';

class NovelDetailsPage extends ConsumerStatefulWidget {
  final String novelId;

  const NovelDetailsPage({
    super.key,
    required this.novelId,
  });

  @override
  ConsumerState<NovelDetailsPage> createState() => _NovelDetailsPageState();
}

class _NovelDetailsPageState extends ConsumerState<NovelDetailsPage> {
  @override
  void initState() {
    super.initState();
    // The provider will automatically load the data
  }

  @override
  Widget build(BuildContext context) {
    final novelDetailsState = ref.watch(novelDetailsNotifierProvider(widget.novelId));
    final theme = Theme.of(context);

    return Scaffold(
      floatingActionButton: novelDetailsState.when(
        data: (data) => FloatingActionButton.extended(
          onPressed: () {
            final novel = data['novel'] as Novel;
            final chapters = data['chapters'] as List<Chapter>;
            if (chapters.isNotEmpty) {
              context.push('/reader/${novel.id}/${chapters.first.id}');
            }
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('Start Reading'),
        ),
        loading: () => null,
        error: (error, stack) => null,
      ),
      body: novelDetailsState.when(
        data: (data) => _buildNovelDetails(data['novel'] as Novel, data['chapters'] as List<Chapter>),
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
                'Failed to load novel details',
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
                  ref.invalidate(novelDetailsNotifierProvider(widget.novelId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Future<Map<String, dynamic>> _getChapterStatus(String novelId, String chapterId) async {
    // History feature removed - always return unread status
    return {
      'isRead': false,
      'progress': 0.0,
      'isCompleted': false,
    };
  }

  Widget _buildNovelDetails(Novel novel, List<Chapter> chapters) {
    return CustomScrollView(
      slivers: [
        // App Bar with cover image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: CachedNetworkImage(
              imageUrl: novel.coverUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Theme.of(context).colorScheme.surface,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Theme.of(context).colorScheme.surface,
                child: const Icon(Icons.image_not_supported, size: 64),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(
                novel.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: novel.isFavorite ? Colors.red : null,
              ),
              onPressed: () {
                ref.read(novelDetailsNotifierProvider(widget.novelId).notifier).toggleFavorite();
              },
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {
                // Share functionality
              },
            ),
          ],
        ),
        
        // Novel Info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spacingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title and Author
                Text(
                  novel.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: AppConstants.spacingS),
                Text(
                  'by ${novel.author}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
                
                const SizedBox(height: AppConstants.spacingM),
                
                // Rating and Views
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber[600], size: 20),
                    const SizedBox(width: AppConstants.spacingXS),
                    Text(
                      novel.rating.toString(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(width: AppConstants.spacingM),
                    Icon(Icons.visibility, size: 20, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                    const SizedBox(width: AppConstants.spacingXS),
                    Text(
                      '${(novel.views / 1000).toStringAsFixed(1)}K views',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                
                const SizedBox(height: AppConstants.spacingM),
                
                // Tags
                Wrap(
                  spacing: AppConstants.spacingS,
                  runSpacing: AppConstants.spacingS,
                  children: novel.tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                  novel.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                
                const SizedBox(height: AppConstants.spacingM),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: Consumer(
                        builder: (context, ref, child) {
                          final isInLibraryAsync = ref.watch(isNovelInLibraryProvider(novel.id));
                          return isInLibraryAsync.when(
                            data: (isInLibrary) => ElevatedButton.icon(
                              onPressed: () async {
                                await LibraryService.toggleLibrary(novel.id);
                                // Invalidate the provider to refresh the UI
                                ref.invalidate(isNovelInLibraryProvider(novel.id));
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
                            ),
                            loading: () => ElevatedButton.icon(
                              onPressed: null,
                              icon: const CircularProgressIndicator(),
                              label: const Text('Loading...'),
                            ),
                            error: (error, stack) => ElevatedButton.icon(
                              onPressed: () async {
                                await LibraryService.toggleLibrary(novel.id);
                                ref.invalidate(isNovelInLibraryProvider(novel.id));
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Add to Library'),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppConstants.spacingS),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // WebView functionality
                        },
                        icon: const Icon(Icons.web),
                        label: const Text('WebView'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Chapters List
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
              return FutureBuilder<Map<String, dynamic>>(
                future: _getChapterStatus(novel.id, chapter.id),
                builder: (context, snapshot) {
                  final isRead = snapshot.data?['isRead'] ?? false;
                  final progress = snapshot.data?['progress'] ?? 0.0;
                  
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isRead 
                          ? Colors.green.withOpacity(0.1)
                          : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      child: isRead 
                          ? Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            )
                          : Text(
                              chapter.chapterNumber.toString(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    title: Text(
                      chapter.title,
                      style: TextStyle(
                        fontWeight: isRead ? FontWeight.w500 : FontWeight.normal,
                        color: isRead 
                            ? Theme.of(context).colorScheme.onSurface.withOpacity(0.7)
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Updated ${_getTimeAgo(chapter.publishedAt)}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (isRead && progress > 0) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.book,
                                size: 12,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                progress >= 1.0 ? 'Completed' : '${(progress * 100).toInt()}% read',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (chapter.isDownloaded)
                      Icon(
                        Icons.download_done,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.download),
                        onPressed: () {
                          // Download chapter
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        _showChapterOptions(chapter);
                      },
                    ),
                  ],
                ),
                    onTap: () {
                      // Navigate to reader
                      context.push('/reader/${novel.id}/${chapter.id}');
                    },
                  );
                },
              );
            },
            childCount: chapters.length,
          ),
        ),
        
        // Bottom spacing for floating button
        const SliverToBoxAdapter(
          child: SizedBox(height: 80),
        ),
      ],
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _showChapterOptions(Chapter chapter) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.download),
              title: Text(chapter.isDownloaded ? 'Remove Download' : 'Download Chapter'),
              onTap: () {
                Navigator.pop(context);
                // Toggle download
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark_border),
              title: const Text('Bookmark Chapter'),
              onTap: () {
                Navigator.pop(context);
                // Bookmark functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Chapter'),
              onTap: () {
                Navigator.pop(context);
                // Share functionality
              },
            ),
          ],
        ),
      ),
    );
  }
}
