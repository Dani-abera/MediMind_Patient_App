import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_radius.dart';
import '../../../../../core/theme/app_typography.dart';

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      onChanged: onChanged,
      validator: validator ?? _defaultValidator,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: AppTypography.body.copyWith(color: AppColors.neutral900),
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: '9XX XXX XXX',
        prefixIcon: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('🇪🇹', style: TextStyle(fontSize: 20.sp)),
              SizedBox(width: 6.w),
              Text('+251',
                  style: AppTypography.body
                      .copyWith(color: AppColors.neutral700)),
              SizedBox(width: 6.w),
              Container(
                  width: 1, height: 20.h, color: AppColors.neutral300),
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
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 9) return 'Enter a valid 9-digit phone number';
    return null;
  }
}
