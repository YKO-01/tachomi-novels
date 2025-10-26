import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/novel.dart';
import '../models/chapter.dart';
import '../models/novel_history.dart';

/// HistoryService - Manages reading history data
/// Uses SharedPreferences for persistence with proper error handling
class HistoryService {
  static const String _kHistoryKey = 'reading_history';
  static List<NovelHistory> _cachedHistories = [];
  static bool _isInitialized = false;

  // MARK: - Initialization
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      debugPrint('HistoryService: Initializing...');
      try {
        final prefs = await SharedPreferences.getInstance();
        final historyJson = prefs.getString(_kHistoryKey);
        
        if (historyJson != null) {
          final List<dynamic> historyList = json.decode(historyJson);
          _cachedHistories = historyList.map((json) => _fromJson(json)).toList();
          debugPrint('HistoryService: Loaded ${_cachedHistories.length} histories from cache');
        } else {
          debugPrint('HistoryService: No cached data found');
        }
        _isInitialized = true;
      } catch (error) {
        debugPrint('HistoryService: Error during initialization - $error');
        _cachedHistories = [];
        _isInitialized = true;
      }
    }
  }

  // MARK: - Public API
  static Future<List<NovelHistory>> getAllHistories() async {
    await _ensureInitialized();
    debugPrint('HistoryService: Retrieved ${_cachedHistories.length} histories');
    return List.from(_cachedHistories);
  }

  static Future<void> addNovelToHistory(Novel novel, Chapter chapter) async {
    await _ensureInitialized();
    
    debugPrint('HistoryService: Adding novel to history - ${novel.title} (ID: ${novel.id})');
    debugPrint('HistoryService: Chapter - ${chapter.title} (ID: ${chapter.id})');
    
    try {
      final existingIndex = _cachedHistories.indexWhere(
        (history) => history.novelId == novel.id
      );
      
      NovelHistory updatedHistory;
      if (existingIndex >= 0) {
        // Update existing history
        updatedHistory = _cachedHistories[existingIndex].updateLastChapter(chapter);
        _cachedHistories[existingIndex] = updatedHistory;
        debugPrint('HistoryService: Updated existing history for ${novel.title}');
      } else {
        // Create new history
        updatedHistory = NovelHistory.fromNovelAndChapter(novel, chapter);
        _cachedHistories.insert(0, updatedHistory);
        debugPrint('HistoryService: Created new history for ${novel.title}');
      }
      
      // Sort by last read date (most recent first)
      _cachedHistories.sort((a, b) => b.lastRead.compareTo(a.lastRead));
      await _persistData();
      
      debugPrint('HistoryService: Total histories after add: ${_cachedHistories.length}');
      
    } catch (error) {
      debugPrint('HistoryService: Error adding novel to history - $error');
      rethrow;
    }
  }

  static Future<void> removeNovelFromHistory(String novelId) async {
    await _ensureInitialized();
    
    try {
      final initialCount = _cachedHistories.length;
      _cachedHistories.removeWhere((history) => history.novelId == novelId);
      
      if (_cachedHistories.length < initialCount) {
        await _persistData();
        debugPrint('HistoryService: Removed novel $novelId from history');
      }
    } catch (error) {
      debugPrint('HistoryService: Error removing novel from history - $error');
      rethrow;
    }
  }

  static Future<void> clearAllHistory() async {
    await _ensureInitialized();
    
    try {
      _cachedHistories.clear();
      await _persistData();
      debugPrint('HistoryService: Cleared all histories');
    } catch (error) {
      debugPrint('HistoryService: Error clearing all histories - $error');
      rethrow;
    }
  }

  static Future<NovelHistory?> getNovelHistory(String novelId) async {
    await _ensureInitialized();
    
    try {
      return _cachedHistories.firstWhere(
        (history) => history.novelId == novelId,
        orElse: () => throw StateError('Novel history not found'),
      );
    } catch (e) {
      return null;
    }
  }

  // MARK: - Debug Methods
  static Future<void> debugPrintHistories() async {
    await _ensureInitialized();
    debugPrint('HistoryService: Debug - Current histories count: ${_cachedHistories.length}');
    for (int i = 0; i < _cachedHistories.length; i++) {
      final history = _cachedHistories[i];
      debugPrint('HistoryService: Debug - [$i] ${history.novelTitle} - ${history.lastChapterDisplay} - ${history.formattedLastRead}');
    }
  }

  static Future<int> getHistoryCount() async {
    await _ensureInitialized();
    return _cachedHistories.length;
  }

  // MARK: - Private Methods
  static Future<void> _persistData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = json.encode(
        _cachedHistories.map((history) => history.toJson()).toList()
      );
      await prefs.setString(_kHistoryKey, historyJson);
      debugPrint('HistoryService: Persisted ${_cachedHistories.length} histories');
    } catch (error) {
      debugPrint('HistoryService: Error persisting data - $error');
      rethrow;
    }
  }

  static NovelHistory _fromJson(Map<String, dynamic> json) {
    return NovelHistory(
      id: json['id'],
      novelId: json['novelId'],
      novelTitle: json['novelTitle'],
      author: json['author'],
      coverUrl: json['coverUrl'],
      lastRead: DateTime.parse(json['lastRead']),
      lastChapterId: json['lastChapterId'],
      lastChapterTitle: json['lastChapterTitle'],
      lastChapterNumber: json['lastChapterNumber'],
    );
  }
}

// MARK: - JSON Serialization Extension
extension NovelHistoryJson on NovelHistory {
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'novelId': novelId,
      'novelTitle': novelTitle,
      'author': author,
      'coverUrl': coverUrl,
      'lastRead': lastRead.toIso8601String(),
      'lastChapterId': lastChapterId,
      'lastChapterTitle': lastChapterTitle,
      'lastChapterNumber': lastChapterNumber,
    };
  }

  static NovelHistory fromJson(Map<String, dynamic> json) {
    return NovelHistory(
      id: json['id'],
      novelId: json['novelId'],
      novelTitle: json['novelTitle'],
      author: json['author'],
      coverUrl: json['coverUrl'],
      lastRead: DateTime.parse(json['lastRead']),
      lastChapterId: json['lastChapterId'],
      lastChapterTitle: json['lastChapterTitle'],
      lastChapterNumber: json['lastChapterNumber'],
    );
  }
}
