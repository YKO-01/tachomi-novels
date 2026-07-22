import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/manga.dart';
import '../../../core/models/manga_chapter.dart';
import '../../../core/services/manga_service.dart';
import '../../../core/services/library_service.dart';
import '../../../core/services/favorites_service.dart';
import '../../../shared/constants/app_constants.dart';

// Browse state for the manga grid (filter / search / sort)
final mangaBrowseNotifierProvider = StateNotifierProvider<MangaBrowseNotifier, AsyncValue<List<Manga>>>((ref) {
  final mangaService = ref.watch(mangaServiceProvider);
  return MangaBrowseNotifier(mangaService);
});

class MangaBrowseNotifier extends StateNotifier<AsyncValue<List<Manga>>> {
  final MangaService _mangaService;
  List<Manga> _allMangas = [];
  String _currentFilter = AppConstants.filterAll;

  MangaBrowseNotifier(this._mangaService) : super(const AsyncValue.loading());

  Future<void> loadMangas() async {
    state = const AsyncValue.loading();
    try {
      final mangas = await _mangaService.getMangas();
      _allMangas = mangas;
      _applyCurrentFilter();
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  void filterMangas(String filter) {
    _currentFilter = filter;
    _applyCurrentFilter();
  }

  void _applyCurrentFilter() {
    if (_allMangas.isEmpty) return;

    List<Manga> filteredMangas;
    if (_currentFilter == AppConstants.filterAll) {
      filteredMangas = _allMangas;
    } else {
      filteredMangas = _allMangas.where((manga) =>
        manga.genres.any((genre) => genre.toLowerCase() == _currentFilter.toLowerCase())).toList();
    }

    state = AsyncValue.data(filteredMangas);
  }

  void sortMangas(String sortBy) {
    state.whenData((mangas) {
      final sortedMangas = List<Manga>.from(mangas);

      switch (sortBy) {
        case AppConstants.sortPopular:
        case AppConstants.sortRating:
        case AppConstants.sortViews:
          sortedMangas.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case AppConstants.sortLatest:
          sortedMangas.sort((a, b) => a.title.compareTo(b.title));
          break;
      }

      state = AsyncValue.data(sortedMangas);
    });
  }

  void searchMangas(String query) {
    if (query.isEmpty) {
      _applyCurrentFilter();
      return;
    }

    final lowerQuery = query.toLowerCase();
    final filteredMangas = _allMangas.where((manga) =>
      manga.title.toLowerCase().contains(lowerQuery) ||
      manga.genres.any((genre) => genre.toLowerCase().contains(lowerQuery))
    ).toList();

    state = AsyncValue.data(filteredMangas);
  }
}

// Manga details + chapters
final mangaDetailsProvider = FutureProvider.family<Manga?, String>((ref, mangaId) async {
  final mangaService = ref.watch(mangaServiceProvider);
  return await mangaService.getMangaById(mangaId);
});

final mangaChaptersProvider = FutureProvider.family<List<MangaChapter>, String>((ref, mangaId) async {
  final mangaService = ref.watch(mangaServiceProvider);
  return await mangaService.getChaptersByMangaId(mangaId);
});

// Mangas saved in the library (shares the same id storage as novels)
final mangaLibraryProvider = FutureProvider<List<Manga>>((ref) async {
  final mangaService = ref.watch(mangaServiceProvider);
  final libraryIds = await LibraryService.getLibraryNovelIds();
  if (libraryIds.isEmpty) return [];

  final allMangas = await mangaService.getMangas();
  return allMangas.where((manga) => libraryIds.contains(manga.id)).toList();
});

// Favorite mangas (shares the same id storage as novels)
final mangaFavoritesProvider = FutureProvider<List<Manga>>((ref) async {
  final mangaService = ref.watch(mangaServiceProvider);
  final favoriteIds = await FavoritesService.getFavoriteNovelIds();
  if (favoriteIds.isEmpty) return [];

  final allMangas = await mangaService.getMangas();
  return allMangas.where((manga) => favoriteIds.contains(manga.id)).toList();
});
