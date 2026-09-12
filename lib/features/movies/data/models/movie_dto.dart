import '../../domain/entities/movie.dart';

class MovieDto {
  const MovieDto._();

  static Movie fromJson(Map<String, dynamic> json) => Movie(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Sans titre',
        overview: json['overview'] as String? ?? '',
        posterUrl: json['poster_url'] as String?,
        releaseYear: _toInt(json['release_year']),
        rating: _toDouble(json['rating']),
        genre: json['genre'] as String?,
      );

  static Map<String, dynamic> toJson(Movie movie) => {
        'id': movie.id,
        'title': movie.title,
        'overview': movie.overview,
        'poster_url': movie.posterUrl,
        'release_year': movie.releaseYear,
        'rating': movie.rating,
        'genre': movie.genre,
      };

  static int? _toInt(Object? value) => switch (value) {
        final int v => v,
        final double v => v.toInt(),
        final String v => int.tryParse(v),
        _ => null,
      };

  static double? _toDouble(Object? value) => switch (value) {
        final double v => v,
        final int v => v.toDouble(),
        final String v => double.tryParse(v),
        _ => null,
      };
}
