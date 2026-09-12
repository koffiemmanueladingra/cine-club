import 'dart:async';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/network/error_mapper.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required SessionManager sessionManager,
    required Future<void> Function() clearCaches,
    ErrorMapper mapper = const ErrorMapper(),
  })  : _remote = remote,
        _sessionManager = sessionManager,
        _clearCaches = clearCaches,
        _mapper = mapper;

  final AuthRemoteDataSource _remote;
  final SessionManager _sessionManager;

  final Future<void> Function() _clearCaches;

  final ErrorMapper _mapper;

  String? _cachedDisplayName;

  @override
  AppUser? get currentUser {
    final session = _sessionManager.current;
    if (session == null) return null;
    return AppUser(
      id: session.userId,
      email: session.email,
      displayName: _cachedDisplayName,
    );
  }

  @override
  Stream<AppUser?> get authStateChanges => _sessionManager.changes.map(
        (session) => session == null
            ? null
            : AppUser(
                id: session.userId,
                email: session.email,
                displayName: _cachedDisplayName,
              ),
      );

  @override
  Future<AppUser?> restoreSession() async {
    await _sessionManager.restore();
    return currentUser;
  }

  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async {
    try {
      final dto = await _remote.signIn(
        email: email.trim(),
        password: password,
      );
      await _sessionManager.save(dto.session);
      _cachedDisplayName = dto.user.displayName;
      return Ok(dto.user);
    } on UnauthorizedException catch (e) {
      return Err(AuthFailure(
        _isCredentialError(e) ? 'E-mail ou mot de passe incorrect.' : e.message,
        cause: e,
      ));
    } catch (e) {
      return Err(_mapper.fromException(e));
    }
  }

  @override
  Future<Result<RegisterOutcome>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final dto = await _remote.signUp(
        email: email.trim(),
        password: password,
        displayName: displayName.trim(),
      );

      if (dto == null) {
        return const Ok(RegisterOutcome(user: null, sessionOpened: false));
      }
      await _sessionManager.save(dto.session);
      _cachedDisplayName = dto.user.displayName;
      return Ok(RegisterOutcome(user: dto.user, sessionOpened: true));
    } catch (e) {
      return Err(_mapper.fromException(e));
    }
  }

  @override
  Future<Result<void>> logout() async {
    final session = _sessionManager.current;
    Failure? remoteFailure;

    if (session != null) {
      try {
        await _remote.signOut(session.accessToken);
      } catch (e) {
        remoteFailure = _mapper.fromException(e);
      }
    }

    _cachedDisplayName = null;
    await _sessionManager.clear();
    await _clearCaches();

    return remoteFailure == null
        ? const Ok<void>(null)
        : Err<void>(remoteFailure);
  }

  bool _isCredentialError(UnauthorizedException e) {
    final message = e.message.toLowerCase();
    return message.contains('invalid') ||
        message.contains('credentials') ||
        message.contains('grant');
  }
}
