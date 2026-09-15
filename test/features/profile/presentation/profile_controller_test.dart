import 'package:cine_club/core/error/failures.dart';
import 'package:cine_club/core/state/async_state.dart';
import 'package:cine_club/features/profile/domain/entities/user_profile.dart';
import 'package:cine_club/features/profile/presentation/controllers/profile_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fakes.dart';

void main() {
  late FakeProfileRepository repository;
  late ProfileController controller;

  setUp(() {
    repository = FakeProfileRepository(
      profile: const UserProfile(id: 'u-1', displayName: 'Ada'),
    );
    controller = ProfileController(repository);
  });

  test('sans utilisateur lié, load() ne fait rien', () async {
    await controller.load();

    expect(controller.state.status, LoadStatus.idle);
  });

  test('load() remplit l\'état avec le profil', () async {
    controller.bindUser('u-1');

    await controller.load();

    expect(controller.state.status, LoadStatus.ready);
    expect(controller.state.data?.displayName, 'Ada');
  });

  test('un échec de lecture place l\'état en erreur', () async {
    controller.bindUser('u-1');
    repository.failure = const EmptyCacheFailure(
      'hors ligne',
      code: FailureCode.profileOffline,
    );

    await controller.load();

    expect(controller.state.status, LoadStatus.error);
    expect(controller.state.failure!.code, FailureCode.profileOffline);
  });

  test('updateDisplayName() met à jour l\'état affiché', () async {
    controller.bindUser('u-1');
    await controller.load();

    final ok = await controller.updateDisplayName('Grace');

    expect(ok, isTrue);
    expect(controller.state.data?.displayName, 'Grace');
    expect(controller.isSaving, isFalse);
  });

  test('updateDisplayName() en échec expose actionFailure sans muter l\'état',
      () async {
    controller.bindUser('u-1');
    await controller.load();
    repository.failure = const NetworkFailure(
      'hors ligne',
      code: FailureCode.writeOffline,
    );

    final ok = await controller.updateDisplayName('Grace');

    expect(ok, isFalse);
    expect(controller.actionFailure!.code, FailureCode.writeOffline);
    expect(controller.state.data?.displayName, 'Ada');
  });

  test('updateDisplayName() sans utilisateur lié échoue immédiatement',
      () async {
    final ok = await controller.updateDisplayName('Grace');

    expect(ok, isFalse);
    expect(repository.profile.displayName, 'Ada');
  });
}
