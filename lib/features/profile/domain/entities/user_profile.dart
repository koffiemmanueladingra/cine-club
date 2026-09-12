class UserProfile {
  const UserProfile({
    required this.id,
    required this.displayName,
    this.avatarUrl,
    this.updatedAt,
  });

  final String id;
  final String displayName;
  final String? avatarUrl;
  final DateTime? updatedAt;

  UserProfile copyWith({String? displayName, String? avatarUrl}) => UserProfile(
        id: id,
        displayName: displayName ?? this.displayName,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        updatedAt: updatedAt,
      );
}
