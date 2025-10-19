import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/novel.dart';
import '../../../core/models/chapter.dart';
import '../../../shared/constants/app_constants.dart';
import '../providers/updates_provider.dart';

class UpdatesPage extends ConsumerWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final updatesState = ref.watch(updatesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Updates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.invalidate(updatesProvider);
            },
          ),
        ],
      ),
      body: updatesState.when(
        data: (updates) => updates.isEmpty
            ? _buildEmptyState(context)
            : _buildUpdatesList(context, ref, updates),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: AppConstants.spacingM),
              Text('Failed to load updates', style: theme.textTheme.headlineSmall),
              const SizedBox(height: AppConstants.spacingS),
              Text(error.toString(), style: theme.textTheme.bodyMedium),
              const SizedBox(height: AppConstants.spacingM),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(updatesProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
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
            Icons.update,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'No Updates',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'No new chapters available',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdatesList(BuildContext context, WidgetRef ref, List<UpdateItem> updates) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      itemCount: updates.length,
      itemBuilder: (context, index) {
        final update = updates[index];
        return _buildUpdateItem(context, ref, update);
      },
    );
  }

  Widget _buildUpdateItem(BuildContext context, WidgetRef ref, UpdateItem update) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(update.status).withValues(alpha: 0.1),
          child: Icon(
            _getStatusIcon(update.status),
            color: _getStatusColor(update.status),
          ),
        ),
        title: Text(
          update.chapter.title,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${update.novel.title} - Chapter ${update.chapter.chapterNumber}',
              style: theme.textTheme.bodySmall,
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
                  _formatDate(update.chapter.publishedAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const Spacer(),
                _buildStatusChip(update.status),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'read':
                _readChapter(context, update);
                break;
              case 'download':
                ref.read(updatesProvider.notifier).downloadChapter(update.novel, update.chapter);
                break;
              case 'mark_read':
                ref.read(updatesProvider.notifier).markAsRead(update.id);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'read',
              child: ListTile(
                leading: Icon(Icons.play_arrow),
                title: Text('Read Now'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const PopupMenuItem(
              value: 'download',
              child: ListTile(
                leading: Icon(Icons.download),
                title: Text('Download'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            if (update.status == UpdateStatus.unread)
              const PopupMenuItem(
                value: 'mark_read',
                child: ListTile(
                  leading: Icon(Icons.check),
                  title: Text('Mark as Read'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
          ],
        ),
        onTap: () => _readChapter(context, update),
      ),
    );
  }

  Widget _buildStatusChip(UpdateStatus status) {
    Color color;
    String text;
    
    switch (status) {
      case UpdateStatus.newChapter:
        color = Colors.green;
        text = 'New';
        break;
      case UpdateStatus.unread:
        color = Colors.blue;
        text = 'Unread';
        break;
      case UpdateStatus.read:
        color = Colors.grey;
        text = 'Read';
        break;
      case UpdateStatus.downloaded:
        color = Colors.purple;
        text = 'Downloaded';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getStatusColor(UpdateStatus status) {
    switch (status) {
      case UpdateStatus.newChapter:
        return Colors.green;
      case UpdateStatus.unread:
        return Colors.blue;
      case UpdateStatus.read:
        return Colors.grey;
      case UpdateStatus.downloaded:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon(UpdateStatus status) {
    switch (status) {
      case UpdateStatus.newChapter:
        return Icons.new_releases;
      case UpdateStatus.unread:
        return Icons.mark_email_unread;
      case UpdateStatus.read:
        return Icons.check;
      case UpdateStatus.downloaded:
        return Icons.download_done;
    }
  }

  void _readChapter(BuildContext context, UpdateItem update) {
    context.push('/reader/${update.novel.id}/${update.chapter.id}');
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
