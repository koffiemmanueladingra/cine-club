import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/storage/json_box_store.dart';

abstract interface class MovieLocalDataSource {
  List<Map<String, dynamic>> readMovies();
  Future<void> writeMovies(List<Map<String, dynamic>> movies);
  DateTime? lastSyncAt();
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  MovieLocalDataSourceImpl([JsonBoxStore? store])
      : _store = store ?? JsonBoxStore(HiveBoxes.movies);

  final JsonBoxStore _store;

  static const String _key = 'catalog';

  @override
  List<Map<String, dynamic>> readMovies() => _store.readList(_key);

  @override
  Future<void> writeMovies(List<Map<String, dynamic>> movies) =>
      _store.writeList(_key, movies);

  @override
  DateTime? lastSyncAt() => _store.lastSyncAt(_key);
}
