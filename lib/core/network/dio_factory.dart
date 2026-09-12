import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../session/session_manager.dart';
import '../session/token_refresher.dart';
import 'auth_interceptor.dart';

class DioFactory {
  const DioFactory(this._config);

  final AppConfig _config;

  static const Duration _connectTimeout = Duration(seconds: 10);
  static const Duration _receiveTimeout = Duration(seconds: 15);

  BaseOptions _baseOptions(String baseUrl) => BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: _connectTimeout,
        receiveTimeout: _receiveTimeout,
        sendTimeout: _connectTimeout,
        contentType: Headers.jsonContentType,
        responseType: ResponseType.json,
        headers: {'apikey': _config.supabaseKey},
        validateStatus: (status) => status != null && status < 400,
      );

  Dio createAuthClient() {
    final dio = Dio(_baseOptions(_config.authBaseUrl));
    _attachLogger(dio);
    return dio;
  }

  Dio createRetryClient() => Dio(_baseOptions(_config.restBaseUrl));

  Dio createApiClient({
    required SessionManager sessionManager,
    required TokenRefresher refresher,
    required Dio retryClient,
  }) {
    final dio = Dio(_baseOptions(_config.restBaseUrl));
    dio.interceptors.add(
      AuthInterceptor(
        sessionManager: sessionManager,
        refresher: refresher,
        retryClient: retryClient,
        apiKey: _config.supabaseKey,
      ),
    );
    _attachLogger(dio);
    return dio;
  }

  void _attachLogger(Dio dio) {
    if (!kDebugMode) return;
    dio.interceptors.add(
      LogInterceptor(
        request: false,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: false,
        error: true,
        logPrint: (Object o) => debugPrint('[dio] $o'),
      ),
    );
  }
}
