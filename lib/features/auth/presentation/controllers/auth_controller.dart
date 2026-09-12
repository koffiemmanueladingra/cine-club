import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthController extends ChangeNotifier {
  AuthController(this._repository) {
    _subscription = _repository.authStateChanges.listen(_onAuthStateChanged);
  }

  final AuthRepository _repository;
  late final StreamSubscription<AppUser?> _subscription;

  AuthStatus _status = AuthStatus.unknown;
  AppUser? _user;
  bool _isSubmitting = false;
  Failure? _failure;
  String? _notice;

  AuthStatus get status => _status;
  AppUser? get user => _user;
  bool get isSubmitting => _isSubmitting;
  Failure? get failure => _failure;

  String? get notice => _notice;

  Future<void> bootstrap() async {
    final user = await _repository.restoreSession();
    _user = user;
    _status =
        user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
    notifyListeners();
  }

  Future<bool> login({required String email, required String password}) async {
    _beginSubmit();
    final result = await _repository.login(email: email, password: password);
    return _endSubmit(
      result.fold(
        ok: (user) {
          _user = user;
          _status = AuthStatus.authenticated;
          return true;
        },
        err: (failure) {
          _failure = failure;
          return false;
        },
      ),
    );
  }

  Future<bool> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _beginSubmit();
    final result = await _repository.register(
      email: email,
      password: password,
      displayName: displayName,
    );
    return _endSubmit(
      result.fold(
        ok: (outcome) {
          if (!outcome.sessionOpened) {
            _notice =
                'Compte créé. Confirmez votre adresse e-mail puis connectez-vous.';
            return true;
          }
          _user = outcome.user;
          _status = AuthStatus.authenticated;
          return true;
        },
        err: (failure) {
          _failure = failure;
          return false;
        },
      ),
    );
  }

  Future<void> logout() async {
    _beginSubmit();
    final result = await _repository.logout();
    _failure = result.failureOrNull;
    _user = null;
    _status = AuthStatus.unauthenticated;
    _isSubmitting = false;
    notifyListeners();
  }

  void clearMessages() {
    _failure = null;
    _notice = null;
    notifyListeners();
  }

  void _onAuthStateChanged(AppUser? user) {
    if (user == null && _status == AuthStatus.authenticated) {
      _status = AuthStatus.unauthenticated;
      _user = null;
      _notice = 'Votre session a expiré. Reconnectez-vous.';
      notifyListeners();
    }
  }

  void _beginSubmit() {
    _isSubmitting = true;
    _failure = null;
    _notice = null;
    notifyListeners();
  }

  bool _endSubmit(bool success) {
    _isSubmitting = false;
    notifyListeners();
    return success;
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
