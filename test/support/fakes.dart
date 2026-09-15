import 'dart:async';

import 'package:cine_club/core/error/cached.dart';
import 'package:cine_club/core/error/failures.dart';
import 'package:cine_club/core/error/result.dart';
import 'package:cine_club/core/network/network_info.dart';
import 'package:cine_club/features/auth/domain/entities/app_user.dart';
import 'package:cine_club/features/auth/domain/repositories/auth_repository.dart';
import 'package:cine_club/features/favorites/domain/entities/favorite_movie.dart';
import 'package:cine_club/features/favorites/domain/repositories/favorite_repository.dart';
import 'package:cine_club/features/movies/domain/entities/movie.dart';
import 'package:cine_club/features/movies/domain/repositories/movie_repository.dart';
import 'package:cine_club/features/profile/domain/entities/user_profile.dart';
import 'package:cine_club/features/profile/domain/repositories/profile_repository.dart';

/// Doubles de test en mémoire.
///
/// Choix assumé : des *fakes* (implémentations réelles mais simplifiées)
/// plutôt que des mocks pour les tests de widgets et d'intégration. Un mock
/// vérifie qu'un appel a eu lieu ; un fake permet de vérifier que
/// l'interface réagit correctement à un vrai changement d'état — c'est ce
/// qu'on veut tester ici. Les mocks `mocktail` restent utilisés dans les
/// tests unitaires de repositories, où l'on veut justement contrôler les
/// appels un par un.

Movie movie({
  String id = 'm-1',
  String title = 'Metropolis',
  String overview = 'Une métropole futuriste divisée.',
  String? posterUrl,
  int? releaseYear = 1927,
  double? rating = 8.3,
  String? genre = 'Science-fiction',
}) =>
    Movie(
      id: id,
      title: title,
      overview: overview,
      posterUrl: posterUrl,
      releaseYear: releaseYear,
      rating: rating,
      genre: genre,
    );

class FakeNetworkInfo implements NetworkInfo {
  FakeNetworkInfo({this.connected = true});

  bool connected;
  final _controller = StreamController<bool>.broadcast();

  @override
  Future<bool> get isConnected async => connected;

  @override
  Stream<bool> get onStatusChange => _controller.stream;

  void emit(bool value) {
    connected = value;
    _controller.add(value);
  }

  void dispose() => _controller.close();
}

class FakeMovieRepository implements MovieRepository {
  FakeMovieRepository({
    List<Movie>? movies,
    this.failure,
    this.fromCache = false,
  }) : movies = movies ?? [movie()];

  List<Movie> movies;
  Failure? failure;
  bool fromCache;
  DateTime? syncedAt;

  int getMoviesCalls = 0;

  @override
  Future<Result<Cached<List<Movie>>>> getMovies({
    bool forceRefresh = false,
  }) async {
    getMoviesCalls++;
    final error = failure;
    if (error != null) return Err(error);
    return Ok(Cached(movies, fromCache: fromCache, syncedAt: syncedAt));
  }

  @override
  Future<Result<Cached<Movie>>> getMovieById(String id) async {
    final error = failure;
    if (error != null) return Err(error);
    final found = movies.where((m) => m.id == id);
    if (found.isEmpty) {
      return const Err(
        ServerFailure(
          'Film introuvable.',
          statusCode: 404,
          code: FailureCode.movieNotFound,
        ),
      );
    }
    return Ok(Cached(found.first, fromCache: fromCache, syncedAt: syncedAt));
  }
}

class FakeFavoriteRepository implements FavoriteRepository {
  FakeFavoriteRepository({List<Movie>? catalogue})
      : catalogue = catalogue ?? [movie()];

  /// Sert à retrouver un [Movie] complet à partir d'un identifiant, comme le
  /// ferait la jointure PostgREST du vrai dépôt.
  final List<Movie> catalogue;

  final Set<String> favorites = <String>{};
  Failure? writeFailure;

  @override
  Future<Result<Cached<List<FavoriteMovie>>>> getFavorites({
    required String userId,
  }) async {
    final list = [
      for (final id in favorites)
        FavoriteMovie(
          favoriteId: 'fav-$id',
          movie: catalogue.firstWhere(
            (m) => m.id == id,
            orElse: () => movie(id: id, title: id),
          ),
          addedAt: DateTime.utc(2026),
        ),
    ];
    return Ok(Cached(list));
  }

  @override
  Future<Result<void>> addFavorite({
    required String userId,
    required String movieId,
  }) async {
    final error = writeFailure;
    if (error != null) return Err<void>(error);
    favorites.add(movieId);
    return const Ok<void>(null);
  }

  @override
  Future<Result<void>> removeFavorite({
    required String userId,
    required String movieId,
  }) async {
    final error = writeFailure;
    if (error != null) return Err<void>(error);
    favorites.remove(movieId);
    return const Ok<void>(null);
  }
}

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({UserProfile? profile})
      : profile = profile ?? const UserProfile(id: 'u-1', displayName: 'Ada');

  UserProfile profile;
  Failure? failure;

  @override
  Future<Result<Cached<UserProfile>>> getProfile(String userId) async {
    final error = failure;
    if (error != null) return Err(error);
    return Ok(Cached(profile));
  }

  @override
  Future<Result<UserProfile>> updateDisplayName({
    required String userId,
    required String displayName,
  }) async {
    final error = failure;
    if (error != null) return Err(error);
    profile = profile.copyWith(displayName: displayName);
    return Ok(profile);
  }
}

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.user, this.loginFailure});

  AppUser? user;
  Failure? loginFailure;

  /// Quand `true`, `register` simule le cas « e-mail à confirmer » : compte
  /// créé mais aucune session ouverte.
  bool requiresEmailConfirmation = false;

  final _controller = StreamController<AppUser?>.broadcast();

  @override
  AppUser? get currentUser => user;

  @override
  Stream<AppUser?> get authStateChanges => _controller.stream;

  @override
  Future<AppUser?> restoreSession() async => user;

  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async {
    final error = loginFailure;
    if (error != null) return Err(error);
    user = AppUser(id: 'u-1', email: email, displayName: 'Ada');
    _controller.add(user);
    return Ok(user!);
  }

  @override
  Future<Result<RegisterOutcome>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final error = loginFailure;
    if (error != null) return Err(error);
    if (requiresEmailConfirmation) {
      return const Ok(RegisterOutcome(user: null, sessionOpened: false));
    }
    user = AppUser(id: 'u-1', email: email, displayName: displayName);
    _controller.add(user);
    return Ok(RegisterOutcome(user: user, sessionOpened: true));
  }

  @override
  Future<Result<void>> logout() async {
    user = null;
    _controller.add(null);
    return const Ok<void>(null);
  }

  /// Simule un refresh token expiré côté serveur.
  void expireSession() => _controller.add(null);

  void dispose() => _controller.close();
}
