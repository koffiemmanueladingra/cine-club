import '../../l10n/app_localizations.dart';
import '../error/failures.dart';

/// Traduit un [Failure] dans la locale active.
///
/// Le `switch` est exhaustif sur [FailureCode] : ajouter un code sans ajouter
/// sa traduction devient une erreur de compilation, pas un texte manquant
/// découvert en production.
extension FailureL10n on Failure {
  String localizedMessage(AppLocalizations l10n) => switch (code) {
        FailureCode.timeout => l10n.errorTimeout,
        FailureCode.connection => l10n.errorConnection,
        FailureCode.certificate => l10n.errorCertificate,
        FailureCode.cancelled => l10n.errorCancelled,
        FailureCode.sessionExpired => l10n.errorSessionExpired,
        FailureCode.notFound => l10n.errorNotFound,
        FailureCode.alreadyExists => l10n.errorAlreadyExists,
        FailureCode.tooManyRequests => l10n.errorTooManyRequests,
        FailureCode.serverUnavailable => l10n.errorServerUnavailable,
        FailureCode.requestRejected =>
          l10n.errorRequestRejected(detail ?? '???'),
        FailureCode.catalogOffline => l10n.errorCatalogOffline,
        FailureCode.movieOffline => l10n.errorMovieOffline,
        FailureCode.movieNotFound => l10n.errorMovieNotFound,
        FailureCode.favoritesOffline => l10n.errorFavoritesOffline,
        FailureCode.profileOffline => l10n.errorProfileOffline,
        FailureCode.profileNotFound => l10n.errorProfileNotFound,
        FailureCode.writeOffline => l10n.errorWriteOffline,
        FailureCode.cacheCorrupted => l10n.errorCacheCorrupted,

        // Texte venu du serveur : affiché tel quel, aucune traduction possible.
        FailureCode.serverMessage => message,

        // Échec non classé : on retombe sur le message technique s'il existe,
        // sinon sur une formulation générique traduite.
        FailureCode.unknown => message.isEmpty ? l10n.errorUnexpected : message,
      };
}
