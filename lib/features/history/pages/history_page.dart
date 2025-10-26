import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/history_service.dart';
import '../../../shared/constants/app_constants.dart';
import '../providers/history_provider.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyState = ref.watch(historyProvider);
    final theme = Theme.of(context);
    
    // Debug logging
    print('HistoryPage: Building with state: $historyState');
    historyState.when(
      data: (items) => print('HistoryPage: Data state with ${items.length} items'),
      loading: () => print('HistoryPage: Loading state'),
      error: (error, stack) => print('HistoryPage: Error state - $error'),
    );

    // Debug: Check if we need to refresh
    if (historyState.isLoading) {
      print('HistoryPage: Currently loading history...');
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              print('HistoryPage: Manual refresh triggered');
              ref.invalidate(historyProvider);
            },
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () async {
              print('HistoryPage: Debug - Checking history service directly...');
              try {
                final items = await HistoryService.getHistoryItems();
                print('HistoryPage: Debug - History service returned ${items.length} items');
                for (final item in items) {
                  print('HistoryPage: Debug - Item: ${item.novelTitle} - ${item.chapterTitle}');
                }
              } catch (e) {
                print('HistoryPage: Debug - Error: $e');
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'clear_all':
                  _showClearAllDialog(context, ref);
                  break;
                case 'sort_recent':
                  ref.read(historyProvider.notifier).sortByRecent();
                  break;
                case 'sort_novel':
                  ref.read(historyProvider.notifier).sortByNovel();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'sort_recent',
                child: ListTile(
                  leading: Icon(Icons.access_time),
                  title: Text('Sort by Recent'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'sort_novel',
                child: ListTile(
                  leading: Icon(Icons.book),
                  title: Text('Sort by Novel'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: ListTile(
                  leading: Icon(Icons.clear_all),
                  title: Text('Clear All'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Debug info
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.blue.withOpacity(0.1),
            child: Text(
              'Debug: ${historyState.when(
                data: (items) => 'Data: ${items.length} items',
                loading: () => 'Loading...',
                error: (e, s) => 'Error: $e',
              )}',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          // Main content
          Expanded(
            child: historyState.when(
              data: (historyItems) => historyItems.isEmpty
                  ? _buildEmptyState(context)
                  : _buildHistoryList(context, ref, historyItems),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                    const SizedBox(height: AppConstants.spacingM),
                    Text('Failed to load history', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppConstants.spacingS),
                    Text(error.toString(), style: theme.textTheme.bodyMedium),
                    const SizedBox(height: AppConstants.spacingM),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(historyProvider);
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

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'No Reading History',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'Start reading to see your history here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, WidgetRef ref, List<HistoryItem> historyItems) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      itemCount: historyItems.length,
      itemBuilder: (context, index) {
        final item = historyItems[index];
        return _buildHistoryItem(context, ref, item, index);
      },
    );
  }

  Widget _buildHistoryItem(BuildContext context, WidgetRef ref, HistoryItem item, int index) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
      elevation: 2,
      child: ListTile(
        onTap: () => _continueReading(context, item),
        hoverColor: theme.colorScheme.primary.withValues(alpha: 0.05),
        splashColor: theme.colorScheme.primary.withValues(alpha: 0.1),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
          child: Icon(
            item.isCompleted ? Icons.check_circle : Icons.book,
            color: theme.colorScheme.primary,
            size: 20,
          ),
        ),
        title: Text(
          item.novelTitle,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chapter: ${item.chapterTitle}',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: AppConstants.spacingXS),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(item.lastRead),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.isCompleted 
                        ? Colors.green.withValues(alpha: 0.1)
                        : theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    item.isCompleted 
                        ? 'Completed'
                        : '${(item.progress * 100).toInt()}%',
                    style: TextStyle(
                      color: item.isCompleted 
                          ? Colors.green
                          : theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_arrow,
              color: theme.colorScheme.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'continue':
                _continueReading(context, item);
                break;
              case 'remove':
                ref.read(historyProvider.notifier).removeFromHistory(item.id);
                break;
              case 'mark_unread':
                ref.read(historyProvider.notifier).markAsUnread(item.id);
                break;
            }
          },
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
              value: 'mark_unread',
              child: ListTile(
                leading: Icon(Icons.mark_email_unread),
                title: Text('Mark as Unread'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'remove',
              child: ListTile(
                leading: Icon(Icons.delete),
                title: Text('Remove from History'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
    );
  }

  void _continueReading(BuildContext context, HistoryItem item) {
    context.push('/reader/${item.novel.id}/${item.chapter.id}');
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All History'),
        content: const Text('Are you sure you want to clear all reading history? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(historyProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
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
}
