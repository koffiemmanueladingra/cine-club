import 'package:cine_club/app_providers.dart';
import 'package:cine_club/core/settings/locale_controller.dart';
import 'package:cine_club/features/auth/domain/entities/app_user.dart';
import 'package:cine_club/features/auth/presentation/controllers/auth_controller.dart';
import 'package:cine_club/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';

/// Jeu de dépendances factices monté autour de l'application réelle.
///
/// `pumpApp` construit le **vrai** `CineClubApp` : routes, thème, délégués de
/// localisation, contrôleurs. Seules les quatre interfaces de `domain/` sont
/// remplacées. Un test qui passe ici prouve donc quelque chose sur le code de
/// production, pas sur une maquette.
class AppHarness {
  AppHarness({bool signedIn = true, Locale? locale}) {
    auth = FakeAuthRepository();
    if (signedIn) {
      auth.user = const AppUser(
        id: 'u-1',
        email: 'ada@example.com',
        displayName: 'Ada',
      );
    }
    movies = FakeMovieRepository();
    favorites = FakeFavoriteRepository(catalogue: movies.movies);
    profile = FakeProfileRepository();
    network = FakeNetworkInfo();
    localeController = LocaleController(locale);
  }

  late final FakeAuthRepository auth;
  late final FakeMovieRepository movies;
  late final FakeFavoriteRepository favorites;
  late final FakeProfileRepository profile;
  late final FakeNetworkInfo network;
  late final LocaleController localeController;

  late AuthController authController;

  Future<void> pumpApp(WidgetTester tester) async {
    authController = AuthController(auth);
    await authController.bootstrap();

    await tester.pumpWidget(
      CineClubProviders(
        authRepository: auth,
        movieRepository: movies,
        favoriteRepository: favorites,
        profileRepository: profile,
        networkInfo: network,
        authController: authController,
        localeController: localeController,
      ),
    );

    // Deux passes : la première monte l'arbre, la seconde laisse les
    // `addPostFrameCallback` de `HomeShell` déclencher les chargements.
    await tester.pumpAndSettle();
  }

  void dispose() {
    auth.dispose();
    network.dispose();
  }
}

/// Monte un widget isolé avec les délégués de localisation et un thème.
///
/// Sans `localizationsDelegates`, tout appel à `AppLocalizations.of(context)`
/// lance une exception : c'est l'erreur la plus fréquente en test de widget
/// sur une application traduite.
Future<void> pumpLocalized(
  WidgetTester tester,
  Widget child, {
  Locale locale = const Locale('fr'),
}) async {
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    ),
  );
}

/// Récupère les traductions pour une locale, hors arbre de widgets.
AppLocalizations l10nFor(String languageCode) =>
    lookupAppLocalizations(Locale(languageCode));
