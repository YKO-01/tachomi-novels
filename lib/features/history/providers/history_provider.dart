import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/novel.dart';
import '../../../core/models/chapter.dart';
import '../../../core/models/novel_history.dart';
import '../../../core/services/history_service.dart';

/// HistoryNotifier - Manages reading history state
/// Provides reactive state management for the history feature
class HistoryNotifier extends StateNotifier<AsyncValue<List<NovelHistory>>> {
  static const String _kDebugTag = 'HistoryNotifier';
  
  HistoryNotifier() : super(const AsyncValue.loading()) {
    _loadHistories();
  }

  // MARK: - Data Loading
  Future<void> _loadHistories() async {
    debugPrint('$_kDebugTag: Loading histories...');
    state = const AsyncValue.loading();
    
    try {
      final histories = await HistoryService.getAllHistories();
      debugPrint('$_kDebugTag: Loaded ${histories.length} histories from service');
      state = AsyncValue.data(histories);
      debugPrint('$_kDebugTag: Set state with ${histories.length} histories');
    } catch (error, stackTrace) {
      debugPrint('$_kDebugTag: Error loading histories - $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  // MARK: - Public Methods
  Future<void> addNovelToHistory(Novel novel, Chapter chapter) async {
    debugPrint('$_kDebugTag: Adding novel to history - ${novel.title}');
    try {
      await HistoryService.addNovelToHistory(novel, chapter);
      debugPrint('$_kDebugTag: Successfully added to service, reloading histories...');
      await _loadHistories();
      debugPrint('$_kDebugTag: Histories reloaded');
    } catch (error) {
      debugPrint('$_kDebugTag: Error adding novel to history - $error');
      rethrow;
    }
  }

  Future<void> removeNovelFromHistory(String novelId) async {
    try {
      await HistoryService.removeNovelFromHistory(novelId);
      await _loadHistories();
    } catch (error) {
      debugPrint('$_kDebugTag: Error removing novel from history - $error');
      rethrow;
    }
  }

  Future<void> clearAllHistory() async {
    try {
      await HistoryService.clearAllHistory();
      await _loadHistories();
    } catch (error) {
      debugPrint('$_kDebugTag: Error clearing all histories - $error');
      rethrow;
    }
  }

  Future<void> refreshHistories() async {
    debugPrint('$_kDebugTag: Manual refresh requested');
    await _loadHistories();
  }

  // MARK: - Sorting Methods
  void sortByRecent() {
    state.whenData((histories) {
      final sortedHistories = List<NovelHistory>.from(histories);
      sortedHistories.sort((a, b) => b.lastRead.compareTo(a.lastRead));
      state = AsyncValue.data(sortedHistories);
    });
  }

  void sortByTitle() {
    state.whenData((histories) {
      final sortedHistories = List<NovelHistory>.from(histories);
      sortedHistories.sort((a, b) => a.novelTitle.compareTo(b.novelTitle));
      state = AsyncValue.data(sortedHistories);
    });
  }

  void sortByAuthor() {
    state.whenData((histories) {
      final sortedHistories = List<NovelHistory>.from(histories);
      sortedHistories.sort((a, b) => a.author.compareTo(b.author));
      state = AsyncValue.data(sortedHistories);
    });
  }
}

// MARK: - Provider Registration
final historyProvider = StateNotifierProvider<HistoryNotifier, AsyncValue<List<NovelHistory>>>((ref) {
  return HistoryNotifier();
});

// MARK: - Additional Providers
final novelHistoryProvider = FutureProvider.family<NovelHistory?, String>((ref, novelId) async {
  return await HistoryService.getNovelHistory(novelId);
});

final historyCountProvider = Provider<int>((ref) {
  final historyState = ref.watch(historyProvider);
  return historyState.when(
    data: (histories) => histories.length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
