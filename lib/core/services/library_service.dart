import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LibraryService {
  static const String _libraryKey = 'library_novel_ids';
  static Set<String> _libraryNovelIds = <String>{};
  static bool _isInitialized = false;

  static Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      final prefs = await SharedPreferences.getInstance();
      final libraryIds = prefs.getStringList(_libraryKey) ?? <String>[];
      _libraryNovelIds = libraryIds.toSet();
      _isInitialized = true;
    }
  }

  static Future<bool> isInLibrary(String novelId) async {
    await _ensureInitialized();
    return _libraryNovelIds.contains(novelId);
  }

  static Future<void> addToLibrary(String novelId) async {
    await _ensureInitialized();
    _libraryNovelIds.add(novelId);
    await _saveToPreferences();
  }

  static Future<void> removeFromLibrary(String novelId) async {
    await _ensureInitialized();
    _libraryNovelIds.remove(novelId);
    await _saveToPreferences();
  }

  static Future<void> toggleLibrary(String novelId) async {
    if (await isInLibrary(novelId)) {
      await removeFromLibrary(novelId);
    } else {
      await addToLibrary(novelId);
    }
  }

  static Future<List<String>> getLibraryNovelIds() async {
    await _ensureInitialized();
    return _libraryNovelIds.toList();
  }

  static Future<void> clearLibrary() async {
    await _ensureInitialized();
    _libraryNovelIds.clear();
    await _saveToPreferences();
  }

  static Future<void> _saveToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_libraryKey, _libraryNovelIds.toList());
  }
}

// Provider for library service
final libraryServiceProvider = Provider<LibraryService>((ref) {
  return LibraryService();
});

// Provider to check if a novel is in library
final isNovelInLibraryProvider = FutureProvider.family<bool, String>((ref, novelId) async {
  return await LibraryService.isInLibrary(novelId);
});

// Provider to get all library novel IDs
final libraryNovelIdsProvider = FutureProvider<List<String>>((ref) async {
  return await LibraryService.getLibraryNovelIds();
});

// Notifier for library changes
class LibraryNotifier extends StateNotifier<AsyncValue<List<String>>> {
  LibraryNotifier() : super(const AsyncValue.loading()) {
    _loadLibrary();
  }

  Future<void> _loadLibrary() async {
    try {
      final novelIds = await LibraryService.getLibraryNovelIds();
      state = AsyncValue.data(novelIds);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> addToLibrary(String novelId) async {
    await LibraryService.addToLibrary(novelId);
    await _loadLibrary();
  }

  Future<void> removeFromLibrary(String novelId) async {
    await LibraryService.removeFromLibrary(novelId);
    await _loadLibrary();
  }

  Future<void> toggleLibrary(String novelId) async {
    await LibraryService.toggleLibrary(novelId);
    await _loadLibrary();
  }
}

final libraryServiceNotifierProvider = StateNotifierProvider<LibraryNotifier, AsyncValue<List<String>>>((ref) {
  return LibraryNotifier();
});


