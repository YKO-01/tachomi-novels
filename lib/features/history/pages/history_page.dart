import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/models/novel_history.dart';
import '../../../shared/constants/app_constants.dart';
import '../providers/history_provider.dart';

/// HistoryPage - Displays reading history with clean, minimal design
/// Shows novels with cover, title, last chapter, and read time
class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(context, ref, theme),
      body: _buildBody(context, ref, historyState, theme),
    );
  }

  // MARK: - App Bar
  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref, ThemeData theme) {
    return AppBar(
      title: const Text('History'),
      centerTitle: true,
      actions: [
        if (ref.watch(historyCountProvider) > 0) ...[
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) => _handleSortSelection(ref, value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'recent',
                child: ListTile(
                  leading: Icon(Icons.access_time),
                  title: Text('Most Recent'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'title',
                child: ListTile(
                  leading: Icon(Icons.sort_by_alpha),
                  title: Text('Title A-Z'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'author',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Author A-Z'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: ListTile(
                  leading: Icon(Icons.clear_all, color: Colors.red),
                  title: Text('Clear All', style: TextStyle(color: Colors.red)),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  // MARK: - Body
  Widget _buildBody(BuildContext context, WidgetRef ref, AsyncValue<List<NovelHistory>> historyState, ThemeData theme) {
    return historyState.when(
      data: (histories) => _buildHistoryContent(context, ref, histories, theme),
      loading: () => _buildLoadingView(theme),
      error: (error, stack) => _buildErrorView(context, ref, error, theme),
    );
  }

  Widget _buildHistoryContent(BuildContext context, WidgetRef ref, List<NovelHistory> histories, ThemeData theme) {
    if (histories.isEmpty) {
      return _buildEmptyState(theme);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(historyProvider.notifier).refreshHistories(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        itemCount: histories.length,
        separatorBuilder: (context, index) => const SizedBox(height: AppConstants.spacingS),
        itemBuilder: (context, index) {
          final history = histories[index];
          return _buildHistoryCard(context, ref, history, theme);
        },
      ),
    );
  }

  Widget _buildLoadingView(ThemeData theme) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorView(BuildContext context, WidgetRef ref, dynamic error, ThemeData theme) {
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
            'Failed to Load History',
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
            onPressed: () => ref.read(historyProvider.notifier).refreshHistories(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            'No History Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'Start reading to see your history here!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // MARK: - History Card
  Widget _buildHistoryCard(BuildContext context, WidgetRef ref, NovelHistory history, ThemeData theme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      ),
      child: InkWell(
        onTap: () => _navigateToReader(context, history),
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          child: Row(
            children: [
              _buildCoverImage(history, theme),
              const SizedBox(width: AppConstants.spacingM),
              Expanded(
                child: _buildNovelInfo(history, theme),
              ),
              _buildActionButton(context, ref, history),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(NovelHistory history, ThemeData theme) {
    return Container(
      width: 60,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: history.coverUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: history.coverUrl,
                fit: BoxFit.cover,
                httpHeaders: const {
                  'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                },
                maxWidthDiskCache: 500,
                maxHeightDiskCache: 700,
                placeholder: (context, url) => _buildPlaceholderIcon(theme),
                errorWidget: (context, url, error) => _buildPlaceholderIcon(theme),
              )
            : _buildPlaceholderIcon(theme),
      ),
    );
  }

  Widget _buildPlaceholderIcon(ThemeData theme) {
    return Icon(
      Icons.book,
      color: theme.colorScheme.primary.withValues(alpha: 0.6),
      size: 30,
    );
  }

  Widget _buildNovelInfo(NovelHistory history, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          history.novelTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        const SizedBox(height: AppConstants.spacingXS),
        
        // Author
        Text(
          history.author,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        
        const SizedBox(height: AppConstants.spacingS),
        
        // Last Chapter
        Row(
          children: [
            Icon(
              Icons.menu_book,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              history.lastChapterDisplay,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: AppConstants.spacingXS),
        
        // Last Read Time
        Row(
          children: [
            Icon(
              Icons.access_time,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              history.formattedLastRead,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, WidgetRef ref, NovelHistory history) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) => _handleActionSelection(context, ref, value, history),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'continue',
          child: ListTile(
            leading: Icon(Icons.play_arrow),
            title: Text('Continue Reading'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'details',
          child: ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('View Details'),
            contentPadding: EdgeInsets.zero,
          ),
        ),
        const PopupMenuItem(
          value: 'remove',
          child: ListTile(
            leading: Icon(Icons.delete_outline, color: Colors.red),
            title: Text('Remove', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
          ),
        ),
      ],
    );
  }

  // MARK: - Action Handlers
  void _handleSortSelection(WidgetRef ref, String value) {
    switch (value) {
      case 'recent':
        ref.read(historyProvider.notifier).sortByRecent();
        break;
      case 'title':
        ref.read(historyProvider.notifier).sortByTitle();
        break;
      case 'author':
        ref.read(historyProvider.notifier).sortByAuthor();
        break;
      case 'clear':
        _showClearAllDialog(ref);
        break;
    }
  }

  void _handleActionSelection(BuildContext context, WidgetRef ref, String value, NovelHistory history) {
    switch (value) {
      case 'continue':
      case 'details':
        _navigateToReader(context, history);
        break;
      case 'remove':
        _removeNovelFromHistory(ref, history);
        break;
    }
  }

  void _navigateToReader(BuildContext context, NovelHistory history) {
    // Navigate to reader with the last chapter
    context.push('/reader/${history.novelId}/${history.lastChapterId}');
  }

  void _removeNovelFromHistory(WidgetRef ref, NovelHistory history) {
    ref.read(historyProvider.notifier).removeNovelFromHistory(history.novelId);
  }

  void _showClearAllDialog(WidgetRef ref) {
    // This would show a confirmation dialog
    // For now, we'll just clear directly
    ref.read(historyProvider.notifier).clearAllHistory();
  }
}
