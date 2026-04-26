import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/appointment.dart';

class UpcomingAppointmentCard extends StatelessWidget {
  const UpcomingAppointmentCard({super.key, required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryLight],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => context.pushNamed(
              RouteNames.appointmentDetail,
              extra: appointment.id,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Upcoming Appointment',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.white.withValues(alpha: 0.8),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24.r,
                        backgroundColor:
                            AppColors.white.withValues(alpha: 0.2),
                        backgroundImage: appointment.doctorAvatarUrl != null
                            ? NetworkImage(appointment.doctorAvatarUrl!)
                            : null,
                        child: appointment.doctorAvatarUrl == null
                            ? Icon(Icons.person, color: AppColors.white,
                                size: 24.r)
                            : null,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Dr. ${appointment.doctorName}',
                              style: AppTypography.subtitle.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              appointment.doctorSpecialization,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  const Divider(color: Colors.white24),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.access_time_rounded,
                        label: DateFormat('MMM d • h:mm a')
                            .format(appointment.appointmentTime),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: _InfoChip(
                          icon: Icons.location_on_outlined,
                          label: appointment.centerName,
                          flexible: true,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: AppColors.white.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Text(
                        'View details',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.flexible = false,
  });
  final IconData icon;
  final String label;
  final bool flexible;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: flexible ? MainAxisSize.max : MainAxisSize.min,
      children: [
        Icon(icon, size: 14.r, color: AppColors.white.withValues(alpha: 0.9)),
        SizedBox(width: 4.w),
        Flexible(
          child: Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.white.withValues(alpha: 0.9),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
    return content;
  }
}
