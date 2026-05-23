import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
  Future<void> saveTokens(AuthTokensModel tokens);
  Future<AuthTokensModel?> getTokens();
  Future<void> clearTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.userBox,
  });

  final SecureStorage secureStorage;
  final Box<String> userBox;

  static const _userCacheKey = 'cached_user';

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await userBox.put(_userCacheKey, jsonEncode(user.toJson()));
    } catch (_) {
      throw const CacheException(message: 'Failed to cache user');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final raw = userBox.get(_userCacheKey);
      if (raw == null) return null;
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    await userBox.delete(_userCacheKey);
  }

  @override
  Future<void> saveTokens(AuthTokensModel tokens) async {
    await secureStorage.saveAccessToken(tokens.accessToken);
    await secureStorage.saveRefreshToken(tokens.refreshToken);
  }

  @override
  Future<AuthTokensModel?> getTokens() async {
    final accessToken = await secureStorage.getAccessToken();
    final refreshToken = await secureStorage.getRefreshToken();
    if (accessToken == null || refreshToken == null) return null;
    return AuthTokensModel(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: '',
      userType: '',
      fullName: '',
      isProfileComplete: true,
    );
  }

  @override
  Future<void> clearTokens() => secureStorage.clearAll();
}
