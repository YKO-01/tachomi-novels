import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/novel.dart';
import '../../../core/models/chapter.dart';

class HistoryItem {
  final String id;
  final Novel novel;
  final Chapter chapter;
  final DateTime lastRead;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;

  const HistoryItem({
    required this.id,
    required this.novel,
    required this.chapter,
    required this.lastRead,
    required this.progress,
    this.isCompleted = false,
  });

  HistoryItem copyWith({
    String? id,
    Novel? novel,
    Chapter? chapter,
    DateTime? lastRead,
    double? progress,
    bool? isCompleted,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      novel: novel ?? this.novel,
      chapter: chapter ?? this.chapter,
      lastRead: lastRead ?? this.lastRead,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class HistoryNotifier extends StateNotifier<AsyncValue<List<HistoryItem>>> {
  HistoryNotifier() : super(const AsyncValue.loading()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    state = const AsyncValue.loading();
    
    try {
      // Simulate loading history from storage
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock history data
      final historyItems = [
        HistoryItem(
          id: '1',
          novel: Novel(
            id: '1',
            title: 'The Crown\'s Shadow',
            author: 'Sarah Chen',
            description: 'A fantasy romance about a princess who discovers her true power lies not in her crown, but in the shadows she casts.',
            coverUrl: 'https://picsum.photos/300/400?random=1',
            tags: ['Fantasy', 'Romance', 'Magic'],
            status: 'Ongoing',
            totalChapters: 45,
            lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
            rating: 4.8,
            views: 125000,
          ),
          chapter: Chapter(
            id: '1-1',
            novelId: '1',
            title: 'The Crown\'s Weight',
            chapterNumber: 1,
            content: 'Princess Elara stood before the mirror, adjusting her heavy crown...',
            publishedAt: DateTime.now().subtract(const Duration(days: 30)),
            wordCount: 2500,
          ),
          lastRead: DateTime.now().subtract(const Duration(hours: 2)),
          progress: 0.75,
        ),
        HistoryItem(
          id: '2',
          novel: Novel(
            id: '2',
            title: 'Coffee Shop Chronicles',
            author: 'Alex Rivera',
            description: 'Slice of life stories from a cozy coffee shop where every customer has a story to tell.',
            coverUrl: 'https://picsum.photos/300/400?random=2',
            tags: ['Slice of Life', 'Comedy', 'Drama'],
            status: 'Completed',
            totalChapters: 30,
            lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
            rating: 4.6,
            views: 89000,
          ),
          chapter: Chapter(
            id: '2-1',
            novelId: '2',
            title: 'Morning Brew',
            chapterNumber: 1,
            content: 'The coffee shop opened its doors at 6 AM sharp...',
            publishedAt: DateTime.now().subtract(const Duration(days: 45)),
            wordCount: 2100,
          ),
          lastRead: DateTime.now().subtract(const Duration(days: 1)),
          progress: 1.0,
          isCompleted: true,
        ),
        HistoryItem(
          id: '3',
          novel: Novel(
            id: '3',
            title: 'Midnight Express',
            author: 'Jordan Kim',
            description: 'A mysterious train that only appears at midnight, taking passengers to destinations unknown.',
            coverUrl: 'https://picsum.photos/300/400?random=3',
            tags: ['Mystery', 'Supernatural', 'Adventure'],
            status: 'Ongoing',
            totalChapters: 22,
            lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
            rating: 4.9,
            views: 156000,
          ),
          chapter: Chapter(
            id: '3-1',
            novelId: '3',
            title: 'The Midnight Station',
            chapterNumber: 1,
            content: 'The station was empty except for the flickering lights...',
            publishedAt: DateTime.now().subtract(const Duration(days: 7)),
            wordCount: 2800,
          ),
          lastRead: DateTime.now().subtract(const Duration(hours: 5)),
          progress: 0.3,
        ),
      ];
      
      state = AsyncValue.data(historyItems);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void addToHistory(Novel novel, Chapter chapter, double progress) {
    state.whenData((items) {
      final existingIndex = items.indexWhere((item) => item.id == '${novel.id}_${chapter.id}');
      
      final newItem = HistoryItem(
        id: '${novel.id}_${chapter.id}',
        novel: novel,
        chapter: chapter,
        lastRead: DateTime.now(),
        progress: progress,
        isCompleted: progress >= 1.0,
      );
      
      List<HistoryItem> updatedItems;
      if (existingIndex >= 0) {
        updatedItems = List.from(items);
        updatedItems[existingIndex] = newItem;
      } else {
        updatedItems = [newItem, ...items];
      }
      
      // Sort by last read date
      updatedItems.sort((a, b) => b.lastRead.compareTo(a.lastRead));
      
      state = AsyncValue.data(updatedItems);
    });
  }

  void removeFromHistory(String id) {
    state.whenData((items) {
      final updatedItems = items.where((item) => item.id != id).toList();
      state = AsyncValue.data(updatedItems);
    });
  }

  void markAsUnread(String id) {
    state.whenData((items) {
      final updatedItems = items.map((item) {
        if (item.id == id) {
          return item.copyWith(progress: 0.0, isCompleted: false);
        }
        return item;
      }).toList();
      state = AsyncValue.data(updatedItems);
    });
  }

  void clearAll() {
    state = const AsyncValue.data([]);
  }

  void sortByRecent() {
    state.whenData((items) {
      final sortedItems = List<HistoryItem>.from(items);
      sortedItems.sort((a, b) => b.lastRead.compareTo(a.lastRead));
      state = AsyncValue.data(sortedItems);
    });
  }

  void sortByNovel() {
    state.whenData((items) {
      final sortedItems = List<HistoryItem>.from(items);
      sortedItems.sort((a, b) => a.novel.title.compareTo(b.novel.title));
      state = AsyncValue.data(sortedItems);
    });
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, AsyncValue<List<HistoryItem>>>((ref) {
  return HistoryNotifier();
});
