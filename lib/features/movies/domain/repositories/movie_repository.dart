import '../../../../core/error/cached.dart';
import '../../../../core/error/result.dart';
import '../entities/movie.dart';

abstract interface class MovieRepository {
  Future<Result<Cached<List<Movie>>>> getMovies({bool forceRefresh = false});

  Future<Result<Cached<Movie>>> getMovieById(String id);
}
