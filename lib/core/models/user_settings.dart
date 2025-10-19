import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 2)
class UserSettings extends HiveObject {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final bool downloadedOnly;

  @HiveField(2)
  final bool incognitoMode;

  @HiveField(3)
  final double fontSize;

  @HiveField(4)
  final String fontFamily;

  @HiveField(5)
  final double lineHeight;

  @HiveField(6)
  final bool autoDownload;

  @HiveField(7)
  final bool wifiOnlyDownload;

  @HiveField(8)
  final String sortBy; // Popular, Latest, Rating, Views

  @HiveField(9)
  final String filterBy; // All, Romance, BL, Slice of Life, etc.

  UserSettings({
    this.isDarkMode = false,
    this.downloadedOnly = false,
    this.incognitoMode = false,
    this.fontSize = 16.0,
    this.fontFamily = 'SF Pro Display',
    this.lineHeight = 1.5,
    this.autoDownload = false,
    this.wifiOnlyDownload = true,
    this.sortBy = 'Popular',
    this.filterBy = 'All',
  });

  UserSettings copyWith({
    bool? isDarkMode,
    bool? downloadedOnly,
    bool? incognitoMode,
    double? fontSize,
    String? fontFamily,
    double? lineHeight,
    bool? autoDownload,
    bool? wifiOnlyDownload,
    String? sortBy,
    String? filterBy,
  }) {
    return UserSettings(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      downloadedOnly: downloadedOnly ?? this.downloadedOnly,
      incognitoMode: incognitoMode ?? this.incognitoMode,
      fontSize: fontSize ?? this.fontSize,
      fontFamily: fontFamily ?? this.fontFamily,
      lineHeight: lineHeight ?? this.lineHeight,
      autoDownload: autoDownload ?? this.autoDownload,
      wifiOnlyDownload: wifiOnlyDownload ?? this.wifiOnlyDownload,
      sortBy: sortBy ?? this.sortBy,
      filterBy: filterBy ?? this.filterBy,
    );
  }
}
