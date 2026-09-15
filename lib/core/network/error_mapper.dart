import 'package:dio/dio.dart';

import '../error/exceptions.dart';
import '../error/failures.dart';

/// Traduit une erreur technique en [Failure] présentable.
///
/// Chaque échec porte deux choses :
/// - `message` : texte français, conservé pour les journaux et les tests ;
/// - `code` : identifiant stable utilisé par l'interface pour afficher la
///   version traduite (voir `core/l10n/failure_l10n.dart`).
///
/// Quand le backend renvoie lui-même un message exploitable, le code devient
/// [FailureCode.serverMessage] : ce texte est affiché tel quel, puisqu'on ne
/// peut pas le traduire.
class ErrorMapper {
  const ErrorMapper();

  Failure fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return NetworkFailure(
          'Le serveur met trop de temps à répondre. Réessayez plus tard.',
          code: FailureCode.timeout,
          cause: e,
        );

      case DioExceptionType.connectionError:
        return NetworkFailure(
          'Impossible de joindre le serveur. Vérifiez votre connexion Internet.',
          code: FailureCode.connection,
          cause: e,
        );

      case DioExceptionType.badCertificate:
        return NetworkFailure(
          'Connexion non sécurisée : certificat du serveur invalide.',
          code: FailureCode.certificate,
          cause: e,
        );

      case DioExceptionType.cancel:
        return UnknownFailure(
          'Requête annulée.',
          code: FailureCode.cancelled,
          cause: e,
        );

      case DioExceptionType.badResponse:
        return _fromResponse(e);

      case DioExceptionType.unknown:
        return UnknownFailure(
          'Une erreur inattendue est survenue. Réessayez.',
          code: FailureCode.unknown,
          cause: e,
        );
    }
  }

  Failure _fromResponse(DioException e) {
    final status = e.response?.statusCode ?? 0;
    final serverMessage = extractServerMessage(e.response?.data);

    if (status == 401 || status == 403) {
      return AuthFailure(
        serverMessage ?? 'Session expirée. Veuillez vous reconnecter.',
        code: serverMessage == null
            ? FailureCode.sessionExpired
            : FailureCode.serverMessage,
        cause: e,
      );
    }
    if (status == 404) {
      return ServerFailure(
        'Ressource introuvable.',
        statusCode: 404,
        code: FailureCode.notFound,
        cause: e,
      );
    }
    if (status == 409) {
      return ServerFailure(
        serverMessage ?? 'Cet élément existe déjà.',
        statusCode: 409,
        code: serverMessage == null
            ? FailureCode.alreadyExists
            : FailureCode.serverMessage,
        cause: e,
      );
    }
    if (status == 429) {
      return ServerFailure(
        'Trop de requêtes envoyées. Patientez quelques instants.',
        statusCode: 429,
        code: FailureCode.tooManyRequests,
        cause: e,
      );
    }
    if (status >= 500) {
      // Le détail d'un 5xx n'est jamais montré : il peut contenir une trace.
      return ServerFailure(
        'Le service est momentanément indisponible.',
        statusCode: status,
        code: FailureCode.serverUnavailable,
        cause: e,
      );
    }
    return ServerFailure(
      serverMessage ?? 'La requête a été refusée (code $status).',
      statusCode: status,
      code: serverMessage == null
          ? FailureCode.requestRejected
          : FailureCode.serverMessage,
      detail: '$status',
      cause: e,
    );
  }

  Failure fromException(Object error) {
    if (error is DioException) return fromDio(error);
    if (error is UnauthorizedException) {
      return AuthFailure(
        error.message,
        code: FailureCode.serverMessage,
        cause: error,
      );
    }
    if (error is NetworkException) {
      return NetworkFailure(
        error.message,
        code: FailureCode.connection,
        cause: error,
      );
    }
    if (error is CacheException) {
      return CacheFailure(
        error.message,
        code: FailureCode.cacheCorrupted,
        cause: error,
      );
    }
    if (error is ServerException) {
      return ServerFailure(
        error.message,
        statusCode: error.statusCode,
        code: FailureCode.serverMessage,
        cause: error,
      );
    }
    return UnknownFailure('Erreur inattendue : $error', cause: error);
  }

  static String? extractServerMessage(Object? data) {
    if (data is Map) {
      for (final key in ['msg', 'message', 'error_description', 'error']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) return value;
      }
    }
    if (data is String && data.trim().isNotEmpty && data.length < 200) {
      return data;
    }
    return null;
  }
}
