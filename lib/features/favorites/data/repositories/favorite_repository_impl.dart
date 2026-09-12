import '../../../../core/error/cached.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/favorite_movie.dart';
import '../../domain/repositories/favorite_repository.dart';
import '../datasources/favorite_local_data_source.dart';
import '../datasources/favorite_remote_data_source.dart';
import '../models/favorite_dto.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  FavoriteRepositoryImpl({
    required FavoriteRemoteDataSource remote,
    required FavoriteLocalDataSource local,
    required NetworkInfo networkInfo,
    ErrorMapper mapper = const ErrorMapper(),
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo,
        _mapper = mapper;

  final FavoriteRemoteDataSource _remote;
  final FavoriteLocalDataSource _local;
  final NetworkInfo _networkInfo;
  final ErrorMapper _mapper;

  static const String _offlineWriteMessage =
      'Action indisponible hors ligne. Reconnectez-vous à Internet.';

  @override
  Future<Result<Cached<List<FavoriteMovie>>>> getFavorites({
    required String userId,
  }) async {
    if (!await _networkInfo.isConnected) {
      final rows = _safeRead(userId);
      if (rows.isEmpty) {
        return const Err<Cached<List<FavoriteMovie>>>(
          EmptyCacheFailure(
            'Vous êtes hors ligne et vos favoris ne sont pas encore enregistrés.',
          ),
        );
      }
      return Ok(Cached(
        FavoriteDto.fromRows(rows),
        fromCache: true,
        syncedAt: _local.lastSyncAt(userId),
      ));
    }

    try {
      final rows = await _remote.fetchFavorites();
      await _local.writeFavorites(userId, rows);
      return Ok(Cached(
        FavoriteDto.fromRows(rows),
        fromCache: false,
        syncedAt: _local.lastSyncAt(userId),
      ));
    } on UnauthorizedException catch (e) {
      return Err(AuthFailure(e.message, cause: e));
    } catch (e) {
      final rows = _safeRead(userId);
      if (rows.isNotEmpty) {
        return Ok(Cached(
          FavoriteDto.fromRows(rows),
          fromCache: true,
          syncedAt: _local.lastSyncAt(userId),
        ));
      }
      return Err(_mapper.fromException(e));
    }
  }

  @override
  Future<Result<void>> addFavorite({
    required String userId,
    required String movieId,
  }) =>
      _mutate(() => _remote.addFavorite(movieId), userId);

  @override
  Future<Result<void>> removeFavorite({
    required String userId,
    required String movieId,
  }) =>
      _mutate(() => _remote.removeFavorite(movieId), userId);

  Future<Result<void>> _mutate(
    Future<void> Function() action,
    String userId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Err<void>(NetworkFailure(_offlineWriteMessage));
    }
    try {
      await action();
      try {
        final rows = await _remote.fetchFavorites();
        await _local.writeFavorites(userId, rows);
      } catch (_) {}
      return const Ok<void>(null);
    } on UnauthorizedException catch (e) {
      return Err<void>(AuthFailure(e.message, cause: e));
    } catch (e) {
      return Err<void>(_mapper.fromException(e));
    }
  }

  List<Map<String, dynamic>> _safeRead(String userId) {
    try {
      return _local.readFavorites(userId);
    } on CacheException {
      return const [];
    }
  }
}
