import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';

class OtpTimerWidget extends StatelessWidget {
  const OtpTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.onResend,
    this.canResend = false,
  });

  final int remainingSeconds;
  final VoidCallback onResend;
  final bool canResend;

  String get _formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (canResend || remainingSeconds <= 0) {
      return TextButton(
        onPressed: onResend,
        child: Text(
          'Resend code',
          style: AppTypography.subtitle.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }
    return RichText(
      text: TextSpan(
        style: AppTypography.body,
        children: [
          const TextSpan(text: 'Resend code in '),
          TextSpan(
            text: _formattedTime,
            style: AppTypography.body.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
