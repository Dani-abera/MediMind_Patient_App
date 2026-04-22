import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import '../../theme/app_typography.dart';

/// Phone field with Ethiopian (+251) default and 9-digit validation.
/// Uses a simple TextFormField since intl_phone_field is not in the dep list.
class AppPhoneField extends StatelessWidget {
  const AppPhoneField({
    super.key,
    required this.controller,
    this.onChanged,
    this.validator,
    this.label = 'Phone Number',
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      onChanged: onChanged,
      validator: validator ?? _defaultValidator,
      style: AppTypography.body.copyWith(color: AppColors.neutral900),
      decoration: InputDecoration(
        labelText: label,
        hintText: '9XX XXX XXX',
        prefixIcon: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇪🇹', style: TextStyle(fontSize: 20.sp)),
              SizedBox(width: 6.w),
              Text('+251', style: AppTypography.body.copyWith(color: AppColors.neutral700)),
              SizedBox(width: 6.w),
              Container(width: 1, height: 20.h, color: AppColors.neutral300),
            ],
          ),
        ),
        constraints: BoxConstraints(minHeight: 56.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }

  String? _defaultValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 9) return 'Enter a valid 9-digit phone number';
    return null;
  }
}
