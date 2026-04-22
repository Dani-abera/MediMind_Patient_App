import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/storage_keys.dart';

class SecureStorage {
  SecureStorage() : _storage = FlutterSecureStorage(
    iOptions: const IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
    aOptions: const AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  final FlutterSecureStorage _storage;

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: StorageKeys.accessToken, value: token);

  Future<String?> getAccessToken() =>
      _storage.read(key: StorageKeys.accessToken);

  Future<void> saveRefreshToken(String token) =>
      _storage.write(key: StorageKeys.refreshToken, value: token);

  Future<String?> getRefreshToken() =>
      _storage.read(key: StorageKeys.refreshToken);

  Future<void> saveUserId(String userId) =>
      _storage.write(key: StorageKeys.userId, value: userId);

  Future<String?> getUserId() =>
      _storage.read(key: StorageKeys.userId);

  Future<void> clearAll() => _storage.deleteAll();
}
