import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';

class RemoteConfigService {
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  final _rc = FirebaseRemoteConfig.instance;

  // ── Keys ─────────────────────────────────────────────────────────────────

  static const _minRequiredVersion = 'min_required_version';
  static const _latestVersion = 'latest_version';
  static const _maintenanceMode = 'maintenance_mode';
  static const _aiPredictionEnabled = 'ai_prediction_enabled';
  static const _videoConsultationEnabled = 'video_consultation_enabled';
  static const _paymentEnabled = 'payment_enabled';

  // ── Init ─────────────────────────────────────────────────────────────────

  Future<void> init() async {
    await _rc.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: const Duration(hours: 1),
    ));
    await _rc.setDefaults({
      _minRequiredVersion: '1.0.0',
      _latestVersion: '1.0.0',
      _maintenanceMode: false,
      _aiPredictionEnabled: true,
      _videoConsultationEnabled: true,
      _paymentEnabled: true,
    });
    try {
      await _rc.fetchAndActivate();
    } catch (_) {
      // Use cached / defaults on error
    }
  }

  // ── Accessors ─────────────────────────────────────────────────────────────

  String get minRequiredVersion => _rc.getString(_minRequiredVersion);
  String get latestVersion => _rc.getString(_latestVersion);
  bool get maintenanceMode => _rc.getBool(_maintenanceMode);
  bool get aiPredictionEnabled => _rc.getBool(_aiPredictionEnabled);
  bool get videoConsultationEnabled => _rc.getBool(_videoConsultationEnabled);
  bool get paymentEnabled => _rc.getBool(_paymentEnabled);

  Map<String, bool> get featureFlags => {
        'ai_prediction_enabled': aiPredictionEnabled,
        'video_consultation_enabled': videoConsultationEnabled,
        'payment_enabled': paymentEnabled,
      };

  // ── Update check ─────────────────────────────────────────────────────────

  Future<AppUpdateStatus> checkForUpdate() async {
    final info = await PackageInfo.fromPlatform();
    final currentVersion = info.version;

    if (_isVersionLessThan(currentVersion, minRequiredVersion)) {
      return AppUpdateStatus.forceUpdate;
    }
    if (_isVersionLessThan(currentVersion, latestVersion)) {
      return AppUpdateStatus.flexibleUpdate;
    }
    return AppUpdateStatus.upToDate;
  }

  static bool _isVersionLessThan(String a, String b) {
    final aParts = a.split('.').map(int.tryParse).toList();
    final bParts = b.split('.').map(int.tryParse).toList();
    for (var i = 0; i < 3; i++) {
      final av = i < aParts.length ? (aParts[i] ?? 0) : 0;
      final bv = i < bParts.length ? (bParts[i] ?? 0) : 0;
      if (av < bv) return true;
      if (av > bv) return false;
    }
    return false;
  }
}

enum AppUpdateStatus { upToDate, flexibleUpdate, forceUpdate }
