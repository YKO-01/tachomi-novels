import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/download_service.dart';
import '../../../core/models/novel.dart';
import '../../../core/models/chapter.dart';

enum DownloadStatus { queued, downloading, paused, completed, failed }

class DownloadItem {
  final String id;
  final Novel novel;
  final Chapter chapter;
  final DownloadStatus status;
  final double progress;
  final DateTime addedAt;
  final String? error;

  const DownloadItem({
    required this.id,
    required this.novel,
    required this.chapter,
    required this.status,
    required this.progress,
    required this.addedAt,
    this.error,
  });

  DownloadItem copyWith({
    String? id,
    Novel? novel,
    Chapter? chapter,
    DownloadStatus? status,
    double? progress,
    DateTime? addedAt,
    String? error,
  }) {
    return DownloadItem(
      id: id ?? this.id,
      novel: novel ?? this.novel,
      chapter: chapter ?? this.chapter,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      addedAt: addedAt ?? this.addedAt,
      error: error ?? this.error,
    );
  }
}

class DownloadQueueNotifier extends StateNotifier<List<DownloadItem>> {
  DownloadQueueNotifier() : super([]);

  void addDownload(Novel novel, Chapter chapter) {
    final id = '${novel.id}_${chapter.id}';
    
    // Check if already exists
    if (state.any((item) => item.id == id)) {
      return;
    }
    
    final downloadItem = DownloadItem(
      id: id,
      novel: novel,
      chapter: chapter,
      status: DownloadStatus.queued,
      progress: 0.0,
      addedAt: DateTime.now(),
    );
    
    state = [...state, downloadItem];
    
    // Start download simulation
    _simulateDownload(downloadItem);
  }

  void pauseDownload(String id) {
    state = state.map((item) {
      if (item.id == id && item.status == DownloadStatus.downloading) {
        return item.copyWith(status: DownloadStatus.paused);
      }
      return item;
    }).toList();
  }

  void resumeDownload(String id) {
    state = state.map((item) {
      if (item.id == id && item.status == DownloadStatus.paused) {
        return item.copyWith(status: DownloadStatus.downloading);
      }
      return item;
    }).toList();
    
    // Resume download simulation
    final item = state.firstWhere((item) => item.id == id);
    _simulateDownload(item);
  }

  void cancelDownload(String id) {
    state = state.where((item) => item.id != id).toList();
  }

  void retryDownload(String id) {
    state = state.map((item) {
      if (item.id == id && item.status == DownloadStatus.failed) {
        return item.copyWith(
          status: DownloadStatus.queued,
          progress: 0.0,
          error: null,
        );
      }
      return item;
    }).toList();
    
    // Start download simulation
    final item = state.firstWhere((item) => item.id == id);
    _simulateDownload(item);
  }

  void clearAll() {
    state = [];
  }

  void _simulateDownload(DownloadItem item) {
    // Simulate download progress
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!state.any((i) => i.id == item.id)) return;
      
      state = state.map((i) {
        if (i.id == item.id && i.status == DownloadStatus.queued) {
          return i.copyWith(status: DownloadStatus.downloading);
        }
        return i;
      }).toList();
      
      _updateProgress(item.id, 0.0);
    });
  }

  void _updateProgress(String id, double progress) {
    if (progress >= 1.0) {
      // Download completed
      state = state.map((item) {
        if (item.id == id) {
          // Persist downloaded chapter for offline reading
          DownloadService.saveChapter(
            item.chapter.copyWith(isDownloaded: true),
          );
          return item.copyWith(
            status: DownloadStatus.completed,
            progress: 1.0,
          );
        }
        return item;
      }).toList();
      return;
    }
    
    // Update progress
    state = state.map((item) {
      if (item.id == id && item.status == DownloadStatus.downloading) {
        return item.copyWith(progress: progress);
      }
      return item;
    }).toList();
    
    // Continue progress simulation
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!state.any((i) => i.id == id)) return;
      
      final currentItem = state.firstWhere((i) => i.id == id);
      if (currentItem.status == DownloadStatus.downloading) {
        _updateProgress(id, progress + 0.1);
      }
    });
  }
}

final downloadQueueProvider = StateNotifierProvider<DownloadQueueNotifier, List<DownloadItem>>((ref) {
  return DownloadQueueNotifier();
});
