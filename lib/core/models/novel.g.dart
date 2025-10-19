// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NovelAdapter extends TypeAdapter<Novel> {
  @override
  final int typeId = 0;

  @override
  Novel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Novel(
      id: fields[0] as String,
      title: fields[1] as String,
      author: fields[2] as String,
      description: fields[3] as String,
      coverUrl: fields[4] as String,
      tags: (fields[5] as List).cast<String>(),
      status: fields[6] as String,
      totalChapters: fields[7] as int,
      lastUpdated: fields[8] as DateTime,
      rating: fields[9] as double,
      views: fields[10] as int,
      isFavorite: fields[11] as bool,
      isDownloaded: fields[12] as bool,
      currentChapter: fields[13] as int,
      lastRead: fields[14] as DateTime?,
      isInLibrary: fields[15] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Novel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.author)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.coverUrl)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.status)
      ..writeByte(7)
      ..write(obj.totalChapters)
      ..writeByte(8)
      ..write(obj.lastUpdated)
      ..writeByte(9)
      ..write(obj.rating)
      ..writeByte(10)
      ..write(obj.views)
      ..writeByte(11)
      ..write(obj.isFavorite)
      ..writeByte(12)
      ..write(obj.isDownloaded)
      ..writeByte(13)
      ..write(obj.currentChapter)
      ..writeByte(14)
      ..write(obj.lastRead)
      ..writeByte(15)
      ..write(obj.isInLibrary);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NovelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
