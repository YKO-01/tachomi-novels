import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/manga.dart';
import '../models/manga_chapter.dart';

class MangaService {
  // Google Drive direct-download URLs for remote JSON files.
  // Share links (drive.google.com/file/d/<ID>/view) are converted to the
  // direct-download form: drive.google.com/uc?export=download&id=<ID>
  // https://drive.google.com/file/d/1kVUdBNT_NgjBnwR5E5ePubWMzEd4DyWq/view?usp=sharing
  // https://drive.google.com/file/d/1FgQARDB69i96Zlw_EE69tZNRL34lmMU9/view?usp=sharing
  static const String _mangasJsonUrl = 'https://drive.google.com/uc?export=download&id=1kVUdBNT_NgjBnwR5E5ePubWMzEd4DyWq';
  static const String _chaptersJsonUrl = 'https://drive.google.com/uc?export=download&id=1FgQARDB69i96Zlw_EE69tZNRL34lmMU9';

  // In-memory cache: both JSON files are large, fetch them once per session.
  static List<Manga>? _cachedMangas;
  static List<MangaChapter>? _cachedChapters;

  Future<List<Manga>> getMangas({bool forceRefresh = false}) async {
    if (_cachedMangas != null && !forceRefresh) {
      return List.from(_cachedMangas!);
    }

    debugPrint('MangaService: Fetching mangas from remote JSON...');
    final response = await http.get(Uri.parse(_mangasJsonUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load mangas: ${response.statusCode}');
    }

    final Map<String, dynamic> jsonMap = json.decode(response.body);
    final List<dynamic> jsonList = jsonMap['mangas'] ?? [];
    _cachedMangas = jsonList.map((json) => Manga.fromJson(json)).toList();

    debugPrint('MangaService: Loaded ${_cachedMangas!.length} mangas from JSON');
    return List.from(_cachedMangas!);
  }

  Future<Manga?> getMangaById(String id) async {
    try {
      final mangas = await getMangas();
      return mangas.firstWhere((manga) => manga.id == id);
    } catch (e) {
      debugPrint('MangaService: Manga not found - $id');
      return null;
    }
  }

  Future<List<MangaChapter>> _getAllChapters({bool forceRefresh = false}) async {
    if (_cachedChapters != null && !forceRefresh) {
      return _cachedChapters!;
    }

    debugPrint('MangaService: Fetching chapters from remote JSON...');
    final response = await http.get(Uri.parse(_chaptersJsonUrl));
    if (response.statusCode != 200) {
      throw Exception('Failed to load manga chapters: ${response.statusCode}');
    }

    final List<dynamic> jsonList = json.decode(response.body);
    _cachedChapters = jsonList.map((json) => MangaChapter.fromJson(json)).toList();

    debugPrint('MangaService: Loaded ${_cachedChapters!.length} manga chapters from JSON');
    return _cachedChapters!;
  }

  Future<List<MangaChapter>> getChaptersByMangaId(String mangaId) async {
    try {
      final allChapters = await _getAllChapters();
      final chapters = allChapters.where((chapter) => chapter.mangaId == mangaId).toList();
      chapters.sort((a, b) => a.number.compareTo(b.number));
      return chapters;
    } catch (e) {
      debugPrint('MangaService: Error loading chapters for $mangaId - $e');
      rethrow;
    }
  }

  Future<MangaChapter?> getChapterById(String mangaId, String chapterId) async {
    try {
      final chapters = await getChaptersByMangaId(mangaId);
      return chapters.firstWhere((chapter) => chapter.id == chapterId);
    } catch (e) {
      return null;
    }
  }

  Future<List<Manga>> searchMangas(String query) async {
    final mangas = await getMangas();
    final lowerQuery = query.toLowerCase();
    return mangas.where((manga) {
      return manga.title.toLowerCase().contains(lowerQuery) ||
             manga.genres.any((genre) => genre.toLowerCase().contains(lowerQuery));
    }).toList();
  }
}

final mangaServiceProvider = Provider<MangaService>((ref) {
  return MangaService();
});
