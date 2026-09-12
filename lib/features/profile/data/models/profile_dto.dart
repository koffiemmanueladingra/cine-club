import '../../domain/entities/user_profile.dart';

class ProfileDto {
  const ProfileDto._();

  static UserProfile fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        displayName: json['display_name'] as String? ?? 'Utilisateur',
        avatarUrl: json['avatar_url'] as String?,
        updatedAt:
            DateTime.tryParse(json['updated_at'] as String? ?? '')?.toUtc(),
      );
}
