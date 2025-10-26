import 'package:hive/hive.dart';
import 'novel.dart';
import 'chapter.dart';

part 'novel_history.g.dart';

@HiveType(typeId: 2)
class NovelHistory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String novelId;

  @HiveField(2)
  final String novelTitle;

  @HiveField(3)
  final String author;

  @HiveField(4)
  final String coverUrl;

  @HiveField(5)
  final DateTime lastRead;

  @HiveField(6)
  final String lastChapterId;

  @HiveField(7)
  final String lastChapterTitle;

  @HiveField(8)
  final int lastChapterNumber;

  NovelHistory({
    required this.id,
    required this.novelId,
    required this.novelTitle,
    required this.author,
    required this.coverUrl,
    required this.lastRead,
    required this.lastChapterId,
    required this.lastChapterTitle,
    required this.lastChapterNumber,
  });

  NovelHistory copyWith({
    String? id,
    String? novelId,
    String? novelTitle,
    String? author,
    String? coverUrl,
    DateTime? lastRead,
    String? lastChapterId,
    String? lastChapterTitle,
    int? lastChapterNumber,
  }) {
    return NovelHistory(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      novelTitle: novelTitle ?? this.novelTitle,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      lastRead: lastRead ?? this.lastRead,
      lastChapterId: lastChapterId ?? this.lastChapterId,
      lastChapterTitle: lastChapterTitle ?? this.lastChapterTitle,
      lastChapterNumber: lastChapterNumber ?? this.lastChapterNumber,
    );
  }

  // Create from Novel and Chapter
  factory NovelHistory.fromNovelAndChapter(Novel novel, Chapter chapter) {
    return NovelHistory(
      id: 'novel_${novel.id}',
      novelId: novel.id,
      novelTitle: novel.title,
      author: novel.author,
      coverUrl: novel.coverUrl,
      lastRead: DateTime.now(),
      lastChapterId: chapter.id,
      lastChapterTitle: chapter.title,
      lastChapterNumber: chapter.chapterNumber,
    );
  }

  // Update when a new chapter is read
  NovelHistory updateLastChapter(Chapter chapter) {
    return copyWith(
      lastRead: DateTime.now(),
      lastChapterId: chapter.id,
      lastChapterTitle: chapter.title,
      lastChapterNumber: chapter.chapterNumber,
    );
  }

  // Get formatted last read time
  String get formattedLastRead {
    final now = DateTime.now();
    final difference = now.difference(lastRead);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  // Get last chapter display text
  String get lastChapterDisplay => 'Chapter $lastChapterNumber';
}
