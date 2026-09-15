// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'CinéClub';

  @override
  String get navCatalog => 'Catalogue';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navProfile => 'Profil';

  @override
  String get catalogTitle => 'Catalogue';

  @override
  String get searchHint => 'Rechercher un titre ou un genre';

  @override
  String get searchFieldSemantics => 'Rechercher dans le catalogue';

  @override
  String get emptyCatalog => 'Aucun film ne correspond.';

  @override
  String get retry => 'Réessayer';

  @override
  String get loading => 'Chargement';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String posterOf(String title) {
    return 'Affiche de $title';
  }

  @override
  String movieCardSemantics(String title, String details) {
    return '$title, $details. Appuyez deux fois pour ouvrir la fiche.';
  }

  @override
  String get movieDetailTitle => 'Détail';

  @override
  String ratingOutOfTen(String rating) {
    return 'noté $rating sur 10';
  }

  @override
  String get favoritesTitle => 'Mes favoris';

  @override
  String get emptyFavorites => 'Aucun favori pour le moment.';

  @override
  String get profileTitle => 'Profil';

  @override
  String get displayNameLabel => 'Nom affiché';

  @override
  String get emailLabel => 'Adresse e-mail';

  @override
  String get userIdLabel => 'Identifiant';

  @override
  String get editDisplayNameTitle => 'Nom affiché';

  @override
  String avatarOf(String name) {
    return 'Avatar de $name';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get signOut => 'Se déconnecter';

  @override
  String get languageLabel => 'Langue';

  @override
  String get languageSystem => 'Système';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get loginSubtitle => 'Connectez-vous pour accéder au catalogue.';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get showPassword => 'Afficher le mot de passe';

  @override
  String get hidePassword => 'Masquer le mot de passe';

  @override
  String get signIn => 'Se connecter';

  @override
  String get createAccountLink => 'Créer un compte';

  @override
  String get emailRequired => 'Saisissez votre adresse e-mail.';

  @override
  String get emailInvalid => 'Adresse e-mail invalide.';

  @override
  String get passwordRequired => 'Saisissez votre mot de passe.';

  @override
  String get registerTitle => 'Créer un compte';

  @override
  String get submitRegister => 'Créer mon compte';

  @override
  String displayNameTooShort(String min) {
    return 'Au moins $min caractères.';
  }

  @override
  String passwordTooShort(String min) {
    return 'Au moins $min caractères.';
  }

  @override
  String get registerConfirmEmail =>
      'Compte créé. Confirmez votre adresse e-mail puis connectez-vous.';

  @override
  String get sessionExpired => 'Votre session a expiré. Reconnectez-vous.';

  @override
  String get offlineNoDate =>
      'Mode hors ligne — données enregistrées sur l\'appareil.';

  @override
  String offlineSince(String date) {
    return 'Mode hors ligne — données du $date.';
  }

  @override
  String get errorTimeout =>
      'Le serveur met trop de temps à répondre. Réessayez plus tard.';

  @override
  String get errorConnection =>
      'Impossible de joindre le serveur. Vérifiez votre connexion Internet.';

  @override
  String get errorCertificate =>
      'Connexion non sécurisée : certificat du serveur invalide.';

  @override
  String get errorCancelled => 'Requête annulée.';

  @override
  String get errorUnexpected =>
      'Une erreur inattendue est survenue. Réessayez.';

  @override
  String get errorSessionExpired =>
      'Session expirée. Veuillez vous reconnecter.';

  @override
  String get errorNotFound => 'Ressource introuvable.';

  @override
  String get errorAlreadyExists => 'Cet élément existe déjà.';

  @override
  String get errorTooManyRequests =>
      'Trop de requêtes envoyées. Patientez quelques instants.';

  @override
  String get errorServerUnavailable =>
      'Le service est momentanément indisponible.';

  @override
  String errorRequestRejected(String code) {
    return 'La requête a été refusée (code $code).';
  }

  @override
  String get errorCatalogOffline =>
      'Aucun catalogue enregistré sur cet appareil.';

  @override
  String get errorMovieOffline => 'Ce film n\'est pas disponible hors ligne.';

  @override
  String get errorMovieNotFound => 'Film introuvable.';

  @override
  String get errorFavoritesOffline =>
      'Aucun favori enregistré sur cet appareil.';

  @override
  String get errorProfileOffline => 'Profil indisponible hors ligne.';

  @override
  String get errorProfileNotFound => 'Profil introuvable.';

  @override
  String get errorWriteOffline =>
      'Cette modification nécessite une connexion Internet.';

  @override
  String get errorCacheCorrupted =>
      'Les données locales sont illisibles et ont été ignorées.';
}
