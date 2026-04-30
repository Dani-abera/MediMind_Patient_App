import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../buttons/primary_button.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

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
                Icons.system_update_outlined,
                size: 96.r,
                color: AppColors.primary,
              ),
              SizedBox(height: 32.h),
              Text(
                'update.forceTitle'.tr(),
                style: AppTypography.headline.copyWith(
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'update.forceBody'.tr(),
                style: AppTypography.body.copyWith(
                  color: AppColors.neutral500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),
              PrimaryButton(
                label: 'update.forceButton'.tr(),
                onPressed: _openStore,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openStore() async {
    // On a real device this would open the Play Store / App Store
    final uri = Uri.parse('https://play.google.com/store/apps/details?id=et.medimind.medimind');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
