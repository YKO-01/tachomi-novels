import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/novel.dart';
import '../../../core/models/chapter.dart';
import '../../../shared/constants/app_constants.dart';
import '../providers/reader_provider.dart';

class ReaderPage extends ConsumerStatefulWidget {
  final String novelId;
  final String chapterId;

  const ReaderPage({
    super.key,
    required this.novelId,
    required this.chapterId,
  });

  @override
  ConsumerState<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends ConsumerState<ReaderPage> {
  final ScrollController _scrollController = ScrollController();
  bool _showSettings = false;
  
  final List<String> _fontFamilies = [
    'Default',
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Inter',
    'Roboto Mono',
    'Source Sans Pro',
    'Noto Sans',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(readerProvider.notifier).loadChapter(widget.novelId, widget.chapterId);
      // History is now added immediately when chapter loads in loadChapter method
    });
    
    // Add scroll listener to track reading progress
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      
      if (maxScroll > 0) {
        final progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
        ref.read(readerProvider.notifier).updateReadingProgress(progress);
        
        // Mark as completed when reaching the end
        if (progress >= 0.95) {
          ref.read(readerProvider.notifier).markChapterAsCompleted();
        }
      }
    }
  }


  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final readerState = ref.watch(readerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(readerState.chapter?.title ?? 'Loading...'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.bookmark_border),
          //   onPressed: () {
          //     ref.read(readerProvider.notifier).toggleBookmark();
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              setState(() {
                _showSettings = !_showSettings;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Settings Panel
          if (_showSettings) _buildSettingsPanel(),
          
          // Reader Content
          Expanded(
            child: readerState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : readerState.error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
                            const SizedBox(height: AppConstants.spacingM),
                            Text('Failed to load chapter', style: theme.textTheme.headlineSmall),
                            const SizedBox(height: AppConstants.spacingS),
                            Text(readerState.error.toString(), style: theme.textTheme.bodyMedium),
                            const SizedBox(height: AppConstants.spacingM),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(readerProvider.notifier).loadChapter(widget.novelId, widget.chapterId);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : readerState.novel != null && readerState.chapter != null
                        ? _buildReaderContent(readerState.novel!, readerState.chapter!)
                        : const Center(child: CircularProgressIndicator()),
          ),
          
          // Navigation Bar
          _buildNavigationBar(),
        ],
      ),
    );
  }

  Widget _buildSettingsPanel() {
    final readerSettings = ref.watch(readerSettingsProvider);
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          // Font Size
          Row(
            children: [
              const Icon(Icons.text_fields),
              const SizedBox(width: AppConstants.spacingS),
              const Text('Font Size'),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.remove),
                onPressed: () {
                  ref.read(readerSettingsProvider.notifier).decreaseFontSize();
                },
              ),
              Text('${readerSettings.fontSize.toInt()}'),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  ref.read(readerSettingsProvider.notifier).increaseFontSize();
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacingS),
          
          // Theme Selection
          Row(
            children: [
              const Icon(Icons.palette),
              const SizedBox(width: AppConstants.spacingS),
              const Text('Theme'),
              const Spacer(),
              _buildThemeButton('Light', ReaderTheme.light, readerSettings.theme),
              const SizedBox(width: AppConstants.spacingS),
              _buildThemeButton('Dark', ReaderTheme.dark, readerSettings.theme),
              const SizedBox(width: AppConstants.spacingS),
              _buildThemeButton('Sepia', ReaderTheme.sepia, readerSettings.theme),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacingS),
          
          // Line Height
          Row(
            children: [
              const Icon(Icons.format_line_spacing),
              const SizedBox(width: AppConstants.spacingS),
              const Text('Line Height'),
              const Spacer(),
              Slider(
                value: readerSettings.lineHeight,
                min: 1.0,
                max: 2.5,
                divisions: 15,
                onChanged: (value) {
                  ref.read(readerSettingsProvider.notifier).updateLineHeight(value);
                },
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.spacingS),
          
          // Font Family
          Row(
            children: [
              const Icon(Icons.font_download),
              const SizedBox(width: AppConstants.spacingS),
              const Text('Font Family'),
              const Spacer(),
              DropdownButton<String>(
                value: readerSettings.fontFamily,
                items: _fontFamilies.map((font) {
                  return DropdownMenuItem<String>(
                    value: font,
                    child: Text(
                      font,
                      style: _getTextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                        lineHeight: 1.5,
                        fontFamily: font == 'Default' ? '' : font,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(readerSettingsProvider.notifier).updateFontFamily(value);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeButton(String label, ReaderTheme theme, ReaderTheme currentTheme) {
    final isSelected = theme == currentTheme;
    return GestureDetector(
      onTap: () {
        ref.read(readerSettingsProvider.notifier).updateTheme(theme);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected 
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  TextStyle _getTextStyle({
    required double fontSize,
    required Color color,
    required double lineHeight,
    required String fontFamily,
    FontWeight? fontWeight,
  }) {
    // Map font family names to Google Fonts
    TextStyle baseStyle;
    
    switch (fontFamily) {
      case 'Roboto':
        baseStyle = GoogleFonts.roboto(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          height: lineHeight,
        );
        break;
      case 'Open Sans':
        baseStyle = GoogleFonts.openSans(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          height: lineHeight,
        );
        break;
      case 'Lato':
        baseStyle = GoogleFonts.lato(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          height: lineHeight,
        );
        break;
      case 'Montserrat':
        baseStyle = GoogleFonts.montserrat(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          height: lineHeight,
        );
        break;
      case 'Poppins':
        baseStyle = GoogleFonts.poppins(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          height: lineHeight,
        );
        break;
      case 'Inter':
        baseStyle = GoogleFonts.inter(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          height: lineHeight,
        );
        break;
      case 'Roboto Mono':
        baseStyle = GoogleFonts.robotoMono(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          height: lineHeight,
        );
        break;
      case 'Source Sans Pro':
        baseStyle = GoogleFonts.sourceSans3(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          height: lineHeight,
        );
        break;
      case 'Noto Sans':
        baseStyle = GoogleFonts.notoSans(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          height: lineHeight,
        );
        break;
      default: // 'Default' or any other - use system default
        baseStyle = TextStyle(
          fontSize: fontSize,
          fontWeight: fontWeight ?? FontWeight.normal,
          height: lineHeight,
        );
    }
    
    return baseStyle.copyWith(color: color);
  }

  Widget _buildReaderContent(Novel novel, Chapter chapter) {
    final readerSettings = ref.watch(readerSettingsProvider);
    final theme = _getReaderTheme(readerSettings.theme);
    
    return Container(
      color: theme.backgroundColor,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chapter Title
            Text(
              chapter.title,
              style: _getTextStyle(
                fontSize: readerSettings.fontSize + 4,
                color: theme.textColor,
                lineHeight: readerSettings.lineHeight,
                fontFamily: readerSettings.fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: AppConstants.spacingM),
            
            // Chapter Content
            Text(
              chapter.content,
              style: _getTextStyle(
                fontSize: readerSettings.fontSize,
                color: theme.textColor,
                lineHeight: readerSettings.lineHeight,
                fontFamily: readerSettings.fontFamily,
              ),
            ),
            
            const SizedBox(height: AppConstants.spacingXL),
            
            // Chapter Info
            Container(
              padding: const EdgeInsets.all(AppConstants.spacingM),
              decoration: BoxDecoration(
                color: theme.surfaceColor,
                borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chapter ${chapter.chapterNumber}',
                    style: _getTextStyle(
                      fontSize: readerSettings.fontSize - 2,
                      color: theme.textColor,
                      lineHeight: readerSettings.lineHeight,
                      fontFamily: readerSettings.fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spacingXS),
                  Text(
                    'Published ${_formatDate(chapter.publishedAt)}',
                    style: _getTextStyle(
                      fontSize: readerSettings.fontSize - 4,
                      color: theme.textColor.withValues(alpha: 0.7),
                      lineHeight: readerSettings.lineHeight,
                      fontFamily: readerSettings.fontFamily,
                    ),
                  ),
                  if (chapter.wordCount != null) ...[
                    const SizedBox(height: AppConstants.spacingXS),
                    Text(
                      '${chapter.wordCount} words',
                      style: _getTextStyle(
                        fontSize: readerSettings.fontSize - 4,
                        color: theme.textColor.withValues(alpha: 0.7),
                        lineHeight: readerSettings.lineHeight,
                        fontFamily: readerSettings.fontFamily,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    final readerState = ref.watch(readerProvider);
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.spacingM),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Chapter
          ElevatedButton.icon(
            onPressed: readerState.hasPreviousChapter 
                ? () => ref.read(readerProvider.notifier).goToPreviousChapter()
                : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Previous'),
          ),
          
          // Chapter Progress
          Text(
            '${readerState.currentChapterIndex + 1} / ${readerState.totalChapters}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          
          // Next Chapter
          ElevatedButton.icon(
            onPressed: readerState.hasNextChapter 
                ? () => ref.read(readerProvider.notifier).goToNextChapter()
                : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Next'),
          ),
        ],
      ),
    );
  }

  ReaderThemeColors _getReaderTheme(ReaderTheme theme) {
    switch (theme) {
      case ReaderTheme.light:
        return ReaderThemeColors(
          backgroundColor: Colors.white,
          textColor: Colors.black87,
          surfaceColor: Colors.grey[100]!,
        );
      case ReaderTheme.dark:
        return ReaderThemeColors(
          backgroundColor: const Color(0xFF1E1E1E),
          textColor: Colors.white,
          surfaceColor: const Color(0xFF2D2D2D),
        );
      case ReaderTheme.sepia:
        return ReaderThemeColors(
          backgroundColor: const Color(0xFFF4F1EA),
          textColor: const Color(0xFF5C4B37),
          surfaceColor: const Color(0xFFE8E0D0),
        );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}

class ReaderThemeColors {
  final Color backgroundColor;
  final Color textColor;
  final Color surfaceColor;

  ReaderThemeColors({
    required this.backgroundColor,
    required this.textColor,
    required this.surfaceColor,
  });
}

