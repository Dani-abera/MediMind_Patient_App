import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

enum ButtonVariant { filled, outlined, text }

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.width,
    this.variant = ButtonVariant.filled,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final ButtonVariant variant;

  @override
  Widget build(BuildContext context) {
    final effectiveOnPressed = isLoading ? null : onPressed;

    return SizedBox(
      width: width ?? double.infinity,
      height: 48.h,
      child: switch (variant) {
        ButtonVariant.filled => ElevatedButton(
            onPressed: effectiveOnPressed,
            child: _buildChild(AppColors.white),
          ),
        ButtonVariant.outlined => OutlinedButton(
            onPressed: effectiveOnPressed,
            child: _buildChild(AppColors.primary),
          ),
        ButtonVariant.text => TextButton(
            onPressed: effectiveOnPressed,
            child: _buildChild(AppColors.primary),
          ),
      },
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 20.w,
        height: 20.h,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.r, color: color),
          SizedBox(width: 8.w),
          Text(label, style: AppTypography.subtitle.copyWith(color: color, fontWeight: FontWeight.w600)),
        ],
      );
    }
    return Text(
      label,
      style: AppTypography.subtitle.copyWith(color: color, fontWeight: FontWeight.w600),
    );
  }
}
