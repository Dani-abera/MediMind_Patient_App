import 'dart:io';
import 'package:in_app_update/in_app_update.dart';
import 'remote_config_service.dart';

class AppUpdateService {
  AppUpdateService._();
  static final AppUpdateService instance = AppUpdateService._();

  Future<void> checkAndPrompt(void Function()? onForceUpdate) async {
    final status = await RemoteConfigService.instance.checkForUpdate();

    switch (status) {
      case AppUpdateStatus.forceUpdate:
        if (Platform.isAndroid) await _triggerImmediateUpdate();
        onForceUpdate?.call();
      case AppUpdateStatus.flexibleUpdate:
        if (Platform.isAndroid) await _triggerFlexibleUpdate();
      case AppUpdateStatus.upToDate:
        break;
    }
  }

  Future<void> _triggerImmediateUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (_) {}
  }

  Future<void> _triggerFlexibleUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.startFlexibleUpdate();
        await InAppUpdate.completeFlexibleUpdate();
      }
    } catch (_) {}
  }
}
