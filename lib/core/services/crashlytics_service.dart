import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CrashlyticsService {
  CrashlyticsService._();
  static final CrashlyticsService instance = CrashlyticsService._();

  bool get _available => Firebase.apps.isNotEmpty;

  Future<void> init() async {
    if (!_available) return;
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
    final info = await PackageInfo.fromPlatform();
    await FirebaseCrashlytics.instance
        .setCustomKey('app_version', '${info.version}+${info.buildNumber}');
  }

  Future<void> setUser(String patientId) async {
    if (!_available) return;
    final hashed = patientId.hashCode.toUnsigned(32).toRadixString(16);
    await FirebaseCrashlytics.instance.setUserIdentifier(hashed);
    await AnalyticsHelperRef._setUserId(hashed);
  }

  Future<void> clearUser() async {
    if (!_available) return;
    await FirebaseCrashlytics.instance.setUserIdentifier('');
  }

  Future<void> setScreenName(String name) async {
    if (!_available) return;
    await FirebaseCrashlytics.instance.setCustomKey('screen_name', name);
  }

  Future<void> setFeatureFlags(Map<String, bool> flags) async {
    if (!_available) return;
    for (final entry in flags.entries) {
      await FirebaseCrashlytics.instance
          .setCustomKey('flag_${entry.key}', entry.value);
    }
  }

  Future<void> recordError(Object error, StackTrace? stack,
      {bool fatal = false}) async {
    if (!_available) return;
    await FirebaseCrashlytics.instance
        .recordError(error, stack, fatal: fatal);
  }

  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    if (!_available) return;
    await FirebaseCrashlytics.instance.recordFlutterFatalError(details);
  }
}

/// Thin reference to AnalyticsService to avoid circular import.
class AnalyticsHelperRef {
  static Future<void> Function(String)? _setUserIdFn;

  static void register(Future<void> Function(String) fn) {
    _setUserIdFn = fn;
  }

  static Future<void> _setUserId(String id) async {
    await _setUserIdFn?.call(id);
  }
}
