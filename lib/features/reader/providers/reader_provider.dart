import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/novel.dart';
import '../../../core/models/chapter.dart';
import '../../../core/models/user_settings.dart';
import '../../../core/services/novel_service.dart';
import '../../../core/services/download_service.dart';
import '../../../core/services/network_service.dart';
import '../../history/providers/history_provider.dart';
import '../../more/providers/settings_provider.dart';

class ReaderState {
  final Novel? novel;
  final Chapter? chapter;
  final List<Chapter> chapters;
  final int currentChapterIndex;
  final bool isBookmarked;
  final bool isLoading;
  final String? error;

  const ReaderState({
    this.novel,
    this.chapter,
    this.chapters = const [],
    this.currentChapterIndex = 0,
    this.isBookmarked = false,
    this.isLoading = false,
    this.error,
  });

  bool get hasPreviousChapter => currentChapterIndex > 0;
  bool get hasNextChapter => currentChapterIndex < chapters.length - 1;
  int get totalChapters => chapters.length;

  ReaderState copyWith({
    Novel? novel,
    Chapter? chapter,
    List<Chapter>? chapters,
    int? currentChapterIndex,
    bool? isBookmarked,
    bool? isLoading,
    String? error,
  }) {
    return ReaderState(
      novel: novel ?? this.novel,
      chapter: chapter ?? this.chapter,
      chapters: chapters ?? this.chapters,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ReaderNotifier extends StateNotifier<ReaderState> {
  final NovelService _novelService;
  final Ref _ref;

  ReaderNotifier(this._novelService, this._ref) : super(const ReaderState());

  Future<void> loadChapter(String novelId, String chapterId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final novel = await _novelService.getNovelById(novelId);
      final chapters = await _novelService.getChaptersByNovelId(novelId);
      // Prefer downloaded chapter content when available
      Chapter chapter = chapters.firstWhere(
        (c) => c.id == chapterId,
        orElse: () => chapters.first,
      );
      final downloaded = await DownloadService.getDownloadedChapter(chapter.id);
      if (downloaded != null) {
        chapter = downloaded;
      } else {
        // If offline and not downloaded, block reading
        final online = await NetworkService.isOnline();
        if (!online) {
          state = state.copyWith(
            isLoading: false,
            error: 'No internet connection. This chapter is not downloaded.',
          );
          return;
        }
      }
      
      if (novel == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'Novel not found',
        );
        return;
      }
      
      final chapterIndex = chapters.indexWhere((c) => c.id == chapterId);
      
      state = state.copyWith(
        novel: novel,
        chapter: chapter,
        chapters: chapters,
        currentChapterIndex: chapterIndex >= 0 ? chapterIndex : 0,
        isLoading: false,
      );
      
      // Add to history immediately when chapter loads successfully
      try {
        await _ref.read(historyProvider.notifier).addNovelToHistory(novel, chapter);
        debugPrint('ReaderProvider: Added to history immediately - ${novel.title}, ${chapter.title}');
      } catch (error) {
        debugPrint('ReaderProvider: Error adding to history - $error');
        // Don't fail the chapter load if history fails
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> goToNextChapter() async {
    if (state.hasNextChapter && state.novel != null) {
      final nextIndex = state.currentChapterIndex + 1;
      final nextChapter = state.chapters[nextIndex];
      state = state.copyWith(
        chapter: nextChapter,
        currentChapterIndex: nextIndex,
      );
      
      // Add to history immediately when navigating to next chapter
      try {
        await _ref.read(historyProvider.notifier).addNovelToHistory(state.novel!, nextChapter);
        debugPrint('ReaderProvider: Added next chapter to history - ${state.novel!.title}, ${nextChapter.title}');
      } catch (error) {
        debugPrint('ReaderProvider: Error adding next chapter to history - $error');
      }
    }
  }

  Future<void> goToPreviousChapter() async {
    if (state.hasPreviousChapter && state.novel != null) {
      final prevIndex = state.currentChapterIndex - 1;
      final prevChapter = state.chapters[prevIndex];
      state = state.copyWith(
        chapter: prevChapter,
        currentChapterIndex: prevIndex,
      );
      
      // Add to history immediately when navigating to previous chapter
      try {
        await _ref.read(historyProvider.notifier).addNovelToHistory(state.novel!, prevChapter);
        debugPrint('ReaderProvider: Added previous chapter to history - ${state.novel!.title}, ${prevChapter.title}');
      } catch (error) {
        debugPrint('ReaderProvider: Error adding previous chapter to history - $error');
      }
    }
  }

  void toggleBookmark() {
    state = state.copyWith(isBookmarked: !state.isBookmarked);
  }

  Future<void> trackReadingProgress(double progress) async {
    if (state.novel != null && state.chapter != null) {
      debugPrint('ReaderProvider: Tracking reading progress - ${state.novel!.title}, ${state.chapter!.title}, Progress: $progress');
      // Add novel to history when reading
      await _ref.read(historyProvider.notifier).addNovelToHistory(state.novel!, state.chapter!);
    } else {
      debugPrint('ReaderProvider: Cannot track progress - novel or chapter is null');
    }
  }

  Future<void> markChapterAsCompleted() async {
    if (state.novel != null && state.chapter != null) {
      debugPrint('ReaderProvider: Chapter completed - ${state.novel!.title}, ${state.chapter!.title}');
      // Update history with completed chapter
      await _ref.read(historyProvider.notifier).addNovelToHistory(state.novel!, state.chapter!);
    }
  }

  Future<void> updateReadingProgress(double progress) async {
    if (state.novel != null && state.chapter != null) {
      debugPrint('ReaderProvider: Updating reading progress - ${state.novel!.title}, ${state.chapter!.title}, Progress: $progress');
      // Update history with current reading progress
      await _ref.read(historyProvider.notifier).addNovelToHistory(state.novel!, state.chapter!);
    } else {
      debugPrint('ReaderProvider: Cannot update progress - novel or chapter is null');
    }
  }
}

final readerProvider = StateNotifierProvider<ReaderNotifier, ReaderState>((ref) {
  final novelService = ref.watch(novelServiceProvider);
  return ReaderNotifier(novelService, ref);
});

// Reader Settings
class ReaderSettings {
  final double fontSize;
  final double lineHeight;
  final String fontFamily;
  final ReaderTheme theme;

  const ReaderSettings({
    this.fontSize = 16.0,
    this.lineHeight = 1.5,
    this.fontFamily = 'Default',
    this.theme = ReaderTheme.light,
  });

  ReaderSettings copyWith({
    double? fontSize,
    double? lineHeight,
    String? fontFamily,
    ReaderTheme? theme,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      fontFamily: fontFamily ?? this.fontFamily,
      theme: theme ?? this.theme,
    );
  }
}

class ReaderSettingsNotifier extends StateNotifier<ReaderSettings> {
  final Ref _ref;
  
  ReaderSettingsNotifier(this._ref) : super(const ReaderSettings()) {
    // Initialize from user settings
    _syncWithUserSettings();
    
    // Listen to user settings changes and sync
    _ref.listen<UserSettings>(settingsProvider, (previous, next) {
      if (previous != next) {
        _syncWithUserSettings();
      }
    });
  }

  void _syncWithUserSettings() {
    final userSettings = _ref.read(settingsProvider);
    state = ReaderSettings(
      fontSize: userSettings.fontSize,
      lineHeight: userSettings.lineHeight,
      fontFamily: userSettings.fontFamily,
      theme: state.theme, // Keep current theme as it's reader-specific
    );
  }

  void updateFontSize(double fontSize) {
    state = state.copyWith(fontSize: fontSize);
    // Sync back to user settings
    _ref.read(settingsProvider.notifier).updateFontSize(fontSize);
  }

  void increaseFontSize() {
    final newSize = (state.fontSize + 1).clamp(12.0, 24.0);
    updateFontSize(newSize);
  }

  void decreaseFontSize() {
    final newSize = (state.fontSize - 1).clamp(12.0, 24.0);
    updateFontSize(newSize);
  }

  void updateLineHeight(double lineHeight) {
    state = state.copyWith(lineHeight: lineHeight);
    // Sync back to user settings
    _ref.read(settingsProvider.notifier).updateLineHeight(lineHeight);
  }

  void updateFontFamily(String fontFamily) {
    state = state.copyWith(fontFamily: fontFamily);
    // Sync back to user settings
    _ref.read(settingsProvider.notifier).updateFontFamily(fontFamily);
  }

  void updateTheme(ReaderTheme theme) {
    state = state.copyWith(theme: theme);
    // Theme is reader-specific, don't sync to user settings
  }
}

final readerSettingsProvider = StateNotifierProvider<ReaderSettingsNotifier, ReaderSettings>((ref) {
  return ReaderSettingsNotifier(ref);
});

enum ReaderTheme { light, dark, sepia }
