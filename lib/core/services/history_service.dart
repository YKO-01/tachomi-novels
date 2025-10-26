import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/novel.dart';
import '../models/chapter.dart';

class HistoryItem {
  final String id;
  final String novelId;
  final String chapterId;
  final String novelTitle;
  final String chapterTitle;
  final DateTime lastRead;
  final double progress; // 0.0 to 1.0
  final bool isCompleted;

  const HistoryItem({
    required this.id,
    required this.novelId,
    required this.chapterId,
    required this.novelTitle,
    required this.chapterTitle,
    required this.lastRead,
    required this.progress,
    this.isCompleted = false,
  });

  HistoryItem copyWith({
    String? id,
    String? novelId,
    String? chapterId,
    String? novelTitle,
    String? chapterTitle,
    DateTime? lastRead,
    double? progress,
    bool? isCompleted,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      chapterId: chapterId ?? this.chapterId,
      novelTitle: novelTitle ?? this.novelTitle,
      chapterTitle: chapterTitle ?? this.chapterTitle,
      lastRead: lastRead ?? this.lastRead,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'novelId': novelId,
      'chapterId': chapterId,
      'novelTitle': novelTitle,
      'chapterTitle': chapterTitle,
      'lastRead': lastRead.toIso8601String(),
      'progress': progress,
      'isCompleted': isCompleted,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      novelId: json['novelId'],
      chapterId: json['chapterId'],
      novelTitle: json['novelTitle'],
      chapterTitle: json['chapterTitle'],
      lastRead: DateTime.parse(json['lastRead']),
      progress: json['progress'].toDouble(),
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class HistoryService {
  static const String _historyKey = 'reading_history';
  static List<HistoryItem> _historyItems = [];
  static bool _isInitialized = false;

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      print('HistoryService: Initializing...');
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_historyKey);
      if (historyJson != null) {
        final List<dynamic> historyList = json.decode(historyJson);
        _historyItems = historyList.map((json) => HistoryItem.fromJson(json)).toList();
        print('HistoryService: Loaded ${_historyItems.length} items from SharedPreferences');
      } else {
        print('HistoryService: No existing history data found');
      }
      _isInitialized = true;
    }
  }

  static Future<List<HistoryItem>> getHistoryItems() async {
    await _ensureInitialized();
    print('HistoryService: Retrieved ${_historyItems.length} history items');
    return List.from(_historyItems);
  }

  static Future<void> addToHistory(Novel novel, Chapter chapter, double progress) async {
    await _ensureInitialized();
    
    print('HistoryService: Adding to history - Novel: ${novel.title}, Chapter: ${chapter.title}, Progress: $progress');
    
    final existingIndex = _historyItems.indexWhere(
      (item) => item.novelId == novel.id && item.chapterId == chapter.id
    );
    
    final newItem = HistoryItem(
      id: '${novel.id}_${chapter.id}',
      novelId: novel.id,
      chapterId: chapter.id,
      novelTitle: novel.title,
      chapterTitle: chapter.title,
      lastRead: DateTime.now(),
      progress: progress,
      isCompleted: progress >= 1.0,
    );
    
    if (existingIndex >= 0) {
      _historyItems[existingIndex] = newItem;
      print('HistoryService: Updated existing history item');
    } else {
      _historyItems.insert(0, newItem);
      print('HistoryService: Added new history item');
    }
    
    // Sort by last read date (most recent first)
    _historyItems.sort((a, b) => b.lastRead.compareTo(a.lastRead));
    await _saveToPreferences();
    print('HistoryService: Total history items after save: ${_historyItems.length}');
  }

  static Future<void> updateProgress(String novelId, String chapterId, double progress) async {
    await _ensureInitialized();
    final index = _historyItems.indexWhere(
      (item) => item.novelId == novelId && item.chapterId == chapterId
    );
    
    if (index >= 0) {
      _historyItems[index] = _historyItems[index].copyWith(
        progress: progress,
        isCompleted: progress >= 1.0,
        lastRead: DateTime.now(),
      );
      await _saveToPreferences();
    }
  }

  static Future<void> removeFromHistory(String historyId) async {
    await _ensureInitialized();
    _historyItems.removeWhere((item) => item.id == historyId);
    await _saveToPreferences();
  }

  static Future<void> removeNovelFromHistory(String novelId) async {
    await _ensureInitialized();
    _historyItems.removeWhere((item) => item.novelId == novelId);
    await _saveToPreferences();
  }

  static Future<void> clearAllHistory() async {
    await _ensureInitialized();
    _historyItems.clear();
    await _saveToPreferences();
  }

  static Future<List<HistoryItem>> getNovelHistory(String novelId) async {
    await _ensureInitialized();
    return _historyItems.where((item) => item.novelId == novelId).toList();
  }

  static Future<HistoryItem?> getLastReadChapter(String novelId) async {
    final novelHistory = await getNovelHistory(novelId);
    if (novelHistory.isEmpty) return null;
    
    // Return the most recently read chapter for this novel
    return novelHistory.first;
  }

  static Future<List<HistoryItem>> getRecentHistory({int limit = 10}) async {
    await _ensureInitialized();
    return _historyItems.take(limit).toList();
  }

  static Future<void> markChapterAsRead(String novelId, String chapterId) async {
    await updateProgress(novelId, chapterId, 1.0);
  }

  static Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = json.encode(_historyItems.map((item) => item.toJson()).toList());
    await prefs.setString(_historyKey, historyJson);
    print('HistoryService: Saved ${_historyItems.length} items to SharedPreferences');
  }
}

// Provider for history service
final historyServiceProvider = Provider<HistoryService>((ref) {
  return HistoryService();
});

// Provider to get all history items
final historyItemsProvider = FutureProvider<List<HistoryItem>>((ref) async {
  return await HistoryService.getHistoryItems();
});

// Provider to get recent history
final recentHistoryProvider = FutureProvider.family<List<HistoryItem>, int>((ref, limit) async {
  return await HistoryService.getRecentHistory(limit: limit);
});

// Provider to get novel history
final novelHistoryProvider = FutureProvider.family<List<HistoryItem>, String>((ref, novelId) async {
  return await HistoryService.getNovelHistory(novelId);
});

// Provider to get last read chapter for a novel
final lastReadChapterProvider = FutureProvider.family<HistoryItem?, String>((ref, novelId) async {
  return await HistoryService.getLastReadChapter(novelId);
});

// Notifier for history changes
class HistoryNotifier extends StateNotifier<AsyncValue<List<HistoryItem>>> {
  HistoryNotifier() : super(const AsyncValue.loading()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final historyItems = await HistoryService.getHistoryItems();
      state = AsyncValue.data(historyItems);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addToHistory(Novel novel, Chapter chapter, double progress) async {
    await HistoryService.addToHistory(novel, chapter, progress);
    await _loadHistory();
  }

  Future<void> updateProgress(String novelId, String chapterId, double progress) async {
    await HistoryService.updateProgress(novelId, chapterId, progress);
    await _loadHistory();
  }

  Future<void> markChapterAsRead(String novelId, String chapterId) async {
    await HistoryService.markChapterAsRead(novelId, chapterId);
    await _loadHistory();
  }

  Future<void> removeFromHistory(String historyId) async {
    await HistoryService.removeFromHistory(historyId);
    await _loadHistory();
  }

  Future<void> removeNovelFromHistory(String novelId) async {
    await HistoryService.removeNovelFromHistory(novelId);
    await _loadHistory();
  }

  Future<void> clearAllHistory() async {
    await HistoryService.clearAllHistory();
    await _loadHistory();
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
      sortedItems.sort((a, b) => a.novelTitle.compareTo(b.novelTitle));
      state = AsyncValue.data(sortedItems);
    });
  }
}

final historyServiceNotifierProvider = StateNotifierProvider<HistoryNotifier, AsyncValue<List<HistoryItem>>>((ref) {
  return HistoryNotifier();
});
