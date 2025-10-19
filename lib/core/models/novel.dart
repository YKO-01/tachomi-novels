import 'package:hive/hive.dart';

part 'novel.g.dart';

@HiveType(typeId: 0)
class Novel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String author;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String coverUrl;

  @HiveField(5)
  final List<String> tags;

  @HiveField(6)
  final String status; // Ongoing, Completed, Hiatus

  @HiveField(7)
  final int totalChapters;

  @HiveField(8)
  final DateTime lastUpdated;

  @HiveField(9)
  final double rating;

  @HiveField(10)
  final int views;

  @HiveField(11)
  final bool isFavorite;

  @HiveField(12)
  final bool isDownloaded;

  @HiveField(13)
  final int currentChapter;

  @HiveField(14)
  final DateTime? lastRead;

  Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.tags,
    required this.status,
    required this.totalChapters,
    required this.lastUpdated,
    required this.rating,
    required this.views,
    this.isFavorite = false,
    this.isDownloaded = false,
    this.currentChapter = 0,
    this.lastRead,
  });

  Novel copyWith({
    String? id,
    String? title,
    String? author,
    String? description,
    String? coverUrl,
    List<String>? tags,
    String? status,
    int? totalChapters,
    DateTime? lastUpdated,
    double? rating,
    int? views,
    bool? isFavorite,
    bool? isDownloaded,
    int? currentChapter,
    DateTime? lastRead,
  }) {
    return Novel(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      totalChapters: totalChapters ?? this.totalChapters,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      rating: rating ?? this.rating,
      views: views ?? this.views,
      isFavorite: isFavorite ?? this.isFavorite,
      isDownloaded: isDownloaded ?? this.isDownloaded,
      currentChapter: currentChapter ?? this.currentChapter,
      lastRead: lastRead ?? this.lastRead,
    );
  }
}
