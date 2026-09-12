import 'auth_session.dart';

abstract interface class TokenRefresher {
  Future<AuthSession> refresh(String refreshToken);
}
