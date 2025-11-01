import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// LibraryCategory - Represents a custom category for organizing novels
class LibraryCategory {
  final String id;
  final String name;
  final String color;
  final List<String> novelIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  LibraryCategory({
    required this.id,
    required this.name,
    required this.color,
    this.novelIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  LibraryCategory copyWith({
    String? id,
    String? name,
    String? color,
    List<String>? novelIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LibraryCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      novelIds: novelIds ?? this.novelIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'novelIds': novelIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory LibraryCategory.fromJson(Map<String, dynamic> json) {
    return LibraryCategory(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      novelIds: List<String>.from(json['novelIds'] ?? []),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

/// ReadingStatistics - Tracks reading statistics
class ReadingStatistics {
  final int totalNovelsRead;
  final int totalChaptersRead;
  final int totalReadingTimeMinutes;
  final int totalWordsRead;
  final Map<String, int> genreStats;
  final Map<String, int> monthlyStats;
  final DateTime lastUpdated;

  ReadingStatistics({
    this.totalNovelsRead = 0,
    this.totalChaptersRead = 0,
    this.totalReadingTimeMinutes = 0,
    this.totalWordsRead = 0,
    this.genreStats = const {},
    this.monthlyStats = const {},
    required this.lastUpdated,
  });

  ReadingStatistics copyWith({
    int? totalNovelsRead,
    int? totalChaptersRead,
    int? totalReadingTimeMinutes,
    int? totalWordsRead,
    Map<String, int>? genreStats,
    Map<String, int>? monthlyStats,
    DateTime? lastUpdated,
  }) {
    return ReadingStatistics(
      totalNovelsRead: totalNovelsRead ?? this.totalNovelsRead,
      totalChaptersRead: totalChaptersRead ?? this.totalChaptersRead,
      totalReadingTimeMinutes: totalReadingTimeMinutes ?? this.totalReadingTimeMinutes,
      totalWordsRead: totalWordsRead ?? this.totalWordsRead,
      genreStats: genreStats ?? this.genreStats,
      monthlyStats: monthlyStats ?? this.monthlyStats,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  String get formattedReadingTime {
    final hours = totalReadingTimeMinutes ~/ 60;
    final minutes = totalReadingTimeMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get formattedWordsRead {
    if (totalWordsRead >= 1000000) {
      return '${(totalWordsRead / 1000000).toStringAsFixed(1)}M words';
    } else if (totalWordsRead >= 1000) {
      return '${(totalWordsRead / 1000).toStringAsFixed(1)}K words';
    }
    return '$totalWordsRead words';
  }

  Map<String, dynamic> toJson() {
    return {
      'totalNovelsRead': totalNovelsRead,
      'totalChaptersRead': totalChaptersRead,
      'totalReadingTimeMinutes': totalReadingTimeMinutes,
      'totalWordsRead': totalWordsRead,
      'genreStats': genreStats,
      'monthlyStats': monthlyStats,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  factory ReadingStatistics.fromJson(Map<String, dynamic> json) {
    return ReadingStatistics(
      totalNovelsRead: json['totalNovelsRead'] ?? 0,
      totalChaptersRead: json['totalChaptersRead'] ?? 0,
      totalReadingTimeMinutes: json['totalReadingTimeMinutes'] ?? 0,
      totalWordsRead: json['totalWordsRead'] ?? 0,
      genreStats: Map<String, int>.from(json['genreStats'] ?? {}),
      monthlyStats: Map<String, int>.from(json['monthlyStats'] ?? {}),
      lastUpdated: DateTime.parse(json['lastUpdated']),
    );
  }
}

/// LibraryManagementService - Manages library organization, categories, and statistics
class LibraryManagementService {
  static const String _kCategoriesKey = 'library_categories';
  static const String _kStatisticsKey = 'reading_statistics';
  static const String _kLibraryKey = 'user_library';
  
  static List<LibraryCategory> _cachedCategories = [];
  static ReadingStatistics? _cachedStatistics;
  static List<String> _cachedLibrary = [];
  static bool _isInitialized = false;

  // MARK: - Initialization
  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      debugPrint('LibraryManagementService: Initializing...');
      try {
        final prefs = await SharedPreferences.getInstance();
        
        // Load categories
        final categoriesJson = prefs.getString(_kCategoriesKey);
        if (categoriesJson != null) {
          final List<dynamic> categoriesList = json.decode(categoriesJson);
          _cachedCategories = categoriesList.map((json) => LibraryCategory.fromJson(json)).toList();
        }
        
        // Load statistics
        final statisticsJson = prefs.getString(_kStatisticsKey);
        if (statisticsJson != null) {
          final statisticsData = json.decode(statisticsJson);
          _cachedStatistics = ReadingStatistics.fromJson(statisticsData);
        } else {
          _cachedStatistics = ReadingStatistics(lastUpdated: DateTime.now());
        }
        
        // Load library
        final libraryJson = prefs.getString(_kLibraryKey);
        if (libraryJson != null) {
          final List<dynamic> libraryList = json.decode(libraryJson);
          _cachedLibrary = List<String>.from(libraryList);
        }
        
        debugPrint('LibraryManagementService: Loaded ${_cachedCategories.length} categories, ${_cachedLibrary.length} novels');
        _isInitialized = true;
      } catch (error) {
        debugPrint('LibraryManagementService: Error during initialization - $error');
        _cachedCategories = [];
        _cachedStatistics = ReadingStatistics(lastUpdated: DateTime.now());
        _cachedLibrary = [];
        _isInitialized = true;
      }
    }
  }

  // MARK: - Library Management
  static Future<List<String>> getLibrary() async {
    await _ensureInitialized();
    return List.from(_cachedLibrary);
  }

  static Future<void> addToLibrary(String novelId) async {
    await _ensureInitialized();
    
    if (!_cachedLibrary.contains(novelId)) {
      _cachedLibrary.add(novelId);
      await _persistLibrary();
      debugPrint('LibraryManagementService: Added novel $novelId to library');
    }
  }

  static Future<void> removeFromLibrary(String novelId) async {
    await _ensureInitialized();
    
    if (_cachedLibrary.contains(novelId)) {
      _cachedLibrary.remove(novelId);
      await _persistLibrary();
      debugPrint('LibraryManagementService: Removed novel $novelId from library');
    }
  }

  static Future<bool> isInLibrary(String novelId) async {
    await _ensureInitialized();
    return _cachedLibrary.contains(novelId);
  }

  // MARK: - Category Management
  static Future<List<LibraryCategory>> getCategories() async {
    await _ensureInitialized();
    return List.from(_cachedCategories);
  }

  static Future<void> createCategory(String name, String color) async {
    await _ensureInitialized();
    
    final category = LibraryCategory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      color: color,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _cachedCategories.add(category);
    await _persistCategories();
    debugPrint('LibraryManagementService: Created category $name');
  }

  static Future<void> updateCategory(String id, String name, String color) async {
    await _ensureInitialized();
    
    final index = _cachedCategories.indexWhere((cat) => cat.id == id);
    if (index >= 0) {
      _cachedCategories[index] = _cachedCategories[index].copyWith(
        name: name,
        color: color,
        updatedAt: DateTime.now(),
      );
      await _persistCategories();
      debugPrint('LibraryManagementService: Updated category $name');
    }
  }

  static Future<void> deleteCategory(String id) async {
    await _ensureInitialized();
    
    _cachedCategories.removeWhere((cat) => cat.id == id);
    await _persistCategories();
    debugPrint('LibraryManagementService: Deleted category $id');
  }

  static Future<void> addNovelToCategory(String categoryId, String novelId) async {
    await _ensureInitialized();
    
    final index = _cachedCategories.indexWhere((cat) => cat.id == categoryId);
    if (index >= 0) {
      final category = _cachedCategories[index];
      if (!category.novelIds.contains(novelId)) {
        final updatedNovelIds = [...category.novelIds, novelId];
        _cachedCategories[index] = category.copyWith(
          novelIds: updatedNovelIds,
          updatedAt: DateTime.now(),
        );
        await _persistCategories();
        debugPrint('LibraryManagementService: Added novel $novelId to category $categoryId');
      }
    }
  }

  static Future<void> removeNovelFromCategory(String categoryId, String novelId) async {
    await _ensureInitialized();
    
    final index = _cachedCategories.indexWhere((cat) => cat.id == categoryId);
    if (index >= 0) {
      final category = _cachedCategories[index];
      final updatedNovelIds = category.novelIds.where((id) => id != novelId).toList();
      _cachedCategories[index] = category.copyWith(
        novelIds: updatedNovelIds,
        updatedAt: DateTime.now(),
      );
      await _persistCategories();
      debugPrint('LibraryManagementService: Removed novel $novelId from category $categoryId');
    }
  }

  // MARK: - Statistics Management
  static Future<ReadingStatistics> getStatistics() async {
    await _ensureInitialized();
    return _cachedStatistics!;
  }

  static Future<void> updateReadingStatistics({
    int? novelsRead,
    int? chaptersRead,
    int? readingTimeMinutes,
    int? wordsRead,
    String? genre,
  }) async {
    await _ensureInitialized();
    
    final currentStats = _cachedStatistics!;
    var newGenreStats = Map<String, int>.from(currentStats.genreStats);
    
    if (genre != null) {
      newGenreStats[genre] = (newGenreStats[genre] ?? 0) + 1;
    }
    
    final newStats = currentStats.copyWith(
      totalNovelsRead: currentStats.totalNovelsRead + (novelsRead ?? 0),
      totalChaptersRead: currentStats.totalChaptersRead + (chaptersRead ?? 0),
      totalReadingTimeMinutes: currentStats.totalReadingTimeMinutes + (readingTimeMinutes ?? 0),
      totalWordsRead: currentStats.totalWordsRead + (wordsRead ?? 0),
      genreStats: newGenreStats,
      lastUpdated: DateTime.now(),
    );
    
    _cachedStatistics = newStats;
    await _persistStatistics();
    debugPrint('LibraryManagementService: Updated reading statistics');
  }

  static Future<void> resetStatistics() async {
    await _ensureInitialized();
    
    _cachedStatistics = ReadingStatistics(lastUpdated: DateTime.now());
    await _persistStatistics();
    debugPrint('LibraryManagementService: Reset reading statistics');
  }

  static Future<void> clearAllLibraryData() async {
    await _ensureInitialized();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear library
      _cachedLibrary.clear();
      await prefs.remove(_kLibraryKey);
      
      // Clear categories
      _cachedCategories.clear();
      await prefs.remove(_kCategoriesKey);
      
      // Reset statistics
      _cachedStatistics = ReadingStatistics(lastUpdated: DateTime.now());
      await _persistStatistics();
      
      debugPrint('LibraryManagementService: Cleared all library data (library, categories, statistics)');
    } catch (error) {
      debugPrint('LibraryManagementService: Error clearing all library data - $error');
      rethrow;
    }
  }

  // MARK: - Private Methods
  static Future<void> _persistLibrary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final libraryJson = json.encode(_cachedLibrary);
      await prefs.setString(_kLibraryKey, libraryJson);
    } catch (error) {
      debugPrint('LibraryManagementService: Error persisting library - $error');
    }
  }

  static Future<void> _persistCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final categoriesJson = json.encode(
        _cachedCategories.map((cat) => cat.toJson()).toList()
      );
      await prefs.setString(_kCategoriesKey, categoriesJson);
    } catch (error) {
      debugPrint('LibraryManagementService: Error persisting categories - $error');
    }
  }

  static Future<void> _persistStatistics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statisticsJson = json.encode(_cachedStatistics!.toJson());
      await prefs.setString(_kStatisticsKey, statisticsJson);
    } catch (error) {
      debugPrint('LibraryManagementService: Error persisting statistics - $error');
    }
  }
}
