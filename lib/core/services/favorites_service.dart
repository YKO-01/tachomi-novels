import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/novel.dart';
import 'novel_service.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_novel_ids';
  static Set<String> _favoriteNovelIds = <String>{};
  static bool _isInitialized = false;

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      final prefs = await SharedPreferences.getInstance();
      final favoriteIds = prefs.getStringList(_favoritesKey) ?? <String>[];
      _favoriteNovelIds = favoriteIds.toSet();
      _isInitialized = true;
    }
  }

  static Future<bool> isFavorite(String novelId) async {
    await _ensureInitialized();
    return _favoriteNovelIds.contains(novelId);
  }

  static Future<void> addToFavorites(String novelId) async {
    await _ensureInitialized();
    _favoriteNovelIds.add(novelId);
    await _saveToPreferences();
  }

  static Future<void> removeFromFavorites(String novelId) async {
    await _ensureInitialized();
    _favoriteNovelIds.remove(novelId);
    await _saveToPreferences();
  }

  static Future<void> toggleFavorite(String novelId) async {
    if (await isFavorite(novelId)) {
      await removeFromFavorites(novelId);
    } else {
      await addToFavorites(novelId);
    }
  }

  static Future<List<String>> getFavoriteNovelIds() async {
    await _ensureInitialized();
    return _favoriteNovelIds.toList();
  }

  static Future<void> clearFavorites() async {
    await _ensureInitialized();
    _favoriteNovelIds.clear();
    await _saveToPreferences();
  }

  static Future<List<Novel>> getFavoriteNovels(NovelService novelService) async {
    final favoriteIds = await getFavoriteNovelIds();
    if (favoriteIds.isEmpty) return [];
    
    final allNovels = await novelService.getNovels();
    return allNovels.where((novel) => favoriteIds.contains(novel.id)).toList();
  }

  static Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, _favoriteNovelIds.toList());
  }
}

// Provider for favorites service
final favoritesServiceProvider = Provider<FavoritesService>((ref) {
  return FavoritesService();
});

// Provider to check if a novel is favorite
final isNovelFavoriteProvider = FutureProvider.family<bool, String>((ref, novelId) async {
  return await FavoritesService.isFavorite(novelId);
});

// Provider to get all favorite novel IDs
final favoriteNovelIdsProvider = FutureProvider<List<String>>((ref) async {
  return await FavoritesService.getFavoriteNovelIds();
});

// Provider to get favorite novels
final favoriteNovelsProvider = FutureProvider<List<Novel>>((ref) async {
  final novelService = ref.watch(novelServiceProvider);
  return await FavoritesService.getFavoriteNovels(novelService);
});

// Notifier for favorites changes
class FavoritesNotifier extends StateNotifier<AsyncValue<List<String>>> {
  FavoritesNotifier() : super(const AsyncValue.loading()) {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final favoriteIds = await FavoritesService.getFavoriteNovelIds();
      state = AsyncValue.data(favoriteIds);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addToFavorites(String novelId) async {
    await FavoritesService.addToFavorites(novelId);
    await _loadFavorites();
  }

  Future<void> removeFromFavorites(String novelId) async {
    await FavoritesService.removeFromFavorites(novelId);
    await _loadFavorites();
  }

  Future<void> toggleFavorite(String novelId) async {
    await FavoritesService.toggleFavorite(novelId);
    await _loadFavorites();
  }
}

final favoritesServiceNotifierProvider = StateNotifierProvider<FavoritesNotifier, AsyncValue<List<String>>>((ref) {
  return FavoritesNotifier();
});
