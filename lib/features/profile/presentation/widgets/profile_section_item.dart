import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class ProfileSectionItem extends StatelessWidget {
  const ProfileSectionItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
    this.trailing,
    this.isDestructive = false,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isDestructive;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.danger : AppColors.neutral700;
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          leading: Icon(icon, color: color, size: 20.r),
          title: Text(
            label,
            style: AppTypography.body.copyWith(color: color),
          ),
          trailing: trailing ??
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.r,
                color: AppColors.neutral300,
              ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
          dense: true,
        ),
        if (showDivider)
          Divider(
            height: 1,
            indent: 52.w,
            color: AppColors.neutral300,
          ),
      ],
    );
  }
}
