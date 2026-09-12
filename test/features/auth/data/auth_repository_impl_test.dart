import 'package:cine_club/core/error/exceptions.dart';
import 'package:cine_club/core/error/failures.dart';
import 'package:cine_club/core/error/result.dart';
import 'package:cine_club/core/session/auth_session.dart';
import 'package:cine_club/core/session/session_manager.dart';
import 'package:cine_club/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:cine_club/features/auth/data/models/session_dto.dart';
import 'package:cine_club/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:cine_club/features/auth/domain/entities/app_user.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRemote extends Mock implements AuthRemoteDataSource {}

class _MockSessionManager extends Mock implements SessionManager {}

class _FakeAuthSession extends Fake implements AuthSession {}

void main() {
  late _MockRemote remote;
  late _MockSessionManager sessionManager;
  late AuthRepositoryImpl repository;
  late int clearCachesCalls;

  final session = AuthSession(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    expiresAt: DateTime.utc(2030),
    userId: 'user-1',
    email: 'ada@example.com',
  );

  const user = AppUser(
    id: 'user-1',
    email: 'ada@example.com',
    displayName: 'Ada',
  );

  setUpAll(() {
    registerFallbackValue(_FakeAuthSession());
  });

  setUp(() {
    remote = _MockRemote();
    sessionManager = _MockSessionManager();
    clearCachesCalls = 0;

    repository = AuthRepositoryImpl(
      remote: remote,
      sessionManager: sessionManager,
      clearCaches: () async => clearCachesCalls++,
    );

    when(() => sessionManager.save(any())).thenAnswer((_) async {});
    when(sessionManager.clear).thenAnswer((_) async {});
    when(() => sessionManager.current).thenReturn(null);
  });

  group('login', () {
    test('persiste la session et renvoie l\'utilisateur', () async {
      when(() => remote.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer(
        (_) async => SessionDto(session: session, user: user),
      );

      final result = await repository.login(
        email: '  ada@example.com  ',
        password: 'secret',
      );

      expect((result as Ok<dynamic>).value.id, 'user-1');
      verify(() => sessionManager.save(session)).called(1);
      verify(() => remote.signIn(
            email: 'ada@example.com',
            password: 'secret',
          )).called(1);
    });

    test(
      'identifiants invalides : message générique, sans révéler si le compte existe',
      () async {
        when(() => remote.signIn(
              email: any(named: 'email'),
              password: any(named: 'password'),
            )).thenThrow(
          const UnauthorizedException('Invalid login credentials'),
        );

        final result = await repository.login(
          email: 'ada@example.com',
          password: 'mauvais',
        );

        final failure = (result as Err<dynamic>).failure;
        expect(failure, isA<AuthFailure>());
        expect(failure.message, 'E-mail ou mot de passe incorrect.');
        verifyNever(() => sessionManager.save(any()));
      },
    );

    test('erreur réseau : NetworkFailure, aucune session enregistrée',
        () async {
      when(() => remote.signIn(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(const NetworkException('Serveur injoignable.'));

      final result = await repository.login(
        email: 'ada@example.com',
        password: 'secret',
      );

      expect((result as Err<dynamic>).failure, isA<NetworkFailure>());
      verifyNever(() => sessionManager.save(any()));
    });
  });

  group('register', () {
    test('sans session ouverte : sessionOpened = false (confirmation e-mail)',
        () async {
      when(() => remote.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            displayName: any(named: 'displayName'),
          )).thenAnswer((_) async => null);

      final result = await repository.register(
        email: 'ada@example.com',
        password: 'secret',
        displayName: 'Ada',
      );

      expect((result as Ok<dynamic>).value.sessionOpened, isFalse);
      verifyNever(() => sessionManager.save(any()));
    });
  });

  group('logout', () {
    test('purge la session et les caches même si l\'appel serveur échoue',
        () async {
      when(() => sessionManager.current).thenReturn(session);
      when(() => remote.signOut(any()))
          .thenThrow(const NetworkException('Serveur injoignable.'));

      final result = await repository.logout();

      expect((result as Err<dynamic>).failure, isA<NetworkFailure>());
      verify(sessionManager.clear).called(1);
      expect(clearCachesCalls, 1);
    });

    test('cas nominal : révocation serveur puis purge locale', () async {
      when(() => sessionManager.current).thenReturn(session);
      when(() => remote.signOut('access-token')).thenAnswer((_) async {});

      final result = await repository.logout();

      expect(result, isA<Ok<dynamic>>());
      verify(() => remote.signOut('access-token')).called(1);
      verify(sessionManager.clear).called(1);
      expect(clearCachesCalls, 1);
    });
  });
}
