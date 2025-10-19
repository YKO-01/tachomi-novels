import 'package:flutter_riverpod/flutter_riverpod.dart';

class LibraryService {
  static final Set<String> _libraryNovelIds = <String>{};

  static bool isInLibrary(String novelId) {
    return _libraryNovelIds.contains(novelId);
  }

  static void addToLibrary(String novelId) {
    _libraryNovelIds.add(novelId);
  }

  static void removeFromLibrary(String novelId) {
    _libraryNovelIds.remove(novelId);
  }

  static void toggleLibrary(String novelId) {
    if (isInLibrary(novelId)) {
      removeFromLibrary(novelId);
    } else {
      addToLibrary(novelId);
    }
  }

  static List<String> getLibraryNovelIds() {
    return _libraryNovelIds.toList();
  }

  static void clearLibrary() {
    _libraryNovelIds.clear();
  }
}

// Provider for library service
final libraryServiceProvider = Provider<LibraryService>((ref) {
  return LibraryService();
});

// Provider to check if a novel is in library
final isNovelInLibraryProvider = Provider.family<bool, String>((ref, novelId) {
  return LibraryService.isInLibrary(novelId);
});

// Provider to get all library novel IDs
final libraryNovelIdsProvider = Provider<List<String>>((ref) {
  return LibraryService.getLibraryNovelIds();
});

// Notifier for library changes
class LibraryNotifier extends StateNotifier<List<String>> {
  LibraryNotifier() : super(LibraryService.getLibraryNovelIds());

  void addToLibrary(String novelId) {
    LibraryService.addToLibrary(novelId);
    state = LibraryService.getLibraryNovelIds();
  }

  void removeFromLibrary(String novelId) {
    LibraryService.removeFromLibrary(novelId);
    state = LibraryService.getLibraryNovelIds();
  }

  void toggleLibrary(String novelId) {
    LibraryService.toggleLibrary(novelId);
    state = LibraryService.getLibraryNovelIds();
  }
}

final libraryServiceNotifierProvider = StateNotifierProvider<LibraryNotifier, List<String>>((ref) {
  return LibraryNotifier();
});
