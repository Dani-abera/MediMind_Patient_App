import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../domain/entities/health_prediction.dart';

class PredictionTeaser extends StatelessWidget {
  const PredictionTeaser({super.key, required this.prediction});

  final HealthPrediction prediction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: AppCard(
        onTap: () => context.push('/health/predictions/${prediction.id}'),
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Your latest risk assessment',
                    style: AppTypography.subtitle),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 14.r, color: AppColors.neutral500),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                _RiskGauge(
                  label: 'Diabetes',
                  risk: prediction.diabetesRisk,
                  level: prediction.diabetesLevel,
                ),
                _RiskGauge(
                  label: 'Hypertension',
                  risk: prediction.hypertensionRisk,
                  level: prediction.hypertensionLevel,
                ),
                _RiskGauge(
                  label: 'Cardiac',
                  risk: prediction.cardiovascularRisk,
                  level: prediction.cardiovascularLevel,
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'View full report →',
                style: AppTypography.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RiskGauge extends StatelessWidget {
  const _RiskGauge({
    required this.label,
    required this.risk,
    required this.level,
  });

  final String label;
  final double risk;
  final RiskLevel level;

  Color get _color {
    return switch (level) {
      RiskLevel.low => AppColors.success,
      RiskLevel.moderate => AppColors.warning,
      RiskLevel.high => AppColors.danger,
    };
  }

  String get _levelLabel {
    return switch (level) {
      RiskLevel.low => 'Low',
      RiskLevel.moderate => 'Moderate',
      RiskLevel.high => 'High',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          SizedBox(
            width: 52.w,
            height: 52.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 5,
                  color: AppColors.neutral300,
                ),
                CircularProgressIndicator(
                  value: risk,
                  strokeWidth: 5,
                  color: _color,
                  backgroundColor: Colors.transparent,
                ),
                Text(
                  '${(risk * 100).toInt()}%',
                  style: AppTypography.overline.copyWith(
                    color: AppColors.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: AppTypography.caption,
            textAlign: TextAlign.center,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              _levelLabel,
              style: AppTypography.overline.copyWith(
                color: _color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
