import '../../../../core/session/auth_session.dart';
import '../../domain/entities/app_user.dart';

class SessionDto {
  const SessionDto({required this.session, required this.user});

  final AuthSession session;
  final AppUser user;

  factory SessionDto.fromJson(Map<String, dynamic> json) {
    final accessToken = json['access_token'] as String?;
    final refreshToken = json['refresh_token'] as String?;
    if (accessToken == null || refreshToken == null) {
      throw const FormatException('Réponse sans session.');
    }

    final userJson = (json['user'] as Map<String, dynamic>?) ?? const {};
    final user = userFromJson(userJson);

    return SessionDto(
      session: AuthSession(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresAt: _expiryFrom(json),
        userId: user.id,
        email: user.email,
      ),
      user: user,
    );
  }

  static DateTime _expiryFrom(Map<String, dynamic> json) {
    final expiresAt = json['expires_at'];
    if (expiresAt is int) {
      return DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000, isUtc: true);
    }
    final expiresIn = json['expires_in'];
    final seconds = expiresIn is int ? expiresIn : 3600;
    return DateTime.now().toUtc().add(Duration(seconds: seconds));
  }

  static AppUser userFromJson(Map<String, dynamic> json) {
    final metadata =
        (json['user_metadata'] as Map<String, dynamic>?) ?? const {};
    return AppUser(
      id: json['id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      displayName: metadata['display_name'] as String?,
    );
  }
}
