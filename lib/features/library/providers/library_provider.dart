import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/novel.dart';
import '../../../core/services/novel_service.dart';
import '../../../core/services/library_service.dart';
import '../../../shared/constants/app_constants.dart';

final libraryProvider = FutureProvider<List<Novel>>((ref) async {
  final novelService = ref.watch(novelServiceProvider);
  final libraryNovelIds = LibraryService.getLibraryNovelIds();
  
  final allNovels = await novelService.getNovels();
  // Filter to only show novels that are in the library
  return allNovels.where((novel) => libraryNovelIds.contains(novel.id)).toList();
});

final libraryNotifierProvider = StateNotifierProvider<LibraryNotifier, AsyncValue<List<Novel>>>((ref) {
  final novelService = ref.watch(novelServiceProvider);
  return LibraryNotifier(novelService);
});

class LibraryNotifier extends StateNotifier<AsyncValue<List<Novel>>> {
  final NovelService _novelService;
  List<Novel> _allNovels = [];
  String _currentFilter = AppConstants.filterAll;

  LibraryNotifier(this._novelService) : super(const AsyncValue.loading());

  Future<void> loadNovels() async {
    state = const AsyncValue.loading();
    
    try {
      final novels = await _novelService.getNovels();
      _allNovels = novels;
      _applyCurrentFilter();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void filterNovels(String filter) {
    _currentFilter = filter;
    _applyCurrentFilter();
  }

  void _applyCurrentFilter() {
    if (_allNovels.isEmpty) return;
    
    // Get library novel IDs from the shared service
    final libraryNovelIds = LibraryService.getLibraryNovelIds();
    
    // First filter to only show novels that are in the library
    List<Novel> libraryNovels = _allNovels.where((novel) => libraryNovelIds.contains(novel.id)).toList();
    
    // Then apply the status filter
    List<Novel> filteredNovels = libraryNovels;
    
    switch (_currentFilter) {
      case AppConstants.filterCompleted:
        filteredNovels = libraryNovels.where((novel) => novel.status == AppConstants.statusCompleted).toList();
        break;
      case AppConstants.filterOngoing:
        filteredNovels = libraryNovels.where((novel) => novel.status == AppConstants.statusOngoing).toList();
        break;
      case AppConstants.filterAll:
      default:
        filteredNovels = libraryNovels;
        break;
    }
    
    state = AsyncValue.data(filteredNovels);
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

  void addToLibrary(String novelId) {
    LibraryService.addToLibrary(novelId);
    _applyCurrentFilter(); // Refresh the library view
  }

  void removeFromLibrary(String novelId) {
    LibraryService.removeFromLibrary(novelId);
    _applyCurrentFilter(); // Refresh the library view
  }
}