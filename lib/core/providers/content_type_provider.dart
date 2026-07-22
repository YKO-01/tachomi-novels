import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What kind of content the user is browsing. Manga is the default.
enum ContentType { manga, novel }

class ContentTypeNotifier extends StateNotifier<ContentType> {
  static const String _prefsKey = 'selected_content_type';

  ContentTypeNotifier() : super(ContentType.manga) {
    _loadSavedType();
  }

  Future<void> _loadSavedType() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved == 'novel') {
      state = ContentType.novel;
    }
  }

  Future<void> setType(ContentType type) async {
    state = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, type == ContentType.novel ? 'novel' : 'manga');
  }
}

final contentTypeProvider = StateNotifierProvider<ContentTypeNotifier, ContentType>((ref) {
  return ContentTypeNotifier();
});
