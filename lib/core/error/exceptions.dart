class AppException implements Exception {
  const AppException(this.message, {this.statusCode, this.cause});

  final String message;
  final int? statusCode;
  final Object? cause;

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

class ServerException extends AppException {
  const ServerException(super.message, {super.statusCode, super.cause});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException(
    super.message, {
    super.cause,
    super.statusCode = 401,
  });
}

class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause});
}

class CacheException extends AppException {
  const CacheException(super.message, {super.cause});
}
