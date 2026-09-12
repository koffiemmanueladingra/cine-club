import 'dart:convert';

import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import '../error/exceptions.dart';
import 'hive_boxes.dart';

class JsonBoxStore {
  JsonBoxStore(this.boxName);

  final String boxName;

  Box<String> get _box => Hive.box<String>(boxName);
  Box<String> get _meta => Hive.box<String>(HiveBoxes.meta);

  List<Map<String, dynamic>> readList(String key) {
    final raw = _box.get(key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      throw CacheException('Cache illisible pour "$key".', cause: e);
    }
  }

  Map<String, dynamic>? readObject(String key) {
    final raw = _box.get(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      throw CacheException('Cache illisible pour "$key".', cause: e);
    }
  }

  Future<void> writeList(String key, List<Map<String, dynamic>> value) async {
    try {
      await _box.put(key, jsonEncode(value));
      await _touch(key);
    } catch (e) {
      throw CacheException('Écriture impossible pour "$key".', cause: e);
    }
  }

  Future<void> writeObject(String key, Map<String, dynamic> value) async {
    try {
      await _box.put(key, jsonEncode(value));
      await _touch(key);
    } catch (e) {
      throw CacheException('Écriture impossible pour "$key".', cause: e);
    }
  }

  Future<void> delete(String key) async {
    await _box.delete(key);
    await _meta.delete(_metaKey(key));
  }

  DateTime? lastSyncAt(String key) {
    final raw = _meta.get(_metaKey(key));
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  Future<void> _touch(String key) =>
      _meta.put(_metaKey(key), DateTime.now().toUtc().toIso8601String());

  String _metaKey(String key) => '$boxName::$key';
}
