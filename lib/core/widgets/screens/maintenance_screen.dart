import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../buttons/primary_button.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.build_circle_outlined,
                size: 96.r,
                color: AppColors.primary,
              ),
              SizedBox(height: 32.h),
              Text(
                'maintenance.title'.tr(),
                style: AppTypography.headline.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'maintenance.body'.tr(),
                style: AppTypography.body.copyWith(
                  color: AppColors.neutral500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),
              if (onRetry != null)
                PrimaryButton(
                  label: 'maintenance.tryAgain'.tr(),
                  onPressed: onRetry,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
