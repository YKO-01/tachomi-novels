// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'novel_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NovelHistoryAdapter extends TypeAdapter<NovelHistory> {
  @override
  final int typeId = 2;

  @override
  NovelHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NovelHistory(
      id: fields[0] as String,
      novelId: fields[1] as String,
      novelTitle: fields[2] as String,
      author: fields[3] as String,
      coverUrl: fields[4] as String,
      lastRead: fields[5] as DateTime,
      lastChapterId: fields[6] as String,
      lastChapterTitle: fields[7] as String,
      lastChapterNumber: fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, NovelHistory obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.novelId)
      ..writeByte(2)
      ..write(obj.novelTitle)
      ..writeByte(3)
      ..write(obj.author)
      ..writeByte(4)
      ..write(obj.coverUrl)
      ..writeByte(5)
      ..write(obj.lastRead)
      ..writeByte(6)
      ..write(obj.lastChapterId)
      ..writeByte(7)
      ..write(obj.lastChapterTitle)
      ..writeByte(8)
      ..write(obj.lastChapterNumber);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NovelHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
