import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/state/async_state.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileController extends ChangeNotifier {
  ProfileController(this._repository);

  final ProfileRepository _repository;

  String? _userId;

  AsyncState<UserProfile> _state = const AsyncState<UserProfile>();
  AsyncState<UserProfile> get state => _state;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  Failure? _actionFailure;
  Failure? get actionFailure => _actionFailure;

  void bindUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _state = const AsyncState<UserProfile>();
    notifyListeners();
  }

  Future<void> load() async {
    final userId = _userId;
    if (userId == null) return;

    _state = _state.toLoading();
    notifyListeners();

    final result = await _repository.getProfile(userId);
    _state = result.fold(
      ok: (cached) => _state.toReady(
        cached.data,
        fromCache: cached.fromCache,
        syncedAt: cached.syncedAt,
      ),
      err: _state.toError,
    );
    notifyListeners();
  }

  Future<bool> updateDisplayName(String displayName) async {
    final userId = _userId;
    if (userId == null) return false;

    _isSaving = true;
    _actionFailure = null;
    notifyListeners();

    final result = await _repository.updateDisplayName(
      userId: userId,
      displayName: displayName,
    );

    _isSaving = false;
    return result.fold(
      ok: (profile) {
        _state = _state.toReady(profile, syncedAt: DateTime.now().toUtc());
        notifyListeners();
        return true;
      },
      err: (failure) {
        _actionFailure = failure;
        notifyListeners();
        return false;
      },
    );
  }
}
