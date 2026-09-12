import 'package:dio/dio.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/session/auth_session.dart';
import '../../../../core/session/token_refresher.dart';
import '../models/session_dto.dart';

abstract interface class AuthRemoteDataSource implements TokenRefresher {
  Future<SessionDto> signIn({required String email, required String password});

  Future<SessionDto?> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  Future<void> signOut(String accessToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<SessionDto> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/token',
        queryParameters: const {'grant_type': 'password'},
        data: {'email': email, 'password': password},
      );
      return SessionDto.fromJson(response.data ?? const {});
    } on DioException catch (e) {
      throw _toException(e, fallback: 'Connexion impossible.');
    } on FormatException catch (e) {
      throw ServerException('Réponse inattendue du serveur.', cause: e);
    }
  }

  @override
  Future<SessionDto?> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/signup',
        data: {
          'email': email,
          'password': password,
          'data': {'display_name': displayName},
        },
      );
      try {
        return SessionDto.fromJson(response.data ?? const {});
      } on FormatException {
        return null;
      }
    } on DioException catch (e) {
      throw _toException(e, fallback: 'Inscription impossible.');
    }
  }

  @override
  Future<AuthSession> refresh(String refreshToken) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/token',
        queryParameters: const {'grant_type': 'refresh_token'},
        data: {'refresh_token': refreshToken},
      );
      return SessionDto.fromJson(response.data ?? const {}).session;
    } on DioException catch (e) {
      throw UnauthorizedException(
        ErrorMapper.extractServerMessage(e.response?.data) ??
            'Session expirée.',
        cause: e,
      );
    } on FormatException catch (e) {
      throw UnauthorizedException('Session expirée.', cause: e);
    }
  }

  @override
  Future<void> signOut(String accessToken) async {
    try {
      await _dio.post<void>(
        '/logout',
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken'},
        ),
      );
    } on DioException catch (e) {
      throw _toException(e, fallback: 'Déconnexion serveur impossible.');
    }
  }

  AppException _toException(DioException e, {required String fallback}) {
    final status = e.response?.statusCode;
    final message = ErrorMapper.extractServerMessage(e.response?.data);
    if (status == 400 || status == 401 || status == 422) {
      return UnauthorizedException(message ?? fallback, cause: e);
    }
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return NetworkException(
        'Impossible de joindre le serveur. Vérifiez votre connexion.',
        cause: e,
      );
    }
    return ServerException(message ?? fallback,
        statusCode: status, cause: e);
  }
}
