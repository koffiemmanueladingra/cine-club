import '../../../movies/data/models/movie_dto.dart';
import '../../domain/entities/favorite_movie.dart';

class FavoriteDto {
  const FavoriteDto._();

  static FavoriteMovie fromJson(Map<String, dynamic> json) {
    final movieJson = json['movie'];
    if (movieJson is! Map<String, dynamic>) {
      throw const FormatException('Favori sans film associé.');
    }
    return FavoriteMovie(
      favoriteId: json['id'] as String,
      movie: MovieDto.fromJson(movieJson),
      addedAt:
          DateTime.tryParse(json['created_at'] as String? ?? '')?.toUtc() ??
              DateTime.now().toUtc(),
    );
  }

  static List<FavoriteMovie> fromRows(List<Map<String, dynamic>> rows) {
    final result = <FavoriteMovie>[];
    for (final row in rows) {
      try {
        result.add(fromJson(row));
      } on FormatException {
        continue;
      }
    }
    return result;
  }
}
