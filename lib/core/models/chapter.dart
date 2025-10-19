import 'package:hive/hive.dart';

part 'chapter.g.dart';

@HiveType(typeId: 1)
class Chapter extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String novelId;

  @HiveField(2)
  final String title;

  @HiveField(3)
  final int chapterNumber;

  @HiveField(4)
  final String content;

  @HiveField(5)
  final DateTime publishedAt;

  @HiveField(6)
  final bool isDownloaded;

  @HiveField(7)
  final bool isRead;

  @HiveField(8)
  final int? wordCount;

  @HiveField(9)
  final String? summary;

  Chapter({
    required this.id,
    required this.novelId,
    required this.title,
    required this.chapterNumber,
    required this.content,
    required this.publishedAt,
    this.isDownloaded = false,
    this.isRead = false,
    this.wordCount,
    this.summary,
  });

  Chapter copyWith({
    String? id,
    String? novelId,
    String? title,
    int? chapterNumber,
    String? content,
    DateTime? publishedAt,
    bool? isDownloaded,
    bool? isRead,
    int? wordCount,
    String? summary,
  }) {
    return Chapter(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      title: title ?? this.title,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      content: content ?? this.content,
      publishedAt: publishedAt ?? this.publishedAt,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      isRead: isRead ?? this.isRead,
      wordCount: wordCount ?? this.wordCount,
      summary: summary ?? this.summary,
    );
  }
}
