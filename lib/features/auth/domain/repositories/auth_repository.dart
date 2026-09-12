import '../../../../core/error/result.dart';
import '../entities/app_user.dart';

class RegisterOutcome {
  const RegisterOutcome({required this.user, required this.sessionOpened});
  final AppUser? user;
  final bool sessionOpened;
}

abstract interface class AuthRepository {
  AppUser? get currentUser;

  Stream<AppUser?> get authStateChanges;

  Future<AppUser?> restoreSession();

  Future<Result<AppUser>> login({
    required String email,
    required String password,
  });

  Future<Result<RegisterOutcome>> register({
    required String email,
    required String password,
    required String displayName,
  });

  Future<Result<void>> logout();
}
