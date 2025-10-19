import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/novel.dart';
import '../../../core/services/novel_service.dart';

final novelDetailsProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, novelId) async {
  final novelService = ref.watch(novelServiceProvider);
  final novel = await novelService.getNovelById(novelId);
  final chapters = await novelService.getChaptersByNovelId(novelId);
  
  if (novel == null) {
    throw Exception('Novel not found');
  }
  
  return {
    'novel': novel,
    'chapters': chapters,
  };
});

final novelDetailsNotifierProvider = StateNotifierProvider.family<NovelDetailsNotifier, AsyncValue<Map<String, dynamic>>, String>((ref, novelId) {
  final novelService = ref.watch(novelServiceProvider);
  return NovelDetailsNotifier(novelService, novelId);
});

class NovelDetailsNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  final NovelService _novelService;
  final String _novelId;

  NovelDetailsNotifier(this._novelService, this._novelId) : super(const AsyncValue.loading()) {
    loadNovelDetails();
  }

  Future<void> loadNovelDetails() async {
    state = const AsyncValue.loading();
    
    try {
      final novel = await _novelService.getNovelById(_novelId);
      final chapters = await _novelService.getChaptersByNovelId(_novelId);
      
      if (novel == null) {
        state = const AsyncValue.error('Novel not found', StackTrace.empty);
        return;
      }
      
      state = AsyncValue.data({
        'novel': novel,
        'chapters': chapters,
      });
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void toggleFavorite() {
    state.whenData((data) {
      final novel = data['novel'] as Novel;
      final updatedNovel = novel.copyWith(
        isFavorite: !novel.isFavorite,
      );
      state = AsyncValue.data({
        'novel': updatedNovel,
        'chapters': data['chapters'],
      });
    });
  }

  void toggleDownload() {
    state.whenData((data) {
      final novel = data['novel'] as Novel;
      final updatedNovel = novel.copyWith(
        isDownloaded: !novel.isDownloaded,
      );
      state = AsyncValue.data({
        'novel': updatedNovel,
        'chapters': data['chapters'],
      });
    });
  }

  void toggleLibrary() {
    state.whenData((data) {
      final novel = data['novel'] as Novel;
      final updatedNovel = novel.copyWith(
        isInLibrary: !novel.isInLibrary,
      );
      state = AsyncValue.data({
        'novel': updatedNovel,
        'chapters': data['chapters'],
      });
    });
  }
}
