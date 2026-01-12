import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/network_service.dart';
import '../../../core/models/novel.dart';
import '../../../core/models/chapter.dart';

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
  UpdatesNotifier(this._isOnline) : super(const AsyncValue.loading()) {
    _loadUpdates();
  }

  final bool _isOnline;
  
  // Supabase URLs for remote JSON files
  static const String _novelsJsonUrl = 'https://dufgldnpzvzrmpwmskli.supabase.co/storage/v1/object/public/json-novels/mock_novels.json';
  static const String _chaptersJsonUrl = 'https://dufgldnpzvzrmpwmskli.supabase.co/storage/v1/object/public/json-novels/mock_chapters.json';

  Future<void> _loadUpdates() async {
    state = const AsyncValue.loading();
    if (!_isOnline) {
      state = const AsyncValue.data([]);
      return;
    }
    
    try {
      // Load novels from remote JSON
      final novelsResponse = await http.get(Uri.parse(_novelsJsonUrl));
      if (novelsResponse.statusCode != 200) {
        throw Exception('Failed to load novels: ${novelsResponse.statusCode}');
      }
      final String novelsJsonString = novelsResponse.body;
      final List<dynamic> novelsJsonList = json.decode(novelsJsonString);
      
      // Load chapters from remote JSON (which has chapters nested in novels)
      final chaptersResponse = await http.get(Uri.parse(_chaptersJsonUrl));
      if (chaptersResponse.statusCode != 200) {
        throw Exception('Failed to load chapters: ${chaptersResponse.statusCode}');
      }
      final String chaptersJsonString = chaptersResponse.body;
      final List<dynamic> chaptersJsonList = json.decode(chaptersJsonString);
      
      // Create a map of novel ID to Novel object
      final Map<String, Novel> novelsMap = {};
      for (var novelJson in novelsJsonList) {
        final novel = Novel(
          id: novelJson['id'],
          title: novelJson['title'],
          author: novelJson['author'],
          description: novelJson['description'],
          coverUrl: novelJson['coverUrl'],
          tags: List<String>.from(novelJson['tags']),
          status: novelJson['status'],
          totalChapters: novelJson['totalChapters'],
          lastUpdated: DateTime.parse(novelJson['lastUpdated']),
          rating: (novelJson['rating'] as num).toDouble(),
          views: novelJson['views'],
          isFavorite: novelJson['isFavorite'] ?? false,
          isDownloaded: novelJson['isDownloaded'] ?? false,
          currentChapter: novelJson['currentChapter'] ?? 0,
        );
        novelsMap[novel.id] = novel;
      }
      
      // Create UpdateItems from chapters
      final List<UpdateItem> updates = [];
      
      for (var novelWithChaptersJson in chaptersJsonList) {
        final novelId = novelWithChaptersJson['id'] as String;
        final novel = novelsMap[novelId];
        
        if (novel == null) continue;
        
        final chaptersJson = novelWithChaptersJson['chapters'] as List<dynamic>?;
        if (chaptersJson == null) continue;
        
        for (var chapterJson in chaptersJson) {
          final chapter = Chapter(
            id: chapterJson['id'],
            novelId: chapterJson['novelId'],
            title: chapterJson['title'],
            chapterNumber: chapterJson['chapterNumber'],
            content: chapterJson['content'],
            publishedAt: DateTime.parse(chapterJson['publishedAt']),
            wordCount: chapterJson['wordCount'],
            isDownloaded: chapterJson['isDownloaded'] ?? false,
            isRead: chapterJson['isRead'] ?? false,
          );
          
          // Determine status based on chapter properties
          UpdateStatus status;
          if (chapter.isDownloaded) {
            status = UpdateStatus.downloaded;
          } else if (chapter.isRead) {
            status = UpdateStatus.read;
          } else {
            // Check if this is a new chapter (published recently)
            final daysSincePublished = DateTime.now().difference(chapter.publishedAt).inDays;
            status = daysSincePublished <= 7 ? UpdateStatus.newChapter : UpdateStatus.unread;
          }
          
          updates.add(UpdateItem(
            id: chapter.id,
            novel: novel,
            chapter: chapter,
            status: status,
            publishedAt: chapter.publishedAt,
          ));
        }
      }
      
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

final networkStatusProvider = StreamProvider<bool>((ref) => NetworkService.onStatusChange);

final updatesProvider = StateNotifierProvider<UpdatesNotifier, AsyncValue<List<UpdateItem>>>((ref) {
  final isOnline = ref.watch(networkStatusProvider).maybeWhen(data: (v) => v, orElse: () => true);
  return UpdatesNotifier(isOnline);
});
