/// Identifiant stable d'un échec, indépendant de la langue.
///
/// `Failure.message` reste une chaîne lisible en français, utilisée comme
/// repli dans les journaux et les tests. L'interface, elle, traduit à partir
/// de ce code (voir `lib/core/l10n/failure_l10n.dart`) : un même échec doit
/// s'afficher en français ou en anglais selon la locale active.
///
/// `serverMessage` est le seul code qui fait exception : il signale que
/// `message` contient un texte renvoyé par le backend (Supabase / PostgREST),
/// que l'application n'a aucun moyen de traduire.
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

  /// Message lisible en français. Repli si le code n'est pas traduisible.
  final String message;

  /// Code stable utilisé pour retrouver la traduction.
  final FailureCode code;

  /// Donnée d'appoint interpolée dans certains messages (ex. code HTTP).
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
