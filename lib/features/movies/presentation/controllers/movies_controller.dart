import 'package:flutter/foundation.dart';

import '../../../../core/state/async_state.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movie_repository.dart';

class MoviesController extends ChangeNotifier {
  MoviesController(this._repository);

  final MovieRepository _repository;

  AsyncState<List<Movie>> _state = const AsyncState<List<Movie>>();
  AsyncState<List<Movie>> get state => _state;

  String _query = '';
  String get query => _query;

  List<Movie> get visibleMovies {
    final all = _state.data ?? const <Movie>[];
    if (_query.trim().isEmpty) return all;
    final needle = _query.toLowerCase();
    return all
        .where((m) =>
            m.title.toLowerCase().contains(needle) ||
            (m.genre ?? '').toLowerCase().contains(needle))
        .toList(growable: false);
  }

  Future<void> load({bool forceRefresh = false}) async {
    _state = _state.toLoading();
    notifyListeners();

    final result = await _repository.getMovies(forceRefresh: forceRefresh);
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

  void search(String value) {
    _query = value;
    notifyListeners();
  }
}
