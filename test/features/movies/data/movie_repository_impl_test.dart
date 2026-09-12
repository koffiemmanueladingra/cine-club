import 'package:cine_club/core/error/exceptions.dart';
import 'package:cine_club/core/error/failures.dart';
import 'package:cine_club/core/error/result.dart';
import 'package:cine_club/core/network/network_info.dart';
import 'package:cine_club/features/movies/data/datasources/movie_local_data_source.dart';
import 'package:cine_club/features/movies/data/datasources/movie_remote_data_source.dart';
import 'package:cine_club/features/movies/data/repositories/movie_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements MovieRemoteDataSource {}

class _MockLocal extends Mock implements MovieLocalDataSource {}

class _MockNetwork extends Mock implements NetworkInfo {}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockNetwork network;
  late MovieRepositoryImpl repository;

  final syncedAt = DateTime.utc(2026, 1, 15, 10, 30);

  final remoteRows = <Map<String, dynamic>>[
    {
      'id': 'm-1',
      'title': 'Metropolis',
      'overview': 'Une métropole futuriste divisée.',
      'poster_url': null,
      'release_year': 1927,
      'rating': 8.3,
      'genre': 'Science-fiction',
    },
  ];

  final cachedRows = <Map<String, dynamic>>[
    {
      'id': 'm-cache',
      'title': 'Nosferatu',
      'overview': 'Un vampire arrive à Wisborg.',
      'poster_url': null,
      'release_year': 1922,
      'rating': '7.9',
      'genre': 'Horreur',
    },
  ];

  setUpAll(() {
    registerFallbackValue(<Map<String, dynamic>>[]);
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    network = _MockNetwork();
    repository = MovieRepositoryImpl(
      remote: remote,
      local: local,
      networkInfo: network,
    );

    when(() => local.lastSyncAt()).thenReturn(syncedAt);
    when(() => local.writeMovies(any())).thenAnswer((_) async {});
  });

  group('getMovies', () {
    test(
      'R1 — hors ligne avec cache : renvoie le cache et marque fromCache',
      () async {
        when(() => network.isConnected).thenAnswer((_) async => false);
        when(local.readMovies).thenReturn(cachedRows);

        final result = await repository.getMovies();

        expect(result, isA<Ok<dynamic>>());
        final cached = (result as Ok<dynamic>).value;
        expect(cached.fromCache, isTrue);
        expect(cached.data.single.title, 'Nosferatu');
        expect(cached.data.single.rating, 7.9);
        expect(cached.syncedAt, syncedAt);
        verifyNever(() => remote.fetchMovies());
      },
    );

    test('R2 — hors ligne sans cache : EmptyCacheFailure', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);
      when(local.readMovies).thenReturn(const []);

      final result = await repository.getMovies();

      expect(result, isA<Err<dynamic>>());
      expect((result as Err<dynamic>).failure, isA<EmptyCacheFailure>());
    });

    test('R3 — en ligne : renvoie le réseau et met le cache à jour', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(remote.fetchMovies).thenAnswer((_) async => remoteRows);

      final result = await repository.getMovies();

      expect(result, isA<Ok<dynamic>>());
      final cached = (result as Ok<dynamic>).value;
      expect(cached.fromCache, isFalse);
      expect(cached.data.single.title, 'Metropolis');
      verify(() => local.writeMovies(remoteRows)).called(1);
    });

    test('R4 — réseau actif mais requête KO : repli sur le cache', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(remote.fetchMovies)
          .thenThrow(const ServerException('500', statusCode: 500));
      when(local.readMovies).thenReturn(cachedRows);

      final result = await repository.getMovies();

      expect(result, isA<Ok<dynamic>>());
      expect((result as Ok<dynamic>).value.fromCache, isTrue);
    });

    test('R5 — requête KO et cache vide : Failure remontée', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(remote.fetchMovies)
          .thenThrow(const ServerException('Boom', statusCode: 500));
      when(local.readMovies).thenReturn(const []);

      final result = await repository.getMovies();

      expect(result, isA<Err<dynamic>>());
      expect((result as Err<dynamic>).failure, isA<ServerFailure>());
    });

    test(
      'un 401 non récupérable n\'est jamais masqué par le cache',
      () async {
        when(() => network.isConnected).thenAnswer((_) async => true);
        when(remote.fetchMovies)
            .thenThrow(const UnauthorizedException('Token invalide'));
        when(local.readMovies).thenReturn(cachedRows);

        final result = await repository.getMovies();

        expect(result, isA<Err<dynamic>>());
        expect((result as Err<dynamic>).failure, isA<AuthFailure>());
      },
    );

    test('un cache corrompu est traité comme un cache vide', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);
      when(local.readMovies).thenThrow(const CacheException('corrompu'));

      final result = await repository.getMovies();

      expect((result as Err<dynamic>).failure, isA<EmptyCacheFailure>());
    });
  });

  group('getMovieById', () {
    test('sert le détail depuis le cache sans appel réseau', () async {
      when(local.readMovies).thenReturn(cachedRows);

      final result = await repository.getMovieById('m-cache');

      expect((result as Ok<dynamic>).value.data.title, 'Nosferatu');
      verifyNever(() => remote.fetchMovieById(any()));
    });

    test('hors ligne et absent du cache : EmptyCacheFailure', () async {
      when(local.readMovies).thenReturn(const []);
      when(() => network.isConnected).thenAnswer((_) async => false);

      final result = await repository.getMovieById('inconnu');

      expect((result as Err<dynamic>).failure, isA<EmptyCacheFailure>());
    });

    test('en ligne et absent du serveur : ServerFailure 404', () async {
      when(local.readMovies).thenReturn(const []);
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(() => remote.fetchMovieById('inconnu')).thenAnswer((_) async => null);

      final result = await repository.getMovieById('inconnu');

      final failure = (result as Err<dynamic>).failure;
      expect(failure, isA<ServerFailure>());
      expect((failure as ServerFailure).statusCode, 404);
    });
  });
}
