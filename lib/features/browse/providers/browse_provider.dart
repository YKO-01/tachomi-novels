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
    print('BrowseNotifier: Starting to load novels...');
    state = const AsyncValue.loading();
    
    try {
      print('BrowseNotifier: Calling novelService.getNovels()...');
      final novels = await _novelService.getNovels();
      print('BrowseNotifier: Received ${novels.length} novels from service');
      _allNovels = novels;
      _applyCurrentFilter();
      print('BrowseNotifier: Applied filter, final state has ${_allNovels.length} novels');
    } catch (e, stackTrace) {
      print('BrowseNotifier: Error loading novels - $e');
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void filterNovels(String filter) {
    _currentFilter = filter;
    _applyCurrentFilter();
  }

  void _applyCurrentFilter() {
    print('BrowseNotifier: _applyCurrentFilter called with filter: $_currentFilter');
    if (_allNovels.isEmpty) {
      print('BrowseNotifier: _allNovels is empty, returning');
      return;
    }
    
    List<Novel> filteredNovels = _allNovels;
    
    switch (_currentFilter) {
      case AppConstants.filterDramatic:
        filteredNovels = _allNovels.where((novel) => 
          novel.tags.any((tag) => tag.toLowerCase() == 'dramatic')).toList();
        break;
      case AppConstants.filterRevenge:
        filteredNovels = _allNovels.where((novel) => 
          novel.tags.any((tag) => tag.toLowerCase() == 'revenge')).toList();
        break;
      case AppConstants.filterLove:
        filteredNovels = _allNovels.where((novel) => 
          novel.tags.any((tag) {
            final lowerTag = tag.toLowerCase();
            return lowerTag == 'love' || 
                   lowerTag == 'true love' || 
                   lowerTag == 'in love' || 
                   lowerTag == 'sad love';
          })).toList();
        break;
      case AppConstants.filterRomantic:
        filteredNovels = _allNovels.where((novel) => 
          novel.tags.any((tag) => tag.toLowerCase() == 'romantic')).toList();
        break;
      case AppConstants.filterMystery:
        filteredNovels = _allNovels.where((novel) => 
          novel.tags.any((tag) => tag.toLowerCase() == 'mystery')).toList();
        break;
      case AppConstants.filterDrama:
        filteredNovels = _allNovels.where((novel) => 
          novel.tags.any((tag) => tag.toLowerCase() == 'drama')).toList();
        break;
      case AppConstants.filterAll:
      default:
        filteredNovels = _allNovels;
        break;
    }
    
    print('BrowseNotifier: Filtered novels count: ${filteredNovels.length}');
    state = AsyncValue.data(filteredNovels);
    print('BrowseNotifier: State updated with ${filteredNovels.length} novels');
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
