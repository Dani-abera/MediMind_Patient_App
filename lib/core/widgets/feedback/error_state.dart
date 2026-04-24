import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../buttons/primary_button.dart';

class ErrorState extends StatelessWidget {
  const ErrorState({
    super.key,
    this.icon,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
  });

  final IconData? icon;
  final String title;
  final String? message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline_rounded,
              size: 64.r,
              color: AppColors.danger,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: AppTypography.title.copyWith(color: AppColors.neutral700),
              textAlign: TextAlign.center,
            ),
            if (message != null) ...[
              SizedBox(height: 8.h),
              Text(
                message!,
                style: AppTypography.body.copyWith(color: AppColors.neutral500),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null) ...[
              SizedBox(height: 24.h),
              PrimaryButton(
                label: 'Try Again',
                onPressed: onRetry,
                width: 200.w,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
