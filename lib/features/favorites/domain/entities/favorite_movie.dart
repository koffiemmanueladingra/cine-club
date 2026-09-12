import '../../../movies/domain/entities/movie.dart';

class FavoriteMovie {
  const FavoriteMovie({
    required this.favoriteId,
    required this.movie,
    required this.addedAt,
  });

  final String favoriteId;

  final Movie movie;
  final DateTime addedAt;
}
