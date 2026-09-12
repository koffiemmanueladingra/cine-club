import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/error_mapper.dart';

abstract interface class FavoriteRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchFavorites();
  Future<void> addFavorite(String movieId);
  Future<void> removeFavorite(String movieId);
}

class FavoriteRemoteDataSourceImpl implements FavoriteRemoteDataSource {
  FavoriteRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static const String _path = '/favorites';

  @override
  Future<List<Map<String, dynamic>>> fetchFavorites() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        _path,
        queryParameters: const {
          'select': 'id,created_at,movie:movies(*)',
          'order': 'created_at.desc',
        },
      );
      return (response.data ?? const []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _toException(e, 'Chargement des favoris impossible.');
    }
  }

  @override
  Future<void> addFavorite(String movieId) async {
    try {
      await _dio.post<dynamic>(
        _path,
        data: {'movie_id': movieId},
        options: Options(
          headers: {
            'Prefer': 'return=minimal',
          },
        ),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return;
      }
      throw _toException(e, 'Ajout aux favoris impossible.');
    }
  }

  @override
  Future<void> removeFavorite(String movieId) async {
    try {
      await _dio.delete<dynamic>(
        _path,
        queryParameters: {'movie_id': 'eq.$movieId'},
      );
    } on DioException catch (e) {
      throw _toException(e, 'Retrait des favoris impossible.');
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
