import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/storage/json_box_store.dart';

abstract interface class FavoriteLocalDataSource {
  List<Map<String, dynamic>> readFavorites(String userId);
  Future<void> writeFavorites(String userId, List<Map<String, dynamic>> rows);
  DateTime? lastSyncAt(String userId);
}

class FavoriteLocalDataSourceImpl implements FavoriteLocalDataSource {
  FavoriteLocalDataSourceImpl([JsonBoxStore? store])
      : _store = store ?? JsonBoxStore(HiveBoxes.favorites);

  final JsonBoxStore _store;

  @override
  List<Map<String, dynamic>> readFavorites(String userId) =>
      _store.readList(_key(userId));

  @override
  Future<void> writeFavorites(
    String userId,
    List<Map<String, dynamic>> rows,
  ) =>
      _store.writeList(_key(userId), rows);

  @override
  DateTime? lastSyncAt(String userId) => _store.lastSyncAt(_key(userId));

  String _key(String userId) => 'user:$userId';
}
