import '../../../../core/error/cached.dart';
import '../../../../core/error/result.dart';
import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<Result<Cached<UserProfile>>> getProfile(String userId);

  Future<Result<UserProfile>> updateDisplayName({
    required String userId,
    required String displayName,
  });
}
