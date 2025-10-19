import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/novel.dart';
import '../../../core/models/chapter.dart';
import '../../download_queue/providers/download_queue_provider.dart';

enum UpdateStatus { newChapter, unread, read, downloaded }

class UpdateItem {
  final String id;
  final Novel novel;
  final Chapter chapter;
  final UpdateStatus status;
  final DateTime publishedAt;

  const UpdateItem({
    required this.id,
    required this.novel,
    required this.chapter,
    required this.status,
    required this.publishedAt,
  });

  UpdateItem copyWith({
    String? id,
    Novel? novel,
    Chapter? chapter,
    UpdateStatus? status,
    DateTime? publishedAt,
  }) {
    return UpdateItem(
      id: id ?? this.id,
      novel: novel ?? this.novel,
      chapter: chapter ?? this.chapter,
      status: status ?? this.status,
      publishedAt: publishedAt ?? this.publishedAt,
    );
  }
}

class UpdatesNotifier extends StateNotifier<AsyncValue<List<UpdateItem>>> {
  UpdatesNotifier() : super(const AsyncValue.loading()) {
    _loadUpdates();
  }

  Future<void> _loadUpdates() async {
    state = const AsyncValue.loading();
    
    try {
      // Simulate loading updates from storage
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Mock updates data
      final updates = [
        UpdateItem(
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
            id: '1-46',
            novelId: '1',
            title: 'The Shadow\'s Embrace',
            chapterNumber: 46,
            content: 'The shadows wrapped around Elara like a protective cloak...',
            publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
            wordCount: 3200,
          ),
          status: UpdateStatus.newChapter,
          publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
        ),
        UpdateItem(
          id: '2',
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
            id: '3-23',
            novelId: '3',
            title: 'The Final Station',
            chapterNumber: 23,
            content: 'The train slowed as it approached what appeared to be the final station...',
            publishedAt: DateTime.now().subtract(const Duration(days: 1)),
            wordCount: 2800,
          ),
          status: UpdateStatus.unread,
          publishedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        UpdateItem(
          id: '3',
          novel: Novel(
            id: '4',
            title: 'Love in Translation',
            author: 'Maya Patel',
            description: 'A bilingual romance that explores the beauty of communication across languages and cultures.',
            coverUrl: 'https://picsum.photos/300/400?random=4',
            tags: ['Romance', 'BL', 'Cultural'],
            status: 'Ongoing',
            totalChapters: 38,
            lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
            rating: 4.7,
            views: 98000,
          ),
          chapter: Chapter(
            id: '4-39',
            novelId: '4',
            title: 'Lost in Translation',
            chapterNumber: 39,
            content: 'The language barrier seemed insurmountable, but their hearts spoke the same language...',
            publishedAt: DateTime.now().subtract(const Duration(days: 2)),
            wordCount: 2400,
          ),
          status: UpdateStatus.downloaded,
          publishedAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        UpdateItem(
          id: '4',
          novel: Novel(
            id: '6',
            title: 'Starlight Academy',
            author: 'Luna Star',
            description: 'A magical academy where students learn to harness the power of starlight in this enchanting coming-of-age story.',
            coverUrl: 'https://picsum.photos/300/400?random=6',
            tags: ['Fantasy', 'School Life', 'Magic'],
            status: 'Ongoing',
            totalChapters: 28,
            lastUpdated: DateTime.now().subtract(const Duration(days: 4)),
            rating: 4.8,
            views: 134000,
          ),
          chapter: Chapter(
            id: '6-29',
            novelId: '6',
            title: 'The Starlight Ceremony',
            chapterNumber: 29,
            content: 'The annual starlight ceremony was about to begin...',
            publishedAt: DateTime.now().subtract(const Duration(days: 3)),
            wordCount: 2600,
          ),
          status: UpdateStatus.read,
          publishedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ];
      
      // Sort by published date (newest first)
      updates.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
      
      state = AsyncValue.data(updates);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void markAsRead(String id) {
    state.whenData((updates) {
      final updatedUpdates = updates.map((update) {
        if (update.id == id) {
          return update.copyWith(status: UpdateStatus.read);
        }
        return update;
      }).toList();
      state = AsyncValue.data(updatedUpdates);
    });
  }

  void downloadChapter(Novel novel, Chapter chapter) {
    // Add to download queue
    // This would typically be done through a service
    // For now, we'll just update the status
    state.whenData((updates) {
      final updatedUpdates = updates.map((update) {
        if (update.novel.id == novel.id && update.chapter.id == chapter.id) {
          return update.copyWith(status: UpdateStatus.downloaded);
        }
        return update;
      }).toList();
      state = AsyncValue.data(updatedUpdates);
    });
  }
}

final updatesProvider = StateNotifierProvider<UpdatesNotifier, AsyncValue<List<UpdateItem>>>((ref) {
  return UpdatesNotifier();
});
