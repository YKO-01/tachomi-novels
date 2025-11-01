import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/library_management_service.dart';

/// LibraryManagementNotifier - Manages library state and operations
class LibraryManagementNotifier extends StateNotifier<AsyncValue<List<String>>> {
  static const String _kDebugTag = 'LibraryManagementNotifier';
  
  LibraryManagementNotifier() : super(const AsyncValue.loading()) {
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    debugPrint('$_kDebugTag: Loading library...');
    state = const AsyncValue.loading();
    
    try {
      final library = await LibraryManagementService.getLibrary();
      state = AsyncValue.data(library);
      debugPrint('$_kDebugTag: Loaded ${library.length} novels in library');
    } catch (error, stackTrace) {
      debugPrint('$_kDebugTag: Error loading library - $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addToLibrary(String novelId) async {
    try {
      await LibraryManagementService.addToLibrary(novelId);
      await _loadLibrary();
    } catch (error) {
      debugPrint('$_kDebugTag: Error adding to library - $error');
      rethrow;
    }
  }

  Future<void> removeFromLibrary(String novelId) async {
    try {
      await LibraryManagementService.removeFromLibrary(novelId);
      await _loadLibrary();
    } catch (error) {
      debugPrint('$_kDebugTag: Error removing from library - $error');
      rethrow;
    }
  }

  Future<bool> isInLibrary(String novelId) async {
    return await LibraryManagementService.isInLibrary(novelId);
  }

  Future<void> refreshLibrary() async {
    await _loadLibrary();
  }
}

/// CategoryManagementNotifier - Manages category state and operations
class CategoryManagementNotifier extends StateNotifier<AsyncValue<List<LibraryCategory>>> {
  static const String _kDebugTag = 'CategoryManagementNotifier';
  
  CategoryManagementNotifier() : super(const AsyncValue.loading()) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    debugPrint('$_kDebugTag: Loading categories...');
    state = const AsyncValue.loading();
    
    try {
      final categories = await LibraryManagementService.getCategories();
      state = AsyncValue.data(categories);
      debugPrint('$_kDebugTag: Loaded ${categories.length} categories');
    } catch (error, stackTrace) {
      debugPrint('$_kDebugTag: Error loading categories - $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createCategory(String name, String color) async {
    try {
      await LibraryManagementService.createCategory(name, color);
      await _loadCategories();
    } catch (error) {
      debugPrint('$_kDebugTag: Error creating category - $error');
      rethrow;
    }
  }

  Future<void> updateCategory(String id, String name, String color) async {
    try {
      await LibraryManagementService.updateCategory(id, name, color);
      await _loadCategories();
    } catch (error) {
      debugPrint('$_kDebugTag: Error updating category - $error');
      rethrow;
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await LibraryManagementService.deleteCategory(id);
      await _loadCategories();
    } catch (error) {
      debugPrint('$_kDebugTag: Error deleting category - $error');
      rethrow;
    }
  }

  Future<void> addNovelToCategory(String categoryId, String novelId) async {
    try {
      await LibraryManagementService.addNovelToCategory(categoryId, novelId);
      await _loadCategories();
    } catch (error) {
      debugPrint('$_kDebugTag: Error adding novel to category - $error');
      rethrow;
    }
  }

  Future<void> removeNovelFromCategory(String categoryId, String novelId) async {
    try {
      await LibraryManagementService.removeNovelFromCategory(categoryId, novelId);
      await _loadCategories();
    } catch (error) {
      debugPrint('$_kDebugTag: Error removing novel from category - $error');
      rethrow;
    }
  }

  Future<void> refreshCategories() async {
    await _loadCategories();
  }
}

/// StatisticsNotifier - Manages reading statistics
class StatisticsNotifier extends StateNotifier<AsyncValue<ReadingStatistics>> {
  static const String _kDebugTag = 'StatisticsNotifier';
  
  StatisticsNotifier() : super(const AsyncValue.loading()) {
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    debugPrint('$_kDebugTag: Loading statistics...');
    state = const AsyncValue.loading();
    
    try {
      final statistics = await LibraryManagementService.getStatistics();
      state = AsyncValue.data(statistics);
      debugPrint('$_kDebugTag: Loaded reading statistics');
    } catch (error, stackTrace) {
      debugPrint('$_kDebugTag: Error loading statistics - $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateReadingStatistics({
    int? novelsRead,
    int? chaptersRead,
    int? readingTimeMinutes,
    int? wordsRead,
    String? genre,
  }) async {
    try {
      await LibraryManagementService.updateReadingStatistics(
        novelsRead: novelsRead,
        chaptersRead: chaptersRead,
        readingTimeMinutes: readingTimeMinutes,
        wordsRead: wordsRead,
        genre: genre,
      );
      await _loadStatistics();
    } catch (error) {
      debugPrint('$_kDebugTag: Error updating statistics - $error');
      rethrow;
    }
  }

  Future<void> resetStatistics() async {
    try {
      await LibraryManagementService.resetStatistics();
      await _loadStatistics();
    } catch (error) {
      debugPrint('$_kDebugTag: Error resetting statistics - $error');
      rethrow;
    }
  }

  Future<void> refreshStatistics() async {
    await _loadStatistics();
  }
}

// MARK: - Provider Registration
final libraryManagementProvider = StateNotifierProvider<LibraryManagementNotifier, AsyncValue<List<String>>>((ref) {
  return LibraryManagementNotifier();
});

final categoryManagementProvider = StateNotifierProvider<CategoryManagementNotifier, AsyncValue<List<LibraryCategory>>>((ref) {
  return CategoryManagementNotifier();
});

final statisticsProvider = StateNotifierProvider<StatisticsNotifier, AsyncValue<ReadingStatistics>>((ref) {
  return StatisticsNotifier();
});

// MARK: - Additional Providers
final isNovelInLibraryProvider = FutureProvider.family<bool, String>((ref, novelId) async {
  return await LibraryManagementService.isInLibrary(novelId);
});

final libraryCountProvider = Provider<int>((ref) {
  final libraryState = ref.watch(libraryManagementProvider);
  return libraryState.when(
    data: (library) => library.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});

final categoriesCountProvider = Provider<int>((ref) {
  final categoriesState = ref.watch(categoryManagementProvider);
  return categoriesState.when(
    data: (categories) => categories.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
