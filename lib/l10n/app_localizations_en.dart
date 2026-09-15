// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'CineClub';

  @override
  String get navCatalog => 'Catalog';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navProfile => 'Profile';

  @override
  String get catalogTitle => 'Catalog';

  @override
  String get searchHint => 'Search by title or genre';

  @override
  String get searchFieldSemantics => 'Search the movie catalog';

  @override
  String get emptyCatalog => 'No movie matches your search.';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading';

  @override
  String get addToFavorites => 'Add to favorites';

  @override
  String get removeFromFavorites => 'Remove from favorites';

  @override
  String posterOf(String title) {
    return 'Poster of $title';
  }

  @override
  String movieCardSemantics(String title, String details) {
    return '$title, $details. Double tap to open the details.';
  }

  @override
  String get movieDetailTitle => 'Details';

  @override
  String ratingOutOfTen(String rating) {
    return 'rated $rating out of 10';
  }

  @override
  String get favoritesTitle => 'My favorites';

  @override
  String get emptyFavorites => 'No favorites yet.';

  @override
  String get profileTitle => 'Profile';

  @override
  String get displayNameLabel => 'Display name';

  @override
  String get emailLabel => 'Email address';

  @override
  String get userIdLabel => 'User ID';

  @override
  String get editDisplayNameTitle => 'Display name';

  @override
  String avatarOf(String name) {
    return 'Avatar of $name';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get signOut => 'Sign out';

  @override
  String get languageLabel => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageFrench => 'Français';

  @override
  String get languageEnglish => 'English';

  @override
  String get loginSubtitle => 'Sign in to browse the catalog.';

  @override
  String get passwordLabel => 'Password';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccountLink => 'Create an account';

  @override
  String get emailRequired => 'Enter your email address.';

  @override
  String get emailInvalid => 'Invalid email address.';

  @override
  String get passwordRequired => 'Enter your password.';

  @override
  String get registerTitle => 'Create an account';

  @override
  String get submitRegister => 'Create my account';

  @override
  String displayNameTooShort(String min) {
    return 'At least $min characters.';
  }

  @override
  String passwordTooShort(String min) {
    return 'At least $min characters.';
  }

  @override
  String get registerConfirmEmail =>
      'Account created. Confirm your email address, then sign in.';

  @override
  String get sessionExpired =>
      'Your session has expired. Please sign in again.';

  @override
  String get offlineNoDate => 'Offline — showing data stored on this device.';

  @override
  String offlineSince(String date) {
    return 'Offline — data from $date.';
  }

  @override
  String get errorTimeout =>
      'The server is taking too long to answer. Try again later.';

  @override
  String get errorConnection =>
      'Cannot reach the server. Check your internet connection.';

  @override
  String get errorCertificate =>
      'Insecure connection: the server certificate is invalid.';

  @override
  String get errorCancelled => 'Request cancelled.';

  @override
  String get errorUnexpected => 'Something went wrong. Try again.';

  @override
  String get errorSessionExpired => 'Session expired. Please sign in again.';

  @override
  String get errorNotFound => 'Resource not found.';

  @override
  String get errorAlreadyExists => 'This item already exists.';

  @override
  String get errorTooManyRequests => 'Too many requests. Wait a moment.';

  @override
  String get errorServerUnavailable =>
      'The service is temporarily unavailable.';

  @override
  String errorRequestRejected(String code) {
    return 'The request was rejected (code $code).';
  }

  @override
  String get errorCatalogOffline => 'No catalog stored on this device yet.';

  @override
  String get errorMovieOffline => 'This movie is not available offline.';

  @override
  String get errorMovieNotFound => 'Movie not found.';

  @override
  String get errorFavoritesOffline => 'No favorites stored on this device yet.';

  @override
  String get errorProfileOffline => 'Profile unavailable offline.';

  @override
  String get errorProfileNotFound => 'Profile not found.';

  @override
  String get errorWriteOffline =>
      'This change requires an internet connection.';

  @override
  String get errorCacheCorrupted => 'Local data is unreadable and was ignored.';
}
