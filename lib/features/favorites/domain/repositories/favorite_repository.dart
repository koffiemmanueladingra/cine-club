import '../../../../core/error/cached.dart';
import '../../../../core/error/result.dart';
import '../entities/favorite_movie.dart';

abstract interface class FavoriteRepository {
  Future<Result<Cached<List<FavoriteMovie>>>> getFavorites({
    required String userId,
  });

  Future<Result<void>> addFavorite({
    required String userId,
    required String movieId,
  });

  Future<Result<void>> removeFavorite({
    required String userId,
    required String movieId,
  });
}
