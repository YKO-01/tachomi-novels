// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 2;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      isDarkMode: fields[0] as bool,
      downloadedOnly: fields[1] as bool,
      incognitoMode: fields[2] as bool,
      fontSize: fields[3] as double,
      fontFamily: fields[4] as String,
      lineHeight: fields[5] as double,
      autoDownload: fields[6] as bool,
      wifiOnlyDownload: fields[7] as bool,
      sortBy: fields[8] as String,
      filterBy: fields[9] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.downloadedOnly)
      ..writeByte(2)
      ..write(obj.incognitoMode)
      ..writeByte(3)
      ..write(obj.fontSize)
      ..writeByte(4)
      ..write(obj.fontFamily)
      ..writeByte(5)
      ..write(obj.lineHeight)
      ..writeByte(6)
      ..write(obj.autoDownload)
      ..writeByte(7)
      ..write(obj.wifiOnlyDownload)
      ..writeByte(8)
      ..write(obj.sortBy)
      ..writeByte(9)
      ..write(obj.filterBy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
