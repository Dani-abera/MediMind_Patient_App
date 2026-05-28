import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/cards/app_card.dart';
import '../../domain/entities/health_record.dart';

class VitalsSummaryCard extends StatelessWidget {
  const VitalsSummaryCard({super.key, this.healthRecord});

  final HealthRecord? healthRecord;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: AppCard(
        onTap: () => context.goNamed(RouteNames.health),
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Today's Vitals", style: AppTypography.subtitle),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14.r,
                  color: AppColors.neutral500,
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (healthRecord != null && healthRecord!.hasVitalsToday)
              _VitalsLogged(metrics: healthRecord!.metrics)
            else
              _VitalsEmpty(
                onTap: () => context.push('/health/log-vitals'),
              ),
          ],
        ),
      ),
    );
  }
}

class _VitalsLogged extends StatelessWidget {
  const _VitalsLogged({required this.metrics});
  final List<VitalMetric> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const _VitalsEmpty();
    return Row(
      children: metrics
          .take(3)
          .map((m) => Expanded(child: _MetricTile(metric: m)))
          .toList(),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.metric});
  final VitalMetric metric;

  Color get _dotColor {
    return switch (metric.status) {
      VitalStatus.normal => AppColors.success,
      VitalStatus.watch => AppColors.warning,
      VitalStatus.alert => AppColors.danger,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: _dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          metric.value,
          style: AppTypography.subtitle.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.neutral900,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          metric.unit,
          style: AppTypography.overline,
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 4.h),
        Text(
          metric.label,
          style: AppTypography.caption,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _VitalsEmpty extends StatelessWidget {
  const _VitalsEmpty({this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.monitor_heart_outlined,
          size: 32.r,
          color: AppColors.neutral300,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'No vitals logged today',
                style: AppTypography.body.copyWith(
                  color: AppColors.neutral500,
                ),
              ),
              GestureDetector(
                onTap: onTap,
                child: Text(
                  "Log today's vitals →",
                  style: AppTypography.body.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
