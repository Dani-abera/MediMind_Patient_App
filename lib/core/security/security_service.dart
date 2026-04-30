import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:root_checker_plus/root_checker_plus.dart';

class SecurityService {
  SecurityService._();
  static final SecurityService instance = SecurityService._();

  bool _rootDetected = false;
  bool get isDeviceRooted => _rootDetected;

  /// Returns true if the device appears rooted / jailbroken.
  /// Only checks in release mode; always returns false in debug.
  Future<bool> checkRootStatus() async {
    if (kDebugMode) return false;
    try {
      _rootDetected = await RootCheckerPlus.isRootChecker() ?? false;
    } catch (_) {
      _rootDetected = false;
    }
    return _rootDetected;
  }
}
