import 'package:cine_club/core/error/failures.dart';
import 'package:cine_club/core/state/async_state.dart';
import 'package:cine_club/features/movies/presentation/controllers/movies_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fakes.dart';

void main() {
  late FakeMovieRepository repository;
  late MoviesController controller;

  final metropolis =
      movie(id: 'm-1', title: 'Metropolis', genre: 'Science-fiction');
  final nosferatu = movie(id: 'm-2', title: 'Nosferatu', genre: 'Horreur');

  setUp(() {
    repository = FakeMovieRepository(movies: [metropolis, nosferatu]);
    controller = MoviesController(repository);
  });

  test('état initial : idle, sans données', () {
    expect(controller.state.status, LoadStatus.idle);
    expect(controller.state.hasData, isFalse);
    expect(controller.visibleMovies, isEmpty);
  });

  test('load() passe par loading puis ready et notifie deux fois', () async {
    final statuses = <LoadStatus>[];
    controller.addListener(() => statuses.add(controller.state.status));

    await controller.load();

    expect(statuses, [LoadStatus.loading, LoadStatus.ready]);
    expect(controller.state.data, [metropolis, nosferatu]);
  });

  test('load() propage fromCache et syncedAt du dépôt', () async {
    repository.fromCache = true;
    repository.syncedAt = DateTime.utc(2026, 1, 15, 10, 30);

    await controller.load();

    expect(controller.state.fromCache, isTrue);
    expect(controller.state.syncedAt, DateTime.utc(2026, 1, 15, 10, 30));
  });

  test("un échec place l'état en erreur sans écraser les données", () async {
    await controller.load();
    repository.failure = const NetworkFailure(
      'hors ligne',
      code: FailureCode.connection,
    );

    await controller.load();

    expect(controller.state.status, LoadStatus.error);
    expect(controller.state.failure, isA<NetworkFailure>());
    // Règle de l'application : une erreur ne fait jamais disparaître
    // des données déjà affichées.
    expect(controller.state.data, isNotNull);
  });

  test('search() filtre sur le titre, sans tenir compte de la casse', () async {
    await controller.load();

    controller.search('METRO');

    expect(controller.visibleMovies, [metropolis]);
  });

  test('search() filtre aussi sur le genre', () async {
    await controller.load();

    controller.search('horreur');

    expect(controller.visibleMovies, [nosferatu]);
  });

  test('une recherche vide ou blanche rend toute la liste', () async {
    await controller.load();

    controller.search('   ');

    expect(controller.visibleMovies, hasLength(2));
  });

  test('forceRefresh est transmis au dépôt', () async {
    await controller.load(forceRefresh: true);

    expect(repository.getMoviesCalls, 1);
  });

  test('la liste filtrée est non modifiable', () async {
    await controller.load();
    controller.search('metro');

    // `visibleMovies` construit la liste filtrée avec `growable: false` :
    // aucune vue ne peut muter l'état du contrôleur par accident.
    expect(
      () => controller.visibleMovies.add(nosferatu),
      throwsUnsupportedError,
    );
  });
}
