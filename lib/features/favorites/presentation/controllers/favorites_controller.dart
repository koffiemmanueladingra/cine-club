import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/state/async_state.dart';
import '../../domain/entities/favorite_movie.dart';
import '../../domain/repositories/favorite_repository.dart';

class FavoritesController extends ChangeNotifier {
  FavoritesController(this._repository);

  final FavoriteRepository _repository;

  String? _userId;

  AsyncState<List<FavoriteMovie>> _state =
      const AsyncState<List<FavoriteMovie>>();
  AsyncState<List<FavoriteMovie>> get state => _state;

  Failure? _actionFailure;

  Failure? get actionFailure => _actionFailure;

  Set<String> get favoriteMovieIds =>
      (_state.data ?? const <FavoriteMovie>[]).map((f) => f.movie.id).toSet();

  void bindUser(String? userId) {
    if (_userId == userId) return;
    _userId = userId;
    _state = const AsyncState<List<FavoriteMovie>>();
    notifyListeners();
  }

  Future<void> load() async {
    final userId = _userId;
    if (userId == null) return;

    _state = _state.toLoading();
    notifyListeners();

    final result = await _repository.getFavorites(userId: userId);
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

  Future<bool> toggle(String movieId) async {
    final userId = _userId;
    if (userId == null) return false;

    _actionFailure = null;
    final isFavorite = favoriteMovieIds.contains(movieId);

    final result = isFavorite
        ? await _repository.removeFavorite(userId: userId, movieId: movieId)
        : await _repository.addFavorite(userId: userId, movieId: movieId);

    return result.fold(
      ok: (_) async {
        await load();
        return true;
      },
      err: (failure) async {
        _actionFailure = failure;
        notifyListeners();
        return false;
      },
    );
  }

  void clearActionFailure() {
    _actionFailure = null;
  }
}
