import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

class AppDialog {
  AppDialog._();

  static Future<void> show(
    BuildContext context, {
    required String title,
    required String message,
    required List<Widget> actions,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
        ),
        title: Text(title, style: AppTypography.title),
        content: Text(message, style: AppTypography.body),
        contentPadding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 0),
        actionsPadding: EdgeInsets.all(16.r),
        actions: actions,
      ),
    );
  }
}
