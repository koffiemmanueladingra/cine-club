enum FailureCode {
  timeout,
  connection,
  certificate,
  cancelled,
  sessionExpired,
  notFound,
  alreadyExists,
  tooManyRequests,
  serverUnavailable,
  requestRejected,
  catalogOffline,
  movieOffline,
  movieNotFound,
  favoritesOffline,
  profileOffline,
  profileNotFound,
  writeOffline,
  cacheCorrupted,
  serverMessage,
  unknown,
}

sealed class Failure {
  const Failure(
    this.message, {
    this.code = FailureCode.unknown,
    this.detail,
    this.cause,
  });

  final String message;

  final FailureCode code;

  final String? detail;

  final Object? cause;

  @override
  String toString() =>
      '$runtimeType(code: $code, message: $message, cause: $cause)';
}

final class NetworkFailure extends Failure {
  const NetworkFailure(
    super.message, {
    super.code,
    super.detail,
    super.cause,
  });
}

final class ServerFailure extends Failure {
  const ServerFailure(
    super.message, {
    this.statusCode,
    super.code,
    super.detail,
    super.cause,
  });

  final int? statusCode;
}

final class AuthFailure extends Failure {
  const AuthFailure(
    super.message, {
    super.code,
    super.detail,
    super.cause,
  });
}

final class CacheFailure extends Failure {
  const CacheFailure(
    super.message, {
    super.code,
    super.detail,
    super.cause,
  });
}

final class EmptyCacheFailure extends Failure {
  const EmptyCacheFailure(
    super.message, {
    super.code,
    super.detail,
    super.cause,
  });
}

final class UnknownFailure extends Failure {
  const UnknownFailure(
    super.message, {
    super.code,
    super.detail,
    super.cause,
  });
}
