import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';

class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _Action(
        icon: Icons.calendar_month_rounded,
        label: 'Book\nAppointment',
        color: AppColors.primary,
        onTap: () => context.pushNamed(RouteNames.book),
      ),
      _Action(
        icon: Icons.monitor_heart_outlined,
        label: 'Log\nVitals',
        color: AppColors.info,
        onTap: () => context.push('/health/log-vitals'),
      ),
      _Action(
        icon: Icons.medication_outlined,
        label: 'My\nPrescriptions',
        color: AppColors.warning,
        onTap: () => context.pushNamed(RouteNames.prescriptions),
      ),
      _Action(
        icon: Icons.psychology_rounded,
        label: 'AI\nPrediction',
        color: AppColors.accent,
        onTap: () => context.push('/health/predictions'),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 1.55,
        children: actions.map(_buildCard).toList(),
      ),
    );
  }

  Widget _buildCard(_Action action) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: action.onTap,
        child: Container(
          decoration: BoxDecoration(
            color: action.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(
              color: action.color.withValues(alpha: 0.15),
            ),
          ),
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: action.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Icon(action.icon, color: action.color, size: 20.r),
              ),
              Text(
                action.label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.neutral900,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Action {
  const _Action({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}
