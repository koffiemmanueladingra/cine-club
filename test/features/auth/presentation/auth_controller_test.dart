import 'package:cine_club/core/error/failures.dart';
import 'package:cine_club/features/auth/domain/entities/app_user.dart';
import 'package:cine_club/features/auth/presentation/controllers/auth_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fakes.dart';

void main() {
  late FakeAuthRepository repository;
  late AuthController controller;

  setUp(() {
    repository = FakeAuthRepository();
    controller = AuthController(repository);
  });

  tearDown(() {
    controller.dispose();
    repository.dispose();
  });

  test('avant bootstrap(), le statut est inconnu', () {
    expect(controller.status, AuthStatus.unknown);
  });

  test('bootstrap() sans session stockée : non authentifié', () async {
    await controller.bootstrap();

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.user, isNull);
  });

  test('bootstrap() avec session stockée : authentifié', () async {
    repository.user = const AppUser(
      id: 'u-1',
      email: 'ada@example.com',
      displayName: 'Ada',
    );
    await controller.bootstrap();

    expect(controller.status, AuthStatus.authenticated);
    expect(controller.user?.email, 'ada@example.com');
  });

  test('login() réussi bascule le statut et vide les messages', () async {
    await controller.bootstrap();

    final ok = await controller.login(
      email: 'ada@example.com',
      password: 'secret',
    );

    expect(ok, isTrue);
    expect(controller.status, AuthStatus.authenticated);
    expect(controller.failure, isNull);
    expect(controller.isSubmitting, isFalse);
  });

  test('login() échoué expose le Failure et reste non authentifié', () async {
    await controller.bootstrap();
    repository.loginFailure = const AuthFailure(
      'E-mail ou mot de passe incorrect.',
      code: FailureCode.serverMessage,
    );

    final ok = await controller.login(email: 'a@b.c', password: 'x');

    expect(ok, isFalse);
    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.failure, isA<AuthFailure>());
  });

  test('isSubmitting est vrai pendant la requête, faux après', () async {
    await controller.bootstrap();
    final seen = <bool>[];
    controller.addListener(() => seen.add(controller.isSubmitting));

    await controller.login(email: 'a@b.c', password: 'x');

    expect(seen.first, isTrue);
    expect(seen.last, isFalse);
  });

  test('register() sans session ouverte expose la notice de confirmation',
      () async {
    await controller.bootstrap();
    repository.requiresEmailConfirmation = true;

    final ok = await controller.register(
      email: 'a@b.c',
      password: 'secret',
      displayName: 'Ada',
    );

    expect(ok, isTrue);
    // Le contrôleur expose un cas, pas une phrase : la traduction est
    // choisie par l'écran, donc changer de langue reste cohérent.
    expect(controller.notice, AuthNotice.confirmEmail);
    expect(controller.status, AuthStatus.unauthenticated);
  });

  test('logout() repasse en non authentifié', () async {
    repository.user = const AppUser(
      id: 'u-1',
      email: 'ada@example.com',
      displayName: 'Ada',
    );
    await controller.bootstrap();

    await controller.logout();

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.user, isNull);
  });

  test('une session expirée côté serveur déconnecte et prévient', () async {
    repository.user = const AppUser(
      id: 'u-1',
      email: 'ada@example.com',
      displayName: 'Ada',
    );
    await controller.bootstrap();

    repository.expireSession();
    await Future<void>.delayed(Duration.zero);

    expect(controller.status, AuthStatus.unauthenticated);
    expect(controller.notice, AuthNotice.sessionExpired);
  });

  test('clearMessages() efface erreur et notice', () async {
    await controller.bootstrap();
    repository.loginFailure =
        const AuthFailure('non', code: FailureCode.unknown);
    await controller.login(email: 'a@b.c', password: 'x');

    controller.clearMessages();

    expect(controller.failure, isNull);
    expect(controller.notice, isNull);
  });
}
