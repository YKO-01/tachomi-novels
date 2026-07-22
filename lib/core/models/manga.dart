class Manga {
  final String id;
  final String title;
  final String coverImage;
  final String description;
  final List<String> genres;
  final double rating;
  final String status; // Ongoing, Completed, Hiatus
  final String type; // Manhwa, Manhua, Manga
  final String url;
  final bool isFavorite;
  final bool isInLibrary;

  Manga({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.description,
    required this.genres,
    required this.rating,
    required this.status,
    required this.type,
    required this.url,
    this.isFavorite = false,
    this.isInLibrary = false,
  });

  factory Manga.fromJson(Map<String, dynamic> json) {
    return Manga(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      coverImage: json['coverImage'] ?? '',
      description: json['description'] ?? '',
      genres: List<String>.from(json['genres'] ?? []),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'Ongoing',
      type: json['type'] ?? 'Manga',
      url: json['url'] ?? '',
    );
  }

  Manga copyWith({
    String? id,
    String? title,
    String? coverImage,
    String? description,
    List<String>? genres,
    double? rating,
    String? status,
    String? type,
    String? url,
    bool? isFavorite,
    bool? isInLibrary,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      type: type ?? this.type,
      url: url ?? this.url,
      isFavorite: isFavorite ?? this.isFavorite,
      isInLibrary: isInLibrary ?? this.isInLibrary,
    );
  }
}
