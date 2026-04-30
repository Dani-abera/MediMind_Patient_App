import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../di/service_locator.dart';
import '../../security/security_service.dart';
import '../../services/app_update_service.dart';
import '../../services/remote_config_service.dart';
import '../../storage/preferences_storage.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../screens/maintenance_screen.dart';
import '../tutorial/coach_mark_overlay.dart';
import 'app_bottom_nav.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  bool _showCoachMark = false;
  bool _showMaintenance = false;
  bool _rootedWarningShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _postInit());
  }

  Future<void> _postInit() async {
    final prefs = sl<PreferencesStorage>();

    if (!prefs.tutorialCompleted && mounted) {
      setState(() => _showCoachMark = true);
    }

    if (RemoteConfigService.instance.maintenanceMode && mounted) {
      setState(() => _showMaintenance = true);
      return;
    }

    await AppUpdateService.instance.checkAndPrompt(null);

    if (!_rootedWarningShown && mounted) {
      final isRooted = await SecurityService.instance.checkRootStatus();
      if (isRooted && mounted) {
        _rootedWarningShown = true;
        _showRootedDialog();
      }
    }
  }

  void _showRootedDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(
          'security.rootedTitle'.tr(),
          style: AppTypography.title,
        ),
        content: Text(
          'security.rootedBody'.tr(),
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'security.rootedAction'.tr(),
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showMaintenance) {
      return MaintenanceScreen(
        onRetry: () {
          if (!RemoteConfigService.instance.maintenanceMode) {
            setState(() => _showMaintenance = false);
          }
        },
      );
    }

    final shell = Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: AppBottomNav(
        currentIndex: widget.navigationShell.currentIndex,
        onTabSelected: (index) => widget.navigationShell.goBranch(
          index,
          initialLocation: index == widget.navigationShell.currentIndex,
        ),
      ),
    );

    return CoachMarkOverlay(
      show: _showCoachMark,
      child: shell,
    );
  }
}
