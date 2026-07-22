class MangaChapter {
  final String id;
  final String mangaId;
  final double number;
  final String title;
  final String releaseDate;
  final List<String> pages;
  final String url;

  MangaChapter({
    required this.id,
    required this.mangaId,
    required this.number,
    required this.title,
    required this.releaseDate,
    required this.pages,
    required this.url,
  });

  factory MangaChapter.fromJson(Map<String, dynamic> json) {
    return MangaChapter(
      id: json['id'] ?? '',
      mangaId: json['mangaId'] ?? '',
      number: (json['number'] as num?)?.toDouble() ?? 0.0,
      title: json['title'] ?? '',
      releaseDate: json['releaseDate'] ?? '',
      pages: List<String>.from(json['pages'] ?? []),
      url: json['url'] ?? '',
    );
  }

  /// "1.0" -> "1", "1.5" stays "1.5"
  String get displayNumber =>
      number == number.roundToDouble() ? number.toInt().toString() : number.toString();
}
