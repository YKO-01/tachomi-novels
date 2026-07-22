import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../core/models/manga.dart';
import '../../../core/models/manga_chapter.dart';
import '../../../core/services/history_service.dart';
import '../../../shared/constants/app_constants.dart';
import '../providers/manga_providers.dart';

class MangaReaderPage extends ConsumerStatefulWidget {
  final String mangaId;
  final String chapterId;

  const MangaReaderPage({
    super.key,
    required this.mangaId,
    required this.chapterId,
  });

  @override
  ConsumerState<MangaReaderPage> createState() => _MangaReaderPageState();
}

class _MangaReaderPageState extends ConsumerState<MangaReaderPage> {
  bool _showControls = true;
  bool _historySaved = false;

  @override
  void initState() {
    super.initState();
    // Immersive reading: hide status bar and system navigation
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore system bars when leaving the reader
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _saveToHistory(Manga manga, MangaChapter chapter) {
    if (_historySaved) return;
    _historySaved = true;
    HistoryService.addMangaToHistory(manga, chapter);
  }

  @override
  Widget build(BuildContext context) {
    final mangaAsync = ref.watch(mangaDetailsProvider(widget.mangaId));
    final chaptersAsync = ref.watch(mangaChaptersProvider(widget.mangaId));
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: chaptersAsync.when(
        data: (chapters) {
          final chapterIndex = chapters.indexWhere((chapter) => chapter.id == widget.chapterId);
          if (chapterIndex == -1) {
            return const Center(
              child: Text('Chapter not found', style: TextStyle(color: Colors.white)),
            );
          }
          final chapter = chapters[chapterIndex];

          // Record reading history once the manga info is available
          mangaAsync.whenData((manga) {
            if (manga != null) _saveToHistory(manga, chapter);
          });

          return Stack(
            children: [
              // Pages
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showControls = !_showControls;
                  });
                },
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: chapter.pages.length,
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: chapter.pages[index],
                      fit: BoxFit.fitWidth,
                      width: double.infinity,
                      httpHeaders: const {
                        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                        'Referer': 'https://en-thunderscans.com/',
                      },
                      placeholder: (context, url) => Container(
                        height: 400,
                        color: Colors.grey[900],
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        height: 200,
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(Icons.broken_image, color: Colors.white54, size: 48),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Top bar
              if (_showControls)
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top,
                    ),
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () => context.pop(),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                mangaAsync.valueOrNull?.title ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Chapter ${chapter.displayNumber}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppConstants.spacingM),
                      ],
                    ),
                  ),
                ),

              // Bottom bar: previous / next chapter
              if (_showControls)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + AppConstants.spacingS,
                      top: AppConstants.spacingS,
                      left: AppConstants.spacingM,
                      right: AppConstants.spacingM,
                    ),
                    color: Colors.black.withValues(alpha: 0.7),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: chapterIndex > 0
                              ? () => _navigateToChapter(chapters[chapterIndex - 1])
                              : null,
                          icon: const Icon(Icons.skip_previous),
                          label: const Text('Previous'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white30,
                          ),
                        ),
                        Text(
                          '${chapterIndex + 1} / ${chapters.length}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        TextButton.icon(
                          onPressed: chapterIndex < chapters.length - 1
                              ? () => _navigateToChapter(chapters[chapterIndex + 1])
                              : null,
                          icon: const Icon(Icons.skip_next),
                          label: const Text('Next'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white30,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: AppConstants.spacingM),
              const Text(
                'Failed to load chapter',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: AppConstants.spacingM),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(mangaChaptersProvider(widget.mangaId));
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToChapter(MangaChapter chapter) {
    // No ad here, matching the novel reader's Previous/Next behavior
    context.pushReplacement('/manga-reader/${widget.mangaId}/${chapter.id}');
  }
}
