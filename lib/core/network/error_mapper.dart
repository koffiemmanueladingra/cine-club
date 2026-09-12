import 'package:dio/dio.dart';

import '../error/exceptions.dart';
import '../error/failures.dart';

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
          cause: e,
        );

      case DioExceptionType.connectionError:
        return NetworkFailure(
          'Impossible de joindre le serveur. Vérifiez votre connexion Internet.',
          cause: e,
        );

      case DioExceptionType.badCertificate:
        return NetworkFailure(
          'Connexion non sécurisée : certificat du serveur invalide.',
          cause: e,
        );

      case DioExceptionType.cancel:
        return UnknownFailure('Requête annulée.', cause: e);

      case DioExceptionType.badResponse:
        return _fromResponse(e);

      case DioExceptionType.unknown:
        return UnknownFailure(
          'Une erreur inattendue est survenue. Réessayez.',
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
        cause: e,
      );
    }
    if (status == 404) {
      return ServerFailure(
        'Ressource introuvable.',
        statusCode: 404,
        cause: e,
      );
    }
    if (status == 409) {
      return ServerFailure(
        serverMessage ?? 'Cet élément existe déjà.',
        statusCode: 409,
        cause: e,
      );
    }
    if (status == 429) {
      return ServerFailure(
        'Trop de requêtes envoyées. Patientez quelques instants.',
        statusCode: 429,
        cause: e,
      );
    }
    if (status >= 500) {
      return ServerFailure(
        'Le service est momentanément indisponible.',
        statusCode: status,
        cause: e,
      );
    }
    return ServerFailure(
      serverMessage ?? 'La requête a été refusée (code $status).',
      statusCode: status,
      cause: e,
    );
  }

  Failure fromException(Object error) {
    if (error is DioException) return fromDio(error);
    if (error is UnauthorizedException) {
      return AuthFailure(error.message, cause: error);
    }
    if (error is NetworkException) {
      return NetworkFailure(error.message, cause: error);
    }
    if (error is CacheException) {
      return CacheFailure(error.message, cause: error);
    }
    if (error is ServerException) {
      return ServerFailure(error.message,
          statusCode: error.statusCode, cause: error);
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
