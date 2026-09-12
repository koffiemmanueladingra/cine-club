import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_session.dart';

class SessionManager {
  SessionManager(this._storage);

  final FlutterSecureStorage _storage;

  static const String _storageKey = 'cine_club.session.v1';

  AuthSession? _current;
  final StreamController<AuthSession?> _controller =
      StreamController<AuthSession?>.broadcast();

  AuthSession? get current => _current;

  Stream<AuthSession?> get changes => _controller.stream;

  Future<AuthSession?> restore() async {
    final raw = await _storage.read(key: _storageKey);
    if (raw == null) return null;
    try {
      _current =
          AuthSession.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      await _storage.delete(key: _storageKey);
      _current = null;
    }
    _controller.add(_current);
    return _current;
  }

  Future<void> save(AuthSession session) async {
    _current = session;
    await _storage.write(key: _storageKey, value: jsonEncode(session.toJson()));
    _controller.add(_current);
  }

  Future<void> clear() async {
    _current = null;
    await _storage.delete(key: _storageKey);
    _controller.add(null);
  }

  Future<void> dispose() async => _controller.close();
}
