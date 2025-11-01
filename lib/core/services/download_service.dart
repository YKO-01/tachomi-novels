import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/chapter.dart';

class DownloadService {
  static const String _kBoxName = 'downloaded_chapters_box';
  static Box<Chapter>? _box;

  static Future<void> _ensureBox() async {
    if (_box != null && _box!.isOpen) return;
    try {
      _box = await Hive.openBox<Chapter>(_kBoxName);
    } catch (e) {
      debugPrint('DownloadService: failed to open box: $e');
      rethrow;
    }
  }

  static Future<void> saveChapter(Chapter chapter) async {
    await _ensureBox();
    final downloaded = chapter.copyWith(isDownloaded: true);
    await _box!.put(downloaded.id, downloaded);
    debugPrint('DownloadService: saved chapter ${downloaded.id}');
  }

  static Future<Chapter?> getDownloadedChapter(String chapterId) async {
    await _ensureBox();
    return _box!.get(chapterId);
  }

  static Future<bool> isDownloaded(String chapterId) async {
    await _ensureBox();
    return _box!.containsKey(chapterId);
  }

  static Future<void> removeChapter(String chapterId) async {
    await _ensureBox();
    await _box!.delete(chapterId);
  }

  static Future<void> clearAll() async {
    await _ensureBox();
    await _box!.clear();
  }
}


