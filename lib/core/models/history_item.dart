import 'package:hive/hive.dart';

part 'history_item.g.dart';

@HiveType(typeId: 2)
class HistoryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String novelId;

  @HiveField(2)
  final String chapterId;

  @HiveField(3)
  final DateTime lastRead;

  @HiveField(4)
  final double progress; // 0.0 to 1.0

  @HiveField(5)
  final bool isCompleted;

  HistoryItem({
    required this.id,
    required this.novelId,
    required this.chapterId,
    required this.lastRead,
    required this.progress,
    this.isCompleted = false,
  });

  HistoryItem copyWith({
    String? id,
    String? novelId,
    String? chapterId,
    DateTime? lastRead,
    double? progress,
    bool? isCompleted,
  }) {
    return HistoryItem(
      id: id ?? this.id,
      novelId: novelId ?? this.novelId,
      chapterId: chapterId ?? this.chapterId,
      lastRead: lastRead ?? this.lastRead,
      progress: progress ?? this.progress,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
