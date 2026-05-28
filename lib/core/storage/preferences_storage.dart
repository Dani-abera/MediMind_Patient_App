import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

class PreferencesStorage {
  PreferencesStorage(this._prefs);
  final SharedPreferences _prefs;

  bool get onboardingCompleted =>
      _prefs.getBool(StorageKeys.onboardingCompleted) ?? false;

  Future<void> setOnboardingCompleted(bool value) =>
      _prefs.setBool(StorageKeys.onboardingCompleted, value);

  String get selectedLanguage =>
      _prefs.getString(StorageKeys.selectedLanguage) ?? 'en-US';

  Future<void> setSelectedLanguage(String lang) =>
      _prefs.setString(StorageKeys.selectedLanguage, lang);

  ThemeMode get themeMode {
    final value = _prefs.getString(StorageKeys.themeMode);
    return ThemeMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      _prefs.setString(StorageKeys.themeMode, mode.name);

  DateTime? get lastSyncedAt {
    final value = _prefs.getString(StorageKeys.lastSyncedAt);
    return value != null ? DateTime.tryParse(value) : null;
  }

  Future<void> setLastSyncedAt(DateTime dateTime) =>
      _prefs.setString(StorageKeys.lastSyncedAt, dateTime.toIso8601String());

  Map<String, dynamic>? get notificationPreferences {
    final value = _prefs.getString(StorageKeys.notificationPreferences);
    if (value == null) return null;
    return json.decode(value) as Map<String, dynamic>;
  }

  Future<void> setNotificationPreferences(Map<String, dynamic> prefs) =>
      _prefs.setString(
        StorageKeys.notificationPreferences,
        json.encode(prefs),
      );

  bool get tutorialCompleted =>
      _prefs.getBool(StorageKeys.tutorialCompleted) ?? false;

  Future<void> setTutorialCompleted(bool value) =>
      _prefs.setBool(StorageKeys.tutorialCompleted, value);

  bool isHealthSetupComplete(String userId) =>
      _prefs.getBool('${StorageKeys.healthSetupCompleted}_$userId') ?? false;

  Future<void> setHealthSetupComplete(String userId) =>
      _prefs.setBool('${StorageKeys.healthSetupCompleted}_$userId', true);

  bool isProfileSetupComplete(String userId) =>
      _prefs.getBool('${StorageKeys.profileSetupCompleted}_$userId') ?? false;

  Future<void> setProfileSetupComplete(String userId) =>
      _prefs.setBool('${StorageKeys.profileSetupCompleted}_$userId', true);
}
