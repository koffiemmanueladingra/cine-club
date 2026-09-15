import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/network/network_info.dart';
import 'core/settings/locale_controller.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/favorites/domain/repositories/favorite_repository.dart';
import 'features/favorites/presentation/controllers/favorites_controller.dart';
import 'features/movies/domain/repositories/movie_repository.dart';
import 'features/movies/presentation/controllers/movies_controller.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/profile/presentation/controllers/profile_controller.dart';

/// Arbre de providers de l'application.
///
/// Séparé de `bootstrap()` volontairement. `bootstrap()` fait des choses
/// qu'un test ne peut pas faire : ouvrir Hive, lire le trousseau système via
/// `flutter_secure_storage`, interroger `connectivity_plus`. Ces trois-là
/// dépendent de canaux de plateforme absents du `flutter_tester`.
///
/// En isolant l'arbre, les tests d'intégration branchent des implémentations
/// en mémoire des mêmes interfaces et exercent **le vrai code d'interface**,
/// sans toucher au réseau ni au disque.
class CineClubProviders extends StatelessWidget {
  const CineClubProviders({
    super.key,
    required this.authRepository,
    required this.movieRepository,
    required this.favoriteRepository,
    required this.profileRepository,
    required this.networkInfo,
    required this.authController,
    this.localeController,
    this.child = const CineClubApp(),
  });

  final AuthRepository authRepository;
  final MovieRepository movieRepository;
  final FavoriteRepository favoriteRepository;
  final ProfileRepository profileRepository;
  final NetworkInfo networkInfo;

  /// Fourni déjà construit : `bootstrap()` doit pouvoir appeler
  /// `authController.bootstrap()` (restauration de session) **avant** le
  /// premier `build`, sinon l'écran de connexion clignote au démarrage.
  final AuthController authController;

  final LocaleController? localeController;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<NetworkInfo>.value(value: networkInfo),
        Provider<MovieRepository>.value(value: movieRepository),
        Provider<FavoriteRepository>.value(value: favoriteRepository),
        Provider<ProfileRepository>.value(value: profileRepository),
        Provider<AuthRepository>.value(value: authRepository),
        ChangeNotifierProvider<LocaleController>(
          create: (_) => localeController ?? LocaleController(),
        ),
        ChangeNotifierProvider<AuthController>.value(value: authController),
        ChangeNotifierProvider<MoviesController>(
          create: (_) => MoviesController(movieRepository),
        ),
        ChangeNotifierProvider<FavoritesController>(
          create: (_) => FavoritesController(favoriteRepository),
        ),
        ChangeNotifierProvider<ProfileController>(
          create: (_) => ProfileController(profileRepository),
        ),
      ],
      child: child,
    );
  }
}
