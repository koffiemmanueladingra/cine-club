import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr')
  ];

  /// Application name, shown in the task switcher and on the login screen.
  ///
  /// In en, this message translates to:
  /// **'CineClub'**
  String get appTitle;

  /// Bottom navigation label for the movie catalog tab.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get navCatalog;

  /// Bottom navigation label for the favorites tab.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get navFavorites;

  /// Bottom navigation label for the profile tab.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// App bar title of the movie catalog screen.
  ///
  /// In en, this message translates to:
  /// **'Catalog'**
  String get catalogTitle;

  /// Placeholder of the catalog search field.
  ///
  /// In en, this message translates to:
  /// **'Search by title or genre'**
  String get searchHint;

  /// Screen reader label of the catalog search field.
  ///
  /// In en, this message translates to:
  /// **'Search the movie catalog'**
  String get searchFieldSemantics;

  /// Shown when the search filters out every movie.
  ///
  /// In en, this message translates to:
  /// **'No movie matches your search.'**
  String get emptyCatalog;

  /// Label of the button that retries a failed request.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Screen reader label of progress indicators.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// Tooltip and screen reader label of the favorite toggle when the movie is not a favorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get addToFavorites;

  /// Tooltip and screen reader label of the favorite toggle when the movie already is a favorite.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get removeFromFavorites;

  /// Screen reader label of a movie poster image.
  ///
  /// In en, this message translates to:
  /// **'Poster of {title}'**
  String posterOf(String title);

  /// Screen reader label of a whole movie card in a list.
  ///
  /// In en, this message translates to:
  /// **'{title}, {details}. Double tap to open the details.'**
  String movieCardSemantics(String title, String details);

  /// App bar title of the movie detail screen.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get movieDetailTitle;

  /// Spoken form of a movie rating, used in screen reader labels.
  ///
  /// In en, this message translates to:
  /// **'rated {rating} out of 10'**
  String ratingOutOfTen(String rating);

  /// App bar title of the favorites screen.
  ///
  /// In en, this message translates to:
  /// **'My favorites'**
  String get favoritesTitle;

  /// Shown when the favorites list is empty.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet.'**
  String get emptyFavorites;

  /// App bar title of the profile screen.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileTitle;

  /// Label of the display name field and profile row.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get displayNameLabel;

  /// Label of the email field and profile row.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailLabel;

  /// Label of the profile row showing the account identifier.
  ///
  /// In en, this message translates to:
  /// **'User ID'**
  String get userIdLabel;

  /// Title of the dialog used to rename the account.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get editDisplayNameTitle;

  /// Screen reader label of the profile avatar.
  ///
  /// In en, this message translates to:
  /// **'Avatar of {name}'**
  String avatarOf(String name);

  /// Dismisses a dialog without saving.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Confirms a dialog and saves the change.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Label of the sign out button.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Label of the language selector in the profile screen.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageLabel;

  /// Language option that follows the device setting.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// French language option, always written in French.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get languageFrench;

  /// English language option, always written in English.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Subtitle of the login screen.
  ///
  /// In en, this message translates to:
  /// **'Sign in to browse the catalog.'**
  String get loginSubtitle;

  /// Label of the password field.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// Screen reader label of the button revealing the password.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// Screen reader label of the button masking the password.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// Label of the login submit button.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// Label of the link that opens the registration screen.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAccountLink;

  /// Validation error shown when the email field is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address.'**
  String get emailRequired;

  /// Validation error shown when the email format is wrong.
  ///
  /// In en, this message translates to:
  /// **'Invalid email address.'**
  String get emailInvalid;

  /// Validation error shown when the password field is empty.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get passwordRequired;

  /// App bar title of the registration screen.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get registerTitle;

  /// Label of the registration submit button.
  ///
  /// In en, this message translates to:
  /// **'Create my account'**
  String get submitRegister;

  /// Validation error shown when the display name is too short.
  ///
  /// In en, this message translates to:
  /// **'At least {min} characters.'**
  String displayNameTooShort(String min);

  /// Validation error shown when the password is too short.
  ///
  /// In en, this message translates to:
  /// **'At least {min} characters.'**
  String passwordTooShort(String min);

  /// Notice shown after registering when email confirmation is required.
  ///
  /// In en, this message translates to:
  /// **'Account created. Confirm your email address, then sign in.'**
  String get registerConfirmEmail;

  /// Notice shown when the refresh token could not be renewed.
  ///
  /// In en, this message translates to:
  /// **'Your session has expired. Please sign in again.'**
  String get sessionExpired;

  /// Offline banner shown when the cache has no timestamp.
  ///
  /// In en, this message translates to:
  /// **'Offline — showing data stored on this device.'**
  String get offlineNoDate;

  /// Offline banner shown when the cache timestamp is known.
  ///
  /// In en, this message translates to:
  /// **'Offline — data from {date}.'**
  String offlineSince(String date);

  /// Network failure caused by a timeout.
  ///
  /// In en, this message translates to:
  /// **'The server is taking too long to answer. Try again later.'**
  String get errorTimeout;

  /// Network failure caused by a connection error.
  ///
  /// In en, this message translates to:
  /// **'Cannot reach the server. Check your internet connection.'**
  String get errorConnection;

  /// Network failure caused by a bad TLS certificate.
  ///
  /// In en, this message translates to:
  /// **'Insecure connection: the server certificate is invalid.'**
  String get errorCertificate;

  /// Failure raised when a request is cancelled.
  ///
  /// In en, this message translates to:
  /// **'Request cancelled.'**
  String get errorCancelled;

  /// Fallback message for unclassified failures.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get errorUnexpected;

  /// Failure raised on HTTP 401 or 403 without a server message.
  ///
  /// In en, this message translates to:
  /// **'Session expired. Please sign in again.'**
  String get errorSessionExpired;

  /// Failure raised on HTTP 404.
  ///
  /// In en, this message translates to:
  /// **'Resource not found.'**
  String get errorNotFound;

  /// Failure raised on HTTP 409.
  ///
  /// In en, this message translates to:
  /// **'This item already exists.'**
  String get errorAlreadyExists;

  /// Failure raised on HTTP 429.
  ///
  /// In en, this message translates to:
  /// **'Too many requests. Wait a moment.'**
  String get errorTooManyRequests;

  /// Failure raised on HTTP 5xx.
  ///
  /// In en, this message translates to:
  /// **'The service is temporarily unavailable.'**
  String get errorServerUnavailable;

  /// Failure raised on an unmapped 4xx status code.
  ///
  /// In en, this message translates to:
  /// **'The request was rejected (code {code}).'**
  String errorRequestRejected(String code);

  /// Empty cache failure for the movie list.
  ///
  /// In en, this message translates to:
  /// **'No catalog stored on this device yet.'**
  String get errorCatalogOffline;

  /// Empty cache failure for a single movie.
  ///
  /// In en, this message translates to:
  /// **'This movie is not available offline.'**
  String get errorMovieOffline;

  /// Server failure when a movie id does not exist.
  ///
  /// In en, this message translates to:
  /// **'Movie not found.'**
  String get errorMovieNotFound;

  /// Empty cache failure for the favorites list.
  ///
  /// In en, this message translates to:
  /// **'No favorites stored on this device yet.'**
  String get errorFavoritesOffline;

  /// Empty cache failure for the profile.
  ///
  /// In en, this message translates to:
  /// **'Profile unavailable offline.'**
  String get errorProfileOffline;

  /// Server failure when the profile row is missing.
  ///
  /// In en, this message translates to:
  /// **'Profile not found.'**
  String get errorProfileNotFound;

  /// Failure raised when a write is attempted while offline.
  ///
  /// In en, this message translates to:
  /// **'This change requires an internet connection.'**
  String get errorWriteOffline;

  /// Failure raised when the Hive cache cannot be decoded.
  ///
  /// In en, this message translates to:
  /// **'Local data is unreadable and was ignored.'**
  String get errorCacheCorrupted;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
