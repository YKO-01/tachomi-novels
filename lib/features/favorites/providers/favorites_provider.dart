import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/novel.dart';
import '../../../core/services/novel_service.dart';
import '../../../core/services/favorites_service.dart';
import '../../../shared/constants/app_constants.dart';

final favoritesProvider = FutureProvider<List<Novel>>((ref) async {
  final novelService = ref.watch(novelServiceProvider);
  return await FavoritesService.getFavoriteNovels(novelService);
});

final favoritesNotifierProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<List<Novel>>>((ref) {
  final novelService = ref.watch(novelServiceProvider);
  return FavoritesNotifier(novelService);
});

class FavoritesNotifier extends StateNotifier<AsyncValue<List<Novel>>> {
  final NovelService _novelService;
  List<Novel> _allFavorites = [];

  FavoritesNotifier(this._novelService) : super(const AsyncValue.loading());

  Future<void> loadFavorites() async {
    state = const AsyncValue.loading();
    
    try {
      final novels = await FavoritesService.getFavoriteNovels(_novelService);
      _allFavorites = novels;
      state = AsyncValue.data(novels);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void sortFavorites(String sortBy) {
    state.whenData((novels) {
      List<Novel> sortedNovels = List.from(novels);
      
      switch (sortBy) {
        case AppConstants.sortLatest:
          // Sort by when they were added to favorites (using lastUpdated as proxy)
          sortedNovels.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
          break;
        case 'title':
          sortedNovels.sort((a, b) => a.title.compareTo(b.title));
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

  void searchFavorites(String query) {
    if (query.isEmpty) {
      state = AsyncValue.data(_allFavorites);
      return;
    }
    
    final filteredNovels = _allFavorites.where((novel) =>
      novel.title.toLowerCase().contains(query.toLowerCase()) ||
      novel.author.toLowerCase().contains(query.toLowerCase()) ||
      novel.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase()))
    ).toList();
    
    state = AsyncValue.data(filteredNovels);
  }

  Future<void> addToFavorites(String novelId) async {
    await FavoritesService.addToFavorites(novelId);
    // Refresh the favorites list
    await loadFavorites();
  }

  Future<void> removeFromFavorites(String novelId) async {
    await FavoritesService.removeFromFavorites(novelId);
    // Refresh the favorites list
    await loadFavorites();
  }

  Future<void> toggleFavorite(String novelId) async {
    await FavoritesService.toggleFavorite(novelId);
    // Refresh the favorites list
    await loadFavorites();
  }
}
