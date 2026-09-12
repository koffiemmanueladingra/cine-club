import 'package:cine_club/core/error/failures.dart';
import 'package:cine_club/core/error/result.dart';
import 'package:cine_club/core/network/network_info.dart';
import 'package:cine_club/features/favorites/data/datasources/favorite_local_data_source.dart';
import 'package:cine_club/features/favorites/data/datasources/favorite_remote_data_source.dart';
import 'package:cine_club/features/favorites/data/repositories/favorite_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements FavoriteRemoteDataSource {}

class _MockLocal extends Mock implements FavoriteLocalDataSource {}

class _MockNetwork extends Mock implements NetworkInfo {}

void main() {
  late _MockRemote remote;
  late _MockLocal local;
  late _MockNetwork network;
  late FavoriteRepositoryImpl repository;

  const userId = 'user-42';
  const movieId = 'movie-7';

  final rows = <Map<String, dynamic>>[
    {
      'id': 'fav-1',
      'created_at': '2026-02-01T12:00:00Z',
      'movie': {
        'id': movieId,
        'title': 'Le Voyage dans la Lune',
        'overview': 'Des savants partent pour la Lune.',
        'release_year': 1902,
        'rating': 8.1,
        'genre': 'Aventure',
      },
    },
    {
      'id': 'fav-2',
      'created_at': '2026-02-02T12:00:00Z',
      'movie': null,
    },
  ];

  setUpAll(() {
    registerFallbackValue(<Map<String, dynamic>>[]);
  });

  setUp(() {
    remote = _MockRemote();
    local = _MockLocal();
    network = _MockNetwork();
    repository = FavoriteRepositoryImpl(
      remote: remote,
      local: local,
      networkInfo: network,
    );

    when(() => local.lastSyncAt(any())).thenReturn(null);
    when(() => local.writeFavorites(any(), any())).thenAnswer((_) async {});
  });

  group('getFavorites', () {
    test('R1 — hors ligne avec cache : renvoie le cache', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);
      when(() => local.readFavorites(userId)).thenReturn(rows);

      final result = await repository.getFavorites(userId: userId);

      final cached = (result as Ok<dynamic>).value;
      expect(cached.fromCache, isTrue);
      expect(cached.data.length, 1);
      expect(cached.data.single.movie.title, 'Le Voyage dans la Lune');
    });

    test('R2 — hors ligne sans cache : EmptyCacheFailure', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);
      when(() => local.readFavorites(userId)).thenReturn(const []);

      final result = await repository.getFavorites(userId: userId);

      expect((result as Err<dynamic>).failure, isA<EmptyCacheFailure>());
    });

    test('R3 — en ligne : réseau puis mise à jour du cache', () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(remote.fetchFavorites).thenAnswer((_) async => rows);

      final result = await repository.getFavorites(userId: userId);

      expect((result as Ok<dynamic>).value.fromCache, isFalse);
      verify(() => local.writeFavorites(userId, rows)).called(1);
    });
  });

  group('mutations', () {
    test('R4 — ajout hors ligne : NetworkFailure, aucun appel réseau',
        () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      final result =
          await repository.addFavorite(userId: userId, movieId: movieId);

      expect((result as Err<dynamic>).failure, isA<NetworkFailure>());
      verifyNever(() => remote.addFavorite(any()));
    });

    test('R4 — retrait hors ligne : NetworkFailure', () async {
      when(() => network.isConnected).thenAnswer((_) async => false);

      final result =
          await repository.removeFavorite(userId: userId, movieId: movieId);

      expect((result as Err<dynamic>).failure, isA<NetworkFailure>());
      verifyNever(() => remote.removeFavorite(any()));
    });

    test('R5 — ajout en ligne : mutation puis resynchronisation du cache',
        () async {
      when(() => network.isConnected).thenAnswer((_) async => true);
      when(() => remote.addFavorite(movieId)).thenAnswer((_) async {});
      when(remote.fetchFavorites).thenAnswer((_) async => rows);

      final result =
          await repository.addFavorite(userId: userId, movieId: movieId);

      expect(result, isA<Ok<dynamic>>());
      verify(() => remote.addFavorite(movieId)).called(1);
      verify(() => local.writeFavorites(userId, rows)).called(1);
    });

    test(
      'un échec de resynchronisation ne transforme pas un succès en erreur',
      () async {
        when(() => network.isConnected).thenAnswer((_) async => true);
        when(() => remote.removeFavorite(movieId)).thenAnswer((_) async {});
        when(remote.fetchFavorites).thenThrow(Exception('timeout'));

        final result =
            await repository.removeFavorite(userId: userId, movieId: movieId);

        expect(result, isA<Ok<dynamic>>());
      },
    );
  });
}
