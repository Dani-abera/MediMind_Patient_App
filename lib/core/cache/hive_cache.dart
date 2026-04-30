import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';

/// Generic TTL-based Hive cache for GET responses.
///
/// Values are stored as JSON strings alongside a timestamp. On read,
/// stale entries (past TTL) return null — callers should re-fetch.
class HiveCache {
  static const _boxName = 'api_cache';
  static Box<String>? _box;

  static Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  static Box<String> get _b {
    assert(_box != null, 'HiveCache.init() must be called first');
    return _box!;
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  static Future<void> put(String key, dynamic value) async {
    final entry = jsonEncode({
      'ts': DateTime.now().millisecondsSinceEpoch,
      'v': value,
    });
    await _b.put(key, entry);
  }

  // ── Read ──────────────────────────────────────────────────────────────────

  static T? get<T>(String key, {required Duration ttl}) {
    final raw = _b.get(key);
    if (raw == null) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final ts = map['ts'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      if (age > ttl.inMilliseconds) return null; // stale
      return map['v'] as T?;
    } catch (_) {
      return null;
    }
  }

  static bool isStale(String key, {required Duration ttl}) {
    final raw = _b.get(key);
    if (raw == null) return true;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final ts = map['ts'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - ts;
      return age > ttl.inMilliseconds;
    } catch (_) {
      return true;
    }
  }

  // ── Invalidate ────────────────────────────────────────────────────────────

  static Future<void> invalidate(String key) => _b.delete(key);

  static Future<void> invalidatePrefix(String prefix) async {
    final keys = _b.keys
        .whereType<String>()
        .where((k) => k.startsWith(prefix))
        .toList();
    await _b.deleteAll(keys);
  }

  static Future<void> clear() => _b.clear();
}

/// TTL constants for each endpoint category.
class CacheTtl {
  CacheTtl._();
  static const centers = Duration(minutes: 5);
  static const doctors = Duration(minutes: 5);
  static const availability = Duration(seconds: 30);
  static const predictions = Duration(minutes: 10);
  // Health records: no cache (always on-demand)
}
