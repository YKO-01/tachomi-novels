import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:dio/dio.dart';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../../shared/constants/app_constants.dart';

/// NovelScraperService - Handles web scraping for novels from various websites
class NovelScraperService {
  final Dio _dio = Dio();
  
  NovelScraperService() {
    _dio.options.headers = {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8',
      'Accept-Language': 'en-US,en;q=0.5',
    };
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  /// Scrape novels from a URL (supports multiple sources)
  Future<List<Novel>> scrapeNovels(String url, {String? sourceType}) async {
    try {
      debugPrint('NovelScraperService: Scraping novels from $url');
      
      // Auto-detect source type if not specified
      final source = sourceType ?? _detectSourceType(url);
      
      switch (source) {
        case 'royalroad':
          return await _scrapeRoyalRoad(url);
        case 'webnovel':
          return await _scrapeWebNovel(url);
        case 'novelfull':
          return await _scrapeNovelFull(url);
        case 'wattpad':
          return await _scrapeWattpad(url);
        default:
          return await _scrapeGeneric(url);
      }
    } catch (e) {
      debugPrint('NovelScraperService: Error scraping novels - $e');
      rethrow;
    }
  }

  /// Get chapters for a specific novel
  Future<List<Chapter>> scrapeChapters(String novelUrl, String novelId, {String? sourceType}) async {
    try {
      debugPrint('NovelScraperService: Scraping chapters from $novelUrl');
      
      final source = sourceType ?? _detectSourceType(novelUrl);
      
      switch (source) {
        case 'royalroad':
          return await _scrapeRoyalRoadChapters(novelUrl, novelId);
        case 'webnovel':
          return await _scrapeWebNovelChapters(novelUrl, novelId);
        case 'novelfull':
          return await _scrapeNovelFullChapters(novelUrl, novelId);
        default:
          return await _scrapeGenericChapters(novelUrl, novelId);
      }
    } catch (e) {
      debugPrint('NovelScraperService: Error scraping chapters - $e');
      rethrow;
    }
  }

  /// Get chapter content
  Future<Chapter?> scrapeChapterContent(String chapterUrl, String chapterId, String novelId, {String? sourceType}) async {
    try {
      debugPrint('NovelScraperService: Scraping chapter content from $chapterUrl');
      
      final source = sourceType ?? _detectSourceType(chapterUrl);
      
      switch (source) {
        case 'royalroad':
          return await _scrapeRoyalRoadChapterContent(chapterUrl, chapterId, novelId);
        case 'webnovel':
          return await _scrapeWebNovelChapterContent(chapterUrl, chapterId, novelId);
        case 'novelfull':
          return await _scrapeNovelFullChapterContent(chapterUrl, chapterId, novelId);
        default:
          return await _scrapeGenericChapterContent(chapterUrl, chapterId, novelId);
      }
    } catch (e) {
      debugPrint('NovelScraperService: Error scraping chapter content - $e');
      rethrow;
    }
  }

  /// Detect source type from URL
  String _detectSourceType(String url) {
    final lowerUrl = url.toLowerCase();
    if (lowerUrl.contains('royalroad.com')) return 'royalroad';
    if (lowerUrl.contains('webnovel.com')) return 'webnovel';
    if (lowerUrl.contains('novelfull.com')) return 'novelfull';
    if (lowerUrl.contains('wattpad.com')) return 'wattpad';
    return 'generic';
  }

  // ========== Royal Road Scraper ==========
  Future<List<Novel>> _scrapeRoyalRoad(String url) async {
    try {
      final response = await _dio.get(url);
      final document = html_parser.parse(response.data);
      
      final novels = <Novel>[];
      final novelElements = document.querySelectorAll('.fiction-list-item, .table-responsive tr');
      
      for (var i = 0; i < novelElements.length; i++) {
        final element = novelElements[i];
        try {
          final titleElement = element.querySelector('h2 a, .fiction-title a, td a');
          if (titleElement == null) continue;
          
          final title = titleElement.text.trim();
          final novelUrl = titleElement.attributes['href'];
          if (novelUrl == null) continue;
          
          final novelId = novelUrl.split('/').last;
          // Note: novelUrl will be used for chapter scraping
          
          final authorElement = element.querySelector('.author, .text-primary');
          final author = authorElement?.text.trim() ?? 'Unknown';
          
          final descriptionElement = element.querySelector('.fiction-description, .synopsis');
          final description = descriptionElement?.text.trim() ?? 'No description available.';
          
          final coverElement = element.querySelector('img');
          final coverUrl = coverElement?.attributes['src'] ?? 'https://via.placeholder.com/300x400';
          
          final ratingElement = element.querySelector('.rating, .star-rating');
          final rating = double.tryParse(ratingElement?.text.trim() ?? '0') ?? 0.0;
          
          final statusElement = element.querySelector('.status-label, .label');
          final status = statusElement?.text.trim() ?? AppConstants.statusOngoing;
          
          final tags = element.querySelectorAll('.tags a, .tag').map((e) => e.text.trim()).toList();
          
          final chaptersElement = element.querySelector('.chapters, .chapter-count');
          final totalChapters = int.tryParse(chaptersElement?.text.trim().split(' ').first ?? '0') ?? 0;
          
          novels.add(Novel(
            id: novelId,
            title: title,
            author: author,
            description: description,
            coverUrl: coverUrl.startsWith('http') ? coverUrl : 'https://www.royalroad.com$coverUrl',
            tags: tags.isEmpty ? ['Fantasy'] : tags,
            status: _normalizeStatus(status),
            totalChapters: totalChapters,
            lastUpdated: DateTime.now(),
            rating: rating,
            views: 0,
          ));
        } catch (e) {
          debugPrint('NovelScraperService: Error parsing novel element - $e');
          continue;
        }
      }
      
      return novels;
    } catch (e) {
      debugPrint('NovelScraperService: Error scraping Royal Road - $e');
      rethrow;
    }
  }

  Future<List<Chapter>> _scrapeRoyalRoadChapters(String novelUrl, String novelId) async {
    try {
      final response = await _dio.get('$novelUrl/table-of-contents');
      final document = html_parser.parse(response.data);
      
      final chapters = <Chapter>[];
      final chapterElements = document.querySelectorAll('table tbody tr, .chapter-row');
      
      for (var i = 0; i < chapterElements.length; i++) {
        final element = chapterElements[i];
        try {
          final linkElement = element.querySelector('a');
          if (linkElement == null) continue;
          
          final title = linkElement.text.trim();
          final chapterUrl = linkElement.attributes['href'];
          if (chapterUrl == null) continue;
          
          final fullUrl = chapterUrl.startsWith('http') ? chapterUrl : 'https://www.royalroad.com$chapterUrl';
          final chapterId = '$novelId-${i + 1}';
          
          // Store fullUrl in summary field for later use when loading content
          chapters.add(Chapter(
            id: chapterId,
            novelId: novelId,
            title: title,
            chapterNumber: i + 1,
            content: '', // Will be loaded when chapter is opened
            publishedAt: DateTime.now().subtract(Duration(days: i)),
            wordCount: null,
            summary: fullUrl, // Store URL for scraping
          ));
        } catch (e) {
          debugPrint('NovelScraperService: Error parsing chapter - $e');
          continue;
        }
      }
      
      return chapters;
    } catch (e) {
      debugPrint('NovelScraperService: Error scraping Royal Road chapters - $e');
      rethrow;
    }
  }

  Future<Chapter?> _scrapeRoyalRoadChapterContent(String chapterUrl, String chapterId, String novelId) async {
    try {
      final response = await _dio.get(chapterUrl);
      final document = html_parser.parse(response.data);
      
      final contentElement = document.querySelector('.chapter-content, .chapter-inner');
      if (contentElement == null) return null;
      
      // Remove unwanted elements
      contentElement.querySelectorAll('script, style, .ad, .advertisement').forEach((e) => e.remove());
      
      final content = contentElement.innerHtml
          .replaceAll(RegExp(r'<br\s*/?>'), '\n')
          .replaceAll(RegExp(r'<[^>]+>'), '')
          .trim();
      
      final titleElement = document.querySelector('h1, .chapter-title');
      final title = titleElement?.text.trim() ?? 'Chapter';
      
      final chapterNumber = int.tryParse(chapterId.split('-').last) ?? 1;
      
      return Chapter(
        id: chapterId,
        novelId: novelId,
        title: title,
        chapterNumber: chapterNumber,
        content: content,
        publishedAt: DateTime.now(),
        wordCount: content.split(' ').length,
      );
    } catch (e) {
      debugPrint('NovelScraperService: Error scraping Royal Road chapter content - $e');
      return null;
    }
  }

  // ========== WebNovel Scraper ==========
  Future<List<Novel>> _scrapeWebNovel(String url) async {
    try {
      final response = await _dio.get(url);
      final document = html_parser.parse(response.data);
      
      final novels = <Novel>[];
      final novelElements = document.querySelectorAll('.book-item, .novel-item');
      
      for (var i = 0; i < novelElements.length; i++) {
        final element = novelElements[i];
        try {
          final titleElement = element.querySelector('.book-title a, .novel-title a');
          if (titleElement == null) continue;
          
          final title = titleElement.text.trim();
          final novelUrl = titleElement.attributes['href'];
          if (novelUrl == null) continue;
          
          final novelId = novelUrl.split('/').last.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
          // Note: novelUrl will be used for chapter scraping
          
          final authorElement = element.querySelector('.author-name, .book-author');
          final author = authorElement?.text.trim() ?? 'Unknown';
          
          final descriptionElement = element.querySelector('.book-intro, .novel-description');
          final description = descriptionElement?.text.trim() ?? 'No description available.';
          
          final coverElement = element.querySelector('img');
          final coverUrl = coverElement?.attributes['src'] ?? coverElement?.attributes['data-src'] ?? 'https://via.placeholder.com/300x400';
          
          novels.add(Novel(
            id: novelId,
            title: title,
            author: author,
            description: description,
            coverUrl: coverUrl.startsWith('http') ? coverUrl : 'https://www.webnovel.com$coverUrl',
            tags: ['WebNovel'],
            status: AppConstants.statusOngoing,
            totalChapters: 0,
            lastUpdated: DateTime.now(),
            rating: 4.0,
            views: 0,
          ));
        } catch (e) {
          debugPrint('NovelScraperService: Error parsing WebNovel element - $e');
          continue;
        }
      }
      
      return novels;
    } catch (e) {
      debugPrint('NovelScraperService: Error scraping WebNovel - $e');
      rethrow;
    }
  }

  Future<List<Chapter>> _scrapeWebNovelChapters(String novelUrl, String novelId) async {
    // Implementation similar to Royal Road
    return [];
  }

  Future<Chapter?> _scrapeWebNovelChapterContent(String chapterUrl, String chapterId, String novelId) async {
    // Implementation similar to Royal Road
    return null;
  }

  // ========== NovelFull Scraper ==========
  Future<List<Novel>> _scrapeNovelFull(String url) async {
    try {
      final response = await _dio.get(url);
      final document = html_parser.parse(response.data);
      
      final novels = <Novel>[];
      final novelElements = document.querySelectorAll('.list-stories .item, .book-item');
      
      for (var i = 0; i < novelElements.length; i++) {
        final element = novelElements[i];
        try {
          final titleElement = element.querySelector('h3 a, .book-title a');
          if (titleElement == null) continue;
          
          final title = titleElement.text.trim();
          final novelUrl = titleElement.attributes['href'];
          if (novelUrl == null) continue;
          
          final novelId = novelUrl.split('/').last.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
          // Note: novelUrl will be used for chapter scraping
          
          final authorElement = element.querySelector('.author, .book-author');
          final author = authorElement?.text.trim() ?? 'Unknown';
          
          final coverElement = element.querySelector('img');
          final coverUrl = coverElement?.attributes['src'] ?? 'https://via.placeholder.com/300x400';
          
          novels.add(Novel(
            id: novelId,
            title: title,
            author: author,
            description: 'No description available.',
            coverUrl: coverUrl.startsWith('http') ? coverUrl : 'https://novelfull.com$coverUrl',
            tags: ['NovelFull'],
            status: AppConstants.statusOngoing,
            totalChapters: 0,
            lastUpdated: DateTime.now(),
            rating: 4.0,
            views: 0,
          ));
        } catch (e) {
          debugPrint('NovelScraperService: Error parsing NovelFull element - $e');
          continue;
        }
      }
      
      return novels;
    } catch (e) {
      debugPrint('NovelScraperService: Error scraping NovelFull - $e');
      rethrow;
    }
  }

  Future<List<Chapter>> _scrapeNovelFullChapters(String novelUrl, String novelId) async {
    return [];
  }

  Future<Chapter?> _scrapeNovelFullChapterContent(String chapterUrl, String chapterId, String novelId) async {
    return null;
  }

  // ========== Wattpad Scraper ==========
  Future<List<Novel>> _scrapeWattpad(String url) async {
    // Wattpad uses heavy JavaScript, may need different approach
    return [];
  }

  // ========== Generic Scraper ==========
  Future<List<Novel>> _scrapeGeneric(String url) async {
    try {
      final response = await _dio.get(url);
      final document = html_parser.parse(response.data);
      
      final novels = <Novel>[];
      // Try to find common patterns
      final titleElements = document.querySelectorAll('a[href*="novel"], a[href*="story"], .title a, h2 a, h3 a');
      
      for (var i = 0; i < titleElements.length && novels.length < 20; i++) {
        final element = titleElements[i];
        try {
          final title = element.text.trim();
          if (title.isEmpty || title.length < 3) continue;
          
          final novelUrl = element.attributes['href'];
          if (novelUrl == null) continue;
          
          final fullUrl = novelUrl.startsWith('http') ? novelUrl : Uri.parse(url).resolve(novelUrl).toString();
          final novelId = fullUrl.split('/').last.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '') + i.toString();
          
          novels.add(Novel(
            id: novelId,
            title: title,
            author: 'Unknown',
            description: 'No description available.',
            coverUrl: 'https://via.placeholder.com/300x400',
            tags: ['Generic'],
            status: AppConstants.statusOngoing,
            totalChapters: 0,
            lastUpdated: DateTime.now(),
            rating: 4.0,
            views: 0,
          ));
        } catch (e) {
          continue;
        }
      }
      
      return novels;
    } catch (e) {
      debugPrint('NovelScraperService: Error scraping generic - $e');
      rethrow;
    }
  }

  Future<List<Chapter>> _scrapeGenericChapters(String novelUrl, String novelId) async {
    return [];
  }

  Future<Chapter?> _scrapeGenericChapterContent(String chapterUrl, String chapterId, String novelId) async {
    try {
      final response = await _dio.get(chapterUrl);
      final document = html_parser.parse(response.data);
      
      // Try common content selectors
      final contentElement = document.querySelector('article, .content, .chapter-content, .story-content, .text, #content, .main-content');
      
      if (contentElement == null) return null;
      
      // Remove unwanted elements
      contentElement.querySelectorAll('script, style, .ad, .advertisement, nav, .nav').forEach((e) => e.remove());
      
      final content = contentElement.innerHtml
          .replaceAll(RegExp(r'<br\s*/?>'), '\n')
          .replaceAll(RegExp(r'<[^>]+>'), ' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim();
      
      final titleElement = document.querySelector('h1, .title, .chapter-title');
      final title = titleElement?.text.trim() ?? 'Chapter';
      
      return Chapter(
        id: chapterId,
        novelId: novelId,
        title: title,
        chapterNumber: 1,
        content: content,
        publishedAt: DateTime.now(),
        wordCount: content.split(' ').length,
      );
    } catch (e) {
      debugPrint('NovelScraperService: Error scraping generic chapter - $e');
      return null;
    }
  }

  String _normalizeStatus(String status) {
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('complete') || lowerStatus.contains('finished')) {
      return AppConstants.statusCompleted;
    } else if (lowerStatus.contains('hiatus') || lowerStatus.contains('on hold')) {
      return AppConstants.statusHiatus;
    }
    return AppConstants.statusOngoing;
  }
}

final novelScraperServiceProvider = Provider<NovelScraperService>((ref) {
  return NovelScraperService();
});

