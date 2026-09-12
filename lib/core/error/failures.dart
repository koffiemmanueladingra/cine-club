sealed class Failure {
  const Failure(this.message, {this.cause});

  final String message;

  final Object? cause;

  @override
  String toString() => '$runtimeType(message: $message, cause: $cause)';
}

final class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.cause});
}

final class ServerFailure extends Failure {
  const ServerFailure(super.message, {this.statusCode, super.cause});
  final int? statusCode;
}

final class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.cause});
}

final class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.cause});
}

final class EmptyCacheFailure extends Failure {
  const EmptyCacheFailure(super.message, {super.cause});
}

final class UnknownFailure extends Failure {
  const UnknownFailure(super.message, {super.cause});
}
