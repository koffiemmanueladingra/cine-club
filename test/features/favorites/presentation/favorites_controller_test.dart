import 'package:cine_club/core/error/failures.dart';
import 'package:cine_club/core/state/async_state.dart';
import 'package:cine_club/features/favorites/presentation/controllers/favorites_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fakes.dart';

void main() {
  late FakeFavoriteRepository repository;
  late FavoritesController controller;

  final metropolis = movie(id: 'm-1', title: 'Metropolis');
  final nosferatu = movie(id: 'm-2', title: 'Nosferatu');

  setUp(() {
    repository = FakeFavoriteRepository(catalogue: [metropolis, nosferatu]);
    controller = FavoritesController(repository);
  });

  test('sans utilisateur lié, load() ne fait rien', () async {
    await controller.load();

    expect(controller.state.status, LoadStatus.idle);
    expect(controller.favoriteMovieIds, isEmpty);
  });

  test('toggle() sans utilisateur lié échoue sans appeler le dépôt', () async {
    final ok = await controller.toggle('m-1');

    expect(ok, isFalse);
    expect(repository.favorites, isEmpty);
  });

  test('bindUser() remet l\'état à zéro', () async {
    controller.bindUser('u-1');
    await controller.load();
    expect(controller.state.hasData, isTrue);

    controller.bindUser('u-2');

    expect(controller.state.status, LoadStatus.idle);
    expect(controller.favoriteMovieIds, isEmpty);
  });

  test('bindUser() avec le même identifiant ne notifie pas', () {
    controller.bindUser('u-1');
    var notifications = 0;
    controller.addListener(() => notifications++);

    controller.bindUser('u-1');

    expect(notifications, 0);
  });

  test('toggle() ajoute puis retire, et recharge la liste', () async {
    controller.bindUser('u-1');
    await controller.load();

    expect(await controller.toggle('m-1'), isTrue);
    expect(controller.favoriteMovieIds, {'m-1'});

    expect(await controller.toggle('m-1'), isTrue);
    expect(controller.favoriteMovieIds, isEmpty);
  });

  test('favoriteMovieIds est mémorisé : même instance entre deux appels',
      () async {
    controller.bindUser('u-1');
    await controller.load();

    // Le getter ne doit pas reconstruire le Set à chaque lecture : chaque
    // carte du catalogue l'interroge via `context.select`.
    expect(
      identical(controller.favoriteMovieIds, controller.favoriteMovieIds),
      isTrue,
    );
  });

  test('un échec d\'écriture est exposé sans changer la liste', () async {
    controller.bindUser('u-1');
    await controller.load();
    repository.writeFailure = const NetworkFailure(
      'hors ligne',
      code: FailureCode.writeOffline,
    );

    final ok = await controller.toggle('m-1');

    expect(ok, isFalse);
    expect(controller.actionFailure, isA<NetworkFailure>());
    expect(controller.actionFailure!.code, FailureCode.writeOffline);
    expect(controller.favoriteMovieIds, isEmpty);
  });

  test('clearActionFailure() efface l\'erreur d\'action', () async {
    controller.bindUser('u-1');
    await controller.load();
    repository.writeFailure = const NetworkFailure(
      'hors ligne',
      code: FailureCode.writeOffline,
    );
    await controller.toggle('m-1');

    controller.clearActionFailure();

    expect(controller.actionFailure, isNull);
  });
}
