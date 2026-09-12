import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/error_mapper.dart';

abstract interface class MovieRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchMovies();
  Future<Map<String, dynamic>?> fetchMovieById(String id);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  MovieRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  static const String _path = '/movies';

  @override
  Future<List<Map<String, dynamic>>> fetchMovies() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        _path,
        queryParameters: const {
          'select': '*',
          'order': 'release_year.desc',
        },
      );
      return (response.data ?? const []).cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  @override
  Future<Map<String, dynamic>?> fetchMovieById(String id) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        _path,
        queryParameters: {'select': '*', 'id': 'eq.$id', 'limit': 1},
      );
      final rows = (response.data ?? const []).cast<Map<String, dynamic>>();
      return rows.isEmpty ? null : rows.first;
    } on DioException catch (e) {
      throw _toException(e);
    }
  }

  AppException _toException(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return NetworkException('Serveur injoignable.', cause: e);
    }
    final status = e.response?.statusCode;
    if (status == 401 || status == 403) {
      return UnauthorizedException(
        ErrorMapper.extractServerMessage(e.response?.data) ??
            'Accès refusé au catalogue.',
        cause: e,
      );
    }
    return ServerException(
      ErrorMapper.extractServerMessage(e.response?.data) ??
          'Chargement du catalogue impossible.',
      statusCode: status,
      cause: e,
    );
  }
}
