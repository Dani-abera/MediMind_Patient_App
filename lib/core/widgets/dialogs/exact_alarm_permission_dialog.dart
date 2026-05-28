import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../services/notification_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

/// Shows an in-app dialog requesting exact alarm permission if not already
/// granted. On Android 12+, tapping "Allow" opens the system Alarms & Reminders
/// settings page. No-op on iOS or if permission is already granted.
Future<void> showExactAlarmPermissionDialogIfNeeded(
    BuildContext context) async {
  final service = NotificationService.instance;
  final granted = await service.canScheduleExactNotifications();
  if (granted || !context.mounted) return;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const _ExactAlarmPermissionDialog(),
  );
}

class _ExactAlarmPermissionDialog extends StatelessWidget {
  const _ExactAlarmPermissionDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.alarm_outlined,
                size: 36.r,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Allow Precise Reminders',
              style: AppTypography.title,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'MediMind needs permission to schedule exact alarms '
              'so your medication reminders fire at the right time.\n\n'
              'Tap "Allow" to enable this in Settings under '
              'Alarms & reminders.',
              style: AppTypography.body.copyWith(color: AppColors.neutral700),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 28.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.neutral700,
                      side: BorderSide(color: AppColors.neutral300),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: const Text('Not Now'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      Navigator.of(context).pop();
                      await NotificationService.instance
                          .requestExactAlarmsPermission();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: const Text('Allow'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
