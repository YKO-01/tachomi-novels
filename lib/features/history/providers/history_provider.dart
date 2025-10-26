import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/novel.dart';
import '../../../core/models/chapter.dart';
import '../../../core/services/history_service.dart';

class HistoryNotifier extends StateNotifier<AsyncValue<List<HistoryItem>>> {
  HistoryNotifier() : super(const AsyncValue.loading()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    print('HistoryProvider: Starting to load history...');
    state = const AsyncValue.loading();
    
    try {
      // Load history from the history service
      await Future.delayed(const Duration(milliseconds: 500));
      final historyItems = await HistoryService.getHistoryItems();
      print('HistoryProvider: Loaded ${historyItems.length} history items');
      state = AsyncValue.data(historyItems);
    } catch (e, stackTrace) {
      print('HistoryProvider: Error loading history - $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addToHistory(Novel novel, Chapter chapter, double progress) async {
    await HistoryService.addToHistory(novel, chapter, progress);
    await _loadHistory();
  }

  Future<void> removeFromHistory(String id) async {
    await HistoryService.removeFromHistory(id);
    await _loadHistory();
  }

  Future<void> markAsUnread(String id) async {
    // Find the item and reset its progress
    final items = await HistoryService.getHistoryItems();
    final item = items.firstWhere((item) => item.id == id);
    await HistoryService.updateProgress(item.novelId, item.chapterId, 0.0);
    await _loadHistory();
  }

  Future<void> clearAll() async {
    await HistoryService.clearAllHistory();
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
      sortedItems.sort((a, b) => a.novelTitle.compareTo(b.novelTitle));
      state = AsyncValue.data(sortedItems);
    });
  }
}

final historyProvider = StateNotifierProvider<HistoryNotifier, AsyncValue<List<HistoryItem>>>((ref) {
  return HistoryNotifier();
});
