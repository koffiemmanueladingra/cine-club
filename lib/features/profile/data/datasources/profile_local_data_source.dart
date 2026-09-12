import '../../../../core/storage/hive_boxes.dart';
import '../../../../core/storage/json_box_store.dart';

abstract interface class ProfileLocalDataSource {
  Map<String, dynamic>? readProfile(String userId);
  Future<void> writeProfile(String userId, Map<String, dynamic> row);
  DateTime? lastSyncAt(String userId);
}

class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {
  ProfileLocalDataSourceImpl([JsonBoxStore? store])
      : _store = store ?? JsonBoxStore(HiveBoxes.profile);

  final JsonBoxStore _store;

  @override
  Map<String, dynamic>? readProfile(String userId) =>
      _store.readObject(_key(userId));

  @override
  Future<void> writeProfile(String userId, Map<String, dynamic> row) =>
      _store.writeObject(_key(userId), row);

  @override
  DateTime? lastSyncAt(String userId) => _store.lastSyncAt(_key(userId));

  String _key(String userId) => 'user:$userId';
}
