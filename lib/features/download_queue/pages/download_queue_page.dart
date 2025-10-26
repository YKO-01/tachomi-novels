import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/constants/app_constants.dart';
import '../providers/download_queue_provider.dart';

class DownloadQueuePage extends ConsumerWidget {
  const DownloadQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadQueue = ref.watch(downloadQueueProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Download Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              _showClearAllDialog(context, ref);
            },
          ),
        ],
      ),
      body: downloadQueue.isEmpty
          ? _buildEmptyState(context)
          : ListView.builder(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              itemCount: downloadQueue.length,
              itemBuilder: (context, index) {
                final item = downloadQueue[index];
                return _buildDownloadItem(context, ref, item);
              },
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
            Icons.download_done,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.spacingM),
          Text(
            'No Downloads',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppConstants.spacingS),
          Text(
            'Your download queue is empty',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadItem(BuildContext context, WidgetRef ref, DownloadItem item) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.spacingS),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(item.status).withValues(alpha: 0.1),
          child: Icon(
            _getStatusIcon(item.status),
            color: _getStatusColor(item.status),
          ),
        ),
        title: Text(
          item.chapter.title,
          style: theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${item.novel.title} - Chapter ${item.chapter.chapterNumber}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: AppConstants.spacingXS),
            _buildProgressIndicator(item),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'pause':
                ref.read(downloadQueueProvider.notifier).pauseDownload(item.id);
                break;
              case 'resume':
                ref.read(downloadQueueProvider.notifier).resumeDownload(item.id);
                break;
              case 'cancel':
                ref.read(downloadQueueProvider.notifier).cancelDownload(item.id);
                break;
              case 'retry':
                ref.read(downloadQueueProvider.notifier).retryDownload(item.id);
                break;
            }
          },
          itemBuilder: (context) => [
            if (item.status == DownloadStatus.downloading)
              const PopupMenuItem(
                value: 'pause',
                child: ListTile(
                  leading: Icon(Icons.pause),
                  title: Text('Pause'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            if (item.status == DownloadStatus.paused)
              const PopupMenuItem(
                value: 'resume',
                child: ListTile(
                  leading: Icon(Icons.play_arrow),
                  title: Text('Resume'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            if (item.status == DownloadStatus.failed)
              const PopupMenuItem(
                value: 'retry',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Retry'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            const PopupMenuItem(
              value: 'cancel',
              child: ListTile(
                leading: Icon(Icons.cancel),
                title: Text('Cancel'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(DownloadItem item) {
    if (item.status == DownloadStatus.completed) {
      return Row(
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: Colors.green[600],
          ),
          const SizedBox(width: AppConstants.spacingXS),
          Text(
            'Completed',
            style: TextStyle(
              color: Colors.green[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    
    if (item.status == DownloadStatus.failed) {
      return Row(
        children: [
          Icon(
            Icons.error,
            size: 16,
            color: Colors.red[600],
          ),
          const SizedBox(width: AppConstants.spacingXS),
          Text(
            'Failed',
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    
    if (item.status == DownloadStatus.paused) {
      return Row(
        children: [
          Icon(
            Icons.pause_circle,
            size: 16,
            color: Colors.orange[600],
          ),
          const SizedBox(width: AppConstants.spacingXS),
          Text(
            'Paused',
            style: TextStyle(
              color: Colors.orange[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }
    
    // Downloading or queued
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LinearProgressIndicator(
          value: item.progress,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(
            _getStatusColor(item.status),
          ),
        ),
        const SizedBox(height: AppConstants.spacingXS),
        Text(
          '${(item.progress * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.queued:
        return Colors.blue;
      case DownloadStatus.downloading:
        return Colors.blue;
      case DownloadStatus.paused:
        return Colors.orange;
      case DownloadStatus.completed:
        return Colors.green;
      case DownloadStatus.failed:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(DownloadStatus status) {
    switch (status) {
      case DownloadStatus.queued:
        return Icons.queue;
      case DownloadStatus.downloading:
        return Icons.download;
      case DownloadStatus.paused:
        return Icons.pause;
      case DownloadStatus.completed:
        return Icons.check;
      case DownloadStatus.failed:
        return Icons.error;
    }
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Downloads'),
        content: const Text('Are you sure you want to clear all downloads? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(downloadQueueProvider.notifier).clearAll();
              Navigator.pop(context);
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
