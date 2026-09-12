library;

import 'package:dio/dio.dart';

import '../error/exceptions.dart';
import '../session/auth_session.dart';
import '../session/session_manager.dart';
import '../session/token_refresher.dart';

class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor({
    required SessionManager sessionManager,
    required TokenRefresher refresher,
    required Dio retryClient,
    required String apiKey,
  })  : _sessionManager = sessionManager,
        _refresher = refresher,
        _retryClient = retryClient,
        _apiKey = apiKey;

  final SessionManager _sessionManager;
  final TokenRefresher _refresher;

  final Dio _retryClient;

  final String _apiKey;

  static const String _retriedFlag = 'cine_club.auth.retried';

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['apikey'] = _apiKey;

    var session = _sessionManager.current;

    if (session != null && session.isExpired()) {
      final renewed = await _tryRefresh(session.refreshToken);
      if (renewed == null) {
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.badResponse,
            error: const UnauthorizedException('Session expirée.'),
            response: Response<dynamic>(
              requestOptions: options,
              statusCode: 401,
            ),
          ),
        );
      }
      session = renewed;
    }

    options.headers['Authorization'] =
        'Bearer ${session?.accessToken ?? _apiKey}';

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra[_retriedFlag] == true;

    if (status != 401 || alreadyRetried) {
      return handler.next(err);
    }

    final session = _sessionManager.current;
    if (session == null || session.refreshToken.isEmpty) {
      await _sessionManager.clear();
      return handler.next(err);
    }

    final renewed = await _tryRefresh(session.refreshToken);
    if (renewed == null) {
      return handler.next(err);
    }

    try {
      final options = err.requestOptions
        ..extra[_retriedFlag] = true
        ..headers['Authorization'] = 'Bearer ${renewed.accessToken}'
        ..headers['apikey'] = _apiKey;

      final response = await _retryClient.fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      return handler.next(retryError);
    }
  }

  Future<AuthSession?> _tryRefresh(String refreshToken) async {
    try {
      final renewed = await _refresher.refresh(refreshToken);
      await _sessionManager.save(renewed);
      return renewed;
    } catch (_) {
      await _sessionManager.clear();
      return null;
    }
  }
}
