import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/novel.dart';
import '../../../core/models/chapter.dart';
import '../../../core/services/novel_service.dart';
import '../../../core/services/history_service.dart';

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

  ReaderNotifier(this._novelService) : super(const ReaderState());

  Future<void> loadChapter(String novelId, String chapterId) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final novel = await _novelService.getNovelById(novelId);
      final chapters = await _novelService.getChaptersByNovelId(novelId);
      final chapter = chapters.firstWhere(
        (c) => c.id == chapterId,
        orElse: () => chapters.first,
      );
      
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
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void goToNextChapter() {
    if (state.hasNextChapter) {
      final nextIndex = state.currentChapterIndex + 1;
      final nextChapter = state.chapters[nextIndex];
      state = state.copyWith(
        chapter: nextChapter,
        currentChapterIndex: nextIndex,
      );
    }
  }

  void goToPreviousChapter() {
    if (state.hasPreviousChapter) {
      final prevIndex = state.currentChapterIndex - 1;
      final prevChapter = state.chapters[prevIndex];
      state = state.copyWith(
        chapter: prevChapter,
        currentChapterIndex: prevIndex,
      );
    }
  }

  void toggleBookmark() {
    state = state.copyWith(isBookmarked: !state.isBookmarked);
  }

  Future<void> trackReadingProgress(double progress) async {
    if (state.novel != null && state.chapter != null) {
      print('ReaderProvider: Tracking reading progress - ${state.novel!.title}, ${state.chapter!.title}, Progress: $progress');
      // Add to history with current progress
      await HistoryService.addToHistory(state.novel!, state.chapter!, progress);
    } else {
      print('ReaderProvider: Cannot track progress - novel or chapter is null');
    }
  }

  Future<void> markChapterAsCompleted() async {
    if (state.novel != null && state.chapter != null) {
      // Mark chapter as fully read (100% progress)
      await HistoryService.markChapterAsRead(state.novel!.id, state.chapter!.id);
    }
  }

  Future<void> updateReadingProgress(double progress) async {
    if (state.novel != null && state.chapter != null) {
      print('ReaderProvider: Updating reading progress - ${state.novel!.title}, ${state.chapter!.title}, Progress: $progress');
      // Update progress in history
      await HistoryService.updateProgress(state.novel!.id, state.chapter!.id, progress);
    } else {
      print('ReaderProvider: Cannot update progress - novel or chapter is null');
    }
  }
}

final readerProvider = StateNotifierProvider<ReaderNotifier, ReaderState>((ref) {
  final novelService = ref.watch(novelServiceProvider);
  return ReaderNotifier(novelService);
});

// Reader Settings
class ReaderSettings {
  final double fontSize;
  final double lineHeight;
  final ReaderTheme theme;

  const ReaderSettings({
    this.fontSize = 16.0,
    this.lineHeight = 1.5,
    this.theme = ReaderTheme.light,
  });

  ReaderSettings copyWith({
    double? fontSize,
    double? lineHeight,
    ReaderTheme? theme,
  }) {
    return ReaderSettings(
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      theme: theme ?? this.theme,
    );
  }
}

class ReaderSettingsNotifier extends StateNotifier<ReaderSettings> {
  ReaderSettingsNotifier() : super(const ReaderSettings());

  void updateFontSize(double fontSize) {
    state = state.copyWith(fontSize: fontSize);
  }

  void increaseFontSize() {
    state = state.copyWith(fontSize: (state.fontSize + 1).clamp(12.0, 24.0));
  }

  void decreaseFontSize() {
    state = state.copyWith(fontSize: (state.fontSize - 1).clamp(12.0, 24.0));
  }

  void updateLineHeight(double lineHeight) {
    state = state.copyWith(lineHeight: lineHeight);
  }

  void updateTheme(ReaderTheme theme) {
    state = state.copyWith(theme: theme);
  }
}

final readerSettingsProvider = StateNotifierProvider<ReaderSettingsNotifier, ReaderSettings>((ref) {
  return ReaderSettingsNotifier();
});

enum ReaderTheme { light, dark, sepia }
