import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../../shared/constants/app_constants.dart';
import 'novel_scraper_service.dart';

class NovelService {
  final NovelScraperService? _scraperService;
  
  NovelService({NovelScraperService? scraperService}) : _scraperService = scraperService;

  // Mock data for demonstration
  static final List<Novel> _mockNovels = [
    Novel(
      id: '1',
      title: 'The Crown\'s Shadow',
      author: 'Sarah Chen',
      description: 'A fantasy romance about a princess who discovers her true power lies not in her crown, but in the shadows she casts.',
      coverUrl: 'https://picsum.photos/300/400?random=1',
      tags: ['Fantasy', 'Romance', 'Magic'],
      status: AppConstants.statusOngoing,
      totalChapters: 45,
      lastUpdated: DateTime.now().subtract(const Duration(days: 2)),
      rating: 4.8,
      views: 125000,
    ),
    Novel(
      id: '2',
      title: 'Coffee Shop Chronicles',
      author: 'Alex Rivera',
      description: 'Slice of life stories from a cozy coffee shop where every customer has a story to tell.',
      coverUrl: 'https://picsum.photos/300/400?random=2',
      tags: ['Slice of Life', 'Comedy', 'Drama'],
      status: AppConstants.statusCompleted,
      totalChapters: 30,
      lastUpdated: DateTime.now().subtract(const Duration(days: 5)),
      rating: 4.6,
      views: 89000,
    ),
    Novel(
      id: '3',
      title: 'Midnight Express',
      author: 'Jordan Kim',
      description: 'A mysterious train that only appears at midnight, taking passengers to destinations unknown.',
      coverUrl: 'https://picsum.photos/300/400?random=3',
      tags: ['Mystery', 'Supernatural', 'Adventure'],
      status: AppConstants.statusOngoing,
      totalChapters: 22,
      lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      rating: 4.9,
      views: 156000,
    ),
    Novel(
      id: '4',
      title: 'Love in Translation',
      author: 'Maya Patel',
      description: 'A bilingual romance that explores the beauty of communication across languages and cultures.',
      coverUrl: 'https://picsum.photos/300/400?random=4',
      tags: ['Romance', 'BL', 'Cultural'],
      status: AppConstants.statusOngoing,
      totalChapters: 38,
      lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
      rating: 4.7,
      views: 98000,
    ),
    Novel(
      id: '5',
      title: 'The Last Bookstore',
      author: 'David Chen',
      description: 'In a world where physical books are rare, one bookstore holds the key to preserving human knowledge.',
      coverUrl: 'https://picsum.photos/300/400?random=5',
      tags: ['Dystopian', 'Drama', 'Philosophy'],
      status: AppConstants.statusCompleted,
      totalChapters: 52,
      lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
      rating: 4.5,
      views: 67000,
    ),
    Novel(
      id: '6',
      title: 'Starlight Academy',
      author: 'Luna Star',
      description: 'A magical academy where students learn to harness the power of starlight in this enchanting coming-of-age story.',
      coverUrl: 'https://picsum.photos/300/400?random=6',
      tags: ['Fantasy', 'School Life', 'Magic'],
      status: AppConstants.statusOngoing,
      totalChapters: 28,
      lastUpdated: DateTime.now().subtract(const Duration(days: 4)),
      rating: 4.8,
      views: 134000,
    ),
  ];

  static final List<Chapter> _mockChapters = [
    Chapter(
      id: '1-1',
      novelId: '1',
      title: 'The Crown\'s Weight',
      chapterNumber: 1,
      content: 'Princess Elara stood before the mirror, adjusting her heavy crown...',
      publishedAt: DateTime.now().subtract(const Duration(days: 30)),
      wordCount: 2500,
    ),
    Chapter(
      id: '1-2',
      novelId: '1',
      title: 'Shadows in the Palace',
      chapterNumber: 2,
      content: 'The palace corridors seemed darker than usual tonight...',
      publishedAt: DateTime.now().subtract(const Duration(days: 28)),
      wordCount: 2300,
    ),
    Chapter(
      id: '2-1',
      novelId: '2',
      title: 'Morning Brew',
      chapterNumber: 1,
      content: 'The coffee shop opened its doors at 6 AM sharp...',
      publishedAt: DateTime.now().subtract(const Duration(days: 45)),
      wordCount: 2100,
    ),
  ];

  Future<List<Novel>> getNovels() async {
    debugPrint('NovelService: getNovels() called');
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    debugPrint('NovelService: Returning ${_mockNovels.length} mock novels');
    return List.from(_mockNovels);
  }

  Future<Novel?> getNovelById(String id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _mockNovels.firstWhere((novel) => novel.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Chapter>> getChaptersByNovelId(String novelId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      // Load from JSON file
      final String jsonString = await rootBundle.loadString('assets/data/mock_chapters.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      
      final chapters = jsonList.map((json) => Chapter(
        id: json['id'],
        novelId: json['novelId'],
        title: json['title'],
        chapterNumber: json['chapterNumber'],
        content: json['content'],
        publishedAt: DateTime.parse(json['publishedAt']),
        isDownloaded: json['isDownloaded'] ?? false,
        isRead: json['isRead'] ?? false,
        wordCount: json['wordCount'],
      )).toList();
      
      return chapters.where((chapter) => chapter.novelId == novelId).toList();
    } catch (e) {
      // Fallback to mock data
      return _mockChapters.where((chapter) => chapter.novelId == novelId).toList();
    }
  }

  Future<List<Novel>> searchNovels(String query) async {
    await Future.delayed(const Duration(seconds: 1));
    return _mockNovels.where((novel) {
      return novel.title.toLowerCase().contains(query.toLowerCase()) ||
             novel.author.toLowerCase().contains(query.toLowerCase()) ||
             novel.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()));
    }).toList();
  }

  Future<List<Novel>> getNovelsByFilter(String filter) async {
    await Future.delayed(const Duration(milliseconds: 500));
    if (filter == AppConstants.filterAll) {
      return List.from(_mockNovels);
    }
    return _mockNovels.where((novel) => novel.tags.contains(filter)).toList();
  }

  Future<List<Novel>> getNovelsBySort(String sortBy) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final novels = List<Novel>.from(_mockNovels);
    
    switch (sortBy) {
      case AppConstants.sortPopular:
        novels.sort((a, b) => b.views.compareTo(a.views));
        break;
      case AppConstants.sortLatest:
        novels.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
        break;
      case AppConstants.sortRating:
        novels.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case AppConstants.sortViews:
        novels.sort((a, b) => b.views.compareTo(a.views));
        break;
    }
    
    return novels;
  }

  /// Scrape novels from a URL
  Future<List<Novel>> scrapeNovelsFromUrl(String url, {String? sourceType}) async {
    if (_scraperService == null) {
      debugPrint('NovelService: Scraper service not available');
      return [];
    }
    
    try {
      return await _scraperService.scrapeNovels(url, sourceType: sourceType);
    } catch (e) {
      debugPrint('NovelService: Error scraping novels - $e');
      rethrow;
    }
  }

  /// Scrape chapters for a novel
  Future<List<Chapter>> scrapeChaptersFromUrl(String novelUrl, String novelId, {String? sourceType}) async {
    if (_scraperService == null) {
      debugPrint('NovelService: Scraper service not available');
      return [];
    }
    
    try {
      return await _scraperService.scrapeChapters(novelUrl, novelId, sourceType: sourceType);
    } catch (e) {
      debugPrint('NovelService: Error scraping chapters - $e');
      rethrow;
    }
  }

  /// Scrape chapter content
  Future<Chapter?> scrapeChapterContentFromUrl(String chapterUrl, String chapterId, String novelId, {String? sourceType}) async {
    if (_scraperService == null) {
      debugPrint('NovelService: Scraper service not available');
      return null;
    }
    
    try {
      return await _scraperService.scrapeChapterContent(chapterUrl, chapterId, novelId, sourceType: sourceType);
    } catch (e) {
      debugPrint('NovelService: Error scraping chapter content - $e');
      return null;
    }
  }
}

final novelServiceProvider = Provider<NovelService>((ref) {
  final scraperService = ref.watch(novelScraperServiceProvider);
  return NovelService(scraperService: scraperService);
});
