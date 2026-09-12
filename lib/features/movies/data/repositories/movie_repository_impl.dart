import '../../../../core/error/cached.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';
import '../datasources/movie_local_data_source.dart';
import '../datasources/movie_remote_data_source.dart';
import '../models/movie_dto.dart';

class MovieRepositoryImpl implements MovieRepository {
  MovieRepositoryImpl({
    required MovieRemoteDataSource remote,
    required MovieLocalDataSource local,
    required NetworkInfo networkInfo,
    ErrorMapper mapper = const ErrorMapper(),
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo,
        _mapper = mapper;

  final MovieRemoteDataSource _remote;
  final MovieLocalDataSource _local;
  final NetworkInfo _networkInfo;
  final ErrorMapper _mapper;

  @override
  Future<Result<Cached<List<Movie>>>> getMovies({
    bool forceRefresh = false,
  }) async {
    final isOnline = await _networkInfo.isConnected;

    if (!isOnline) {
      return _fromCache(
        emptyMessage:
            'Vous êtes hors ligne et aucun film n\'a encore été téléchargé.',
      );
    }

    try {
      final rows = await _remote.fetchMovies();
      await _local.writeMovies(rows);
      return Ok(
        Cached(
          rows.map(MovieDto.fromJson).toList(growable: false),
          fromCache: false,
          syncedAt: _local.lastSyncAt(),
        ),
      );
    } on UnauthorizedException catch (e) {
      return Err(AuthFailure(e.message, cause: e));
    } catch (e) {
      final cached = _safeReadCache();
      if (cached.isNotEmpty) {
        return Ok(
          Cached(
            cached.map(MovieDto.fromJson).toList(growable: false),
            fromCache: true,
            syncedAt: _local.lastSyncAt(),
          ),
        );
      }
      return Err(_mapper.fromException(e));
    }
  }

  @override
  Future<Result<Cached<Movie>>> getMovieById(String id) async {
    final cachedRow = _safeReadCache().where((row) => row['id'] == id);
    if (cachedRow.isNotEmpty) {
      return Ok(
        Cached(
          MovieDto.fromJson(cachedRow.first),
          fromCache: true,
          syncedAt: _local.lastSyncAt(),
        ),
      );
    }

    if (!await _networkInfo.isConnected) {
      return const Err<Cached<Movie>>(
        EmptyCacheFailure('Ce film n\'est pas disponible hors ligne.'),
      );
    }

    try {
      final row = await _remote.fetchMovieById(id);
      if (row == null) {
        return const Err<Cached<Movie>>(
          ServerFailure('Film introuvable.', statusCode: 404),
        );
      }
      return Ok(Cached(MovieDto.fromJson(row), fromCache: false));
    } catch (e) {
      return Err(_mapper.fromException(e));
    }
  }

  Result<Cached<List<Movie>>> _fromCache({required String emptyMessage}) {
    final rows = _safeReadCache();
    if (rows.isEmpty) return Err(EmptyCacheFailure(emptyMessage));
    return Ok(
      Cached(
        rows.map(MovieDto.fromJson).toList(growable: false),
        fromCache: true,
        syncedAt: _local.lastSyncAt(),
      ),
    );
  }

  List<Map<String, dynamic>> _safeReadCache() {
    try {
      return _local.readMovies();
    } on CacheException {
      return const [];
    }
  }
}
