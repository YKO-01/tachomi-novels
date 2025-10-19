import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/novel.dart';
import '../../../core/services/novel_service.dart';

final libraryProvider = FutureProvider<List<Novel>>((ref) async {
  final novelService = ref.watch(novelServiceProvider);
  return await novelService.getNovels();
});

final libraryNotifierProvider = StateNotifierProvider<LibraryNotifier, AsyncValue<List<Novel>>>((ref) {
  final novelService = ref.watch(novelServiceProvider);
  return LibraryNotifier(novelService);
});

class LibraryNotifier extends StateNotifier<AsyncValue<List<Novel>>> {
  final NovelService _novelService;

  LibraryNotifier(this._novelService) : super(const AsyncValue.loading());

  Future<void> loadNovels() async {
    state = const AsyncValue.loading();
    
    try {
      final novels = await _novelService.getNovels();
      state = AsyncValue.data(novels);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void filterNovels(String filter) {
    // In a real app, you would filter the novels based on the filter
    // For now, we'll just update the state
  }

  void sortNovels(String sortBy) {
    // In a real app, you would sort the novels based on the sort criteria
    // For now, we'll just update the state
  }

  void searchNovels(String query) {
    // In a real app, you would search through the novels
    // For now, we'll just update the state
  }

  void toggleFavorite(String novelId) {
    state.whenData((novels) {
      final updatedNovels = novels.map((novel) {
        if (novel.id == novelId) {
          return novel.copyWith(isFavorite: !novel.isFavorite);
        }
        return novel;
      }).toList();
      state = AsyncValue.data(updatedNovels);
    });
  }

  void toggleDownload(String novelId) {
    state.whenData((novels) {
      final updatedNovels = novels.map((novel) {
        if (novel.id == novelId) {
          return novel.copyWith(isDownloaded: !novel.isDownloaded);
        }
        return novel;
      }).toList();
      state = AsyncValue.data(updatedNovels);
    });
  }
}
