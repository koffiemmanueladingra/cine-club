import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/error_mapper.dart';

abstract interface class ProfileRemoteDataSource {
  Future<Map<String, dynamic>?> fetchProfile(String userId);
  Future<Map<String, dynamic>> updateDisplayName(
    String userId,
    String displayName,
  );
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._dio);

  final Dio _dio;
  static const String _path = '/profiles';

  @override
  Future<Map<String, dynamic>?> fetchProfile(String userId) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        _path,
        queryParameters: {'select': '*', 'id': 'eq.$userId', 'limit': 1},
      );
      final rows = (response.data ?? const []).cast<Map<String, dynamic>>();
      return rows.isEmpty ? null : rows.first;
    } on DioException catch (e) {
      throw _toException(e, 'Chargement du profil impossible.');
    }
  }

  @override
  Future<Map<String, dynamic>> updateDisplayName(
    String userId,
    String displayName,
  ) async {
    try {
      final response = await _dio.patch<List<dynamic>>(
        _path,
        queryParameters: {'id': 'eq.$userId'},
        data: {
          'display_name': displayName,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        },
        options: Options(headers: {'Prefer': 'return=representation'}),
      );
      final rows = (response.data ?? const []).cast<Map<String, dynamic>>();
      if (rows.isEmpty) {
        throw const ServerException('Le profil n\'a pas pu être mis à jour.');
      }
      return rows.first;
    } on DioException catch (e) {
      throw _toException(e, 'Mise à jour du profil impossible.');
    }
  }

  AppException _toException(DioException e, String fallback) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException('Serveur injoignable.', cause: e);
    }
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) {
      return UnauthorizedException(
        ErrorMapper.extractServerMessage(e.response?.data) ?? 'Accès refusé.',
        cause: e,
      );
    }
    return ServerException(
      ErrorMapper.extractServerMessage(e.response?.data) ?? fallback,
      statusCode: status,
      cause: e,
    );
  }
}
