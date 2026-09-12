import '../../../../core/error/cached.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_local_data_source.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/profile_dto.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remote,
    required ProfileLocalDataSource local,
    required NetworkInfo networkInfo,
    ErrorMapper mapper = const ErrorMapper(),
  })  : _remote = remote,
        _local = local,
        _networkInfo = networkInfo,
        _mapper = mapper;

  final ProfileRemoteDataSource _remote;
  final ProfileLocalDataSource _local;
  final NetworkInfo _networkInfo;
  final ErrorMapper _mapper;

  @override
  Future<Result<Cached<UserProfile>>> getProfile(String userId) async {
    if (!await _networkInfo.isConnected) {
      final row = _safeRead(userId);
      if (row == null) {
        return const Err<Cached<UserProfile>>(
          EmptyCacheFailure('Profil indisponible hors ligne.'),
        );
      }
      return Ok(Cached(
        ProfileDto.fromJson(row),
        fromCache: true,
        syncedAt: _local.lastSyncAt(userId),
      ));
    }

    try {
      final row = await _remote.fetchProfile(userId);
      if (row == null) {
        return const Err<Cached<UserProfile>>(
          ServerFailure('Profil introuvable.', statusCode: 404),
        );
      }
      await _local.writeProfile(userId, row);
      return Ok(Cached(
        ProfileDto.fromJson(row),
        fromCache: false,
        syncedAt: _local.lastSyncAt(userId),
      ));
    } on UnauthorizedException catch (e) {
      return Err(AuthFailure(e.message, cause: e));
    } catch (e) {
      final row = _safeRead(userId);
      if (row != null) {
        return Ok(Cached(
          ProfileDto.fromJson(row),
          fromCache: true,
          syncedAt: _local.lastSyncAt(userId),
        ));
      }
      return Err(_mapper.fromException(e));
    }
  }

  @override
  Future<Result<UserProfile>> updateDisplayName({
    required String userId,
    required String displayName,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const Err<UserProfile>(
        NetworkFailure('Modification impossible hors ligne.'),
      );
    }
    try {
      final row = await _remote.updateDisplayName(userId, displayName);
      await _local.writeProfile(userId, row);
      return Ok(ProfileDto.fromJson(row));
    } on UnauthorizedException catch (e) {
      return Err(AuthFailure(e.message, cause: e));
    } catch (e) {
      return Err(_mapper.fromException(e));
    }
  }

  Map<String, dynamic>? _safeRead(String userId) {
    try {
      return _local.readProfile(userId);
    } on CacheException {
      return null;
    }
  }
}
