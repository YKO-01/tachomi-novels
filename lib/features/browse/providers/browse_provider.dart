import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/novel.dart';
import '../../../core/services/novel_service.dart';
import '../../../core/services/library_service.dart';
import '../../../core/services/favorites_service.dart';
import '../../../shared/constants/app_constants.dart';

final browseProvider = FutureProvider<List<Novel>>((ref) async {
  final novelService = ref.watch(novelServiceProvider);
  return await novelService.getNovels();
});

final browseNotifierProvider = StateNotifierProvider<BrowseNotifier, AsyncValue<List<Novel>>>((ref) {
  final novelService = ref.watch(novelServiceProvider);
  return BrowseNotifier(novelService);
});

class BrowseNotifier extends StateNotifier<AsyncValue<List<Novel>>> {
  final NovelService _novelService;
  List<Novel> _allNovels = [];
  String _currentFilter = AppConstants.filterAll;

  BrowseNotifier(this._novelService) : super(const AsyncValue.loading());

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
    
    List<Novel> filteredNovels = _allNovels;
    
    switch (_currentFilter) {
      case AppConstants.filterRomance:
        filteredNovels = _allNovels.where((novel) => 
          novel.tags.contains('Romance') || novel.tags.contains('romance')).toList();
        break;
      case AppConstants.filterBL:
        filteredNovels = _allNovels.where((novel) => 
          novel.tags.contains('BL') || novel.tags.contains('bl') || 
          novel.tags.contains('Boys Love') || novel.tags.contains('boys love')).toList();
        break;
      case AppConstants.filterSliceOfLife:
        filteredNovels = _allNovels.where((novel) => 
          novel.tags.contains('Slice of Life') || novel.tags.contains('slice of life') ||
          novel.tags.contains('SliceOfLife')).toList();
        break;
      case AppConstants.filterAll:
      default:
        filteredNovels = _allNovels;
        break;
    }
    
    state = AsyncValue.data(filteredNovels);
  }

  void sortNovels(String sortBy) {
    state.whenData((novels) {
      List<Novel> sortedNovels = List.from(novels);
      
      switch (sortBy) {
        case AppConstants.sortPopular:
          sortedNovels.sort((a, b) => b.views.compareTo(a.views));
          break;
        case AppConstants.sortLatest:
          sortedNovels.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
          break;
        case AppConstants.sortRating:
          sortedNovels.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case AppConstants.sortViews:
          sortedNovels.sort((a, b) => b.views.compareTo(a.views));
          break;
      }
      
      state = AsyncValue.data(sortedNovels);
    });
  }

  void searchNovels(String query) {
    if (query.isEmpty) {
      _applyCurrentFilter();
      return;
    }
    
    state.whenData((novels) {
      final filteredNovels = novels.where((novel) =>
        novel.title.toLowerCase().contains(query.toLowerCase()) ||
        novel.author.toLowerCase().contains(query.toLowerCase()) ||
        novel.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
      ).toList();
      
      state = AsyncValue.data(filteredNovels);
    });
  }

  Future<void> toggleFavorite(String novelId) async {
    // Use the favorites service to toggle
    await FavoritesService.toggleFavorite(novelId);
    
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

  Future<void> addToLibrary(Novel novel) async {
    // Use the shared library service
    await LibraryService.addToLibrary(novel.id);
    // Refresh the browse state to update UI
    _applyCurrentFilter();
  }

  Future<void> removeFromLibrary(Novel novel) async {
    // Use the shared library service
    await LibraryService.removeFromLibrary(novel.id);
    // Refresh the browse state to update UI
    _applyCurrentFilter();
  }
}
