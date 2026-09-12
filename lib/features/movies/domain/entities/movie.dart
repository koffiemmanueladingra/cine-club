class Movie {
  const Movie({
    required this.id,
    required this.title,
    required this.overview,
    required this.posterUrl,
    required this.releaseYear,
    required this.rating,
    required this.genre,
  });

  final String id;
  final String title;
  final String overview;
  final String? posterUrl;
  final int? releaseYear;
  final double? rating;
  final String? genre;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Movie && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
