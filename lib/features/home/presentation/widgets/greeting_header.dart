import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../notifications/presentation/bloc/notification_bloc.dart';
import '../../../notifications/presentation/bloc/notification_state.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({super.key, required this.fullName, this.avatarUrl});

  final String fullName;
  final String? avatarUrl;

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String get _firstName => fullName.split(' ').first;

  String get _formattedDate {
    final now = DateTime.now();
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${days[now.weekday - 1]}, ${months[now.month - 1]} ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$_greeting, $_firstName',
                  style: AppTypography.headline,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(_formattedDate, style: AppTypography.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  const _NotificationBell({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.notifications_outlined,
            size: 26.r,
            color: AppColors.neutral700,
          ),
          if (count > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 16.w,
                height: 16.h,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  count > 99 ? '99+' : '$count',
                  style: AppTypography.overline.copyWith(
                    color: AppColors.white,
                    fontSize: 8,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class HomePageAppBar extends StatelessWidget {
  const HomePageAppBar({super.key, required this.fullName, this.avatarUrl});

  final String fullName;
  final String? avatarUrl;

  String get _firstName => fullName.split(' ').first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => context.pushNamed(RouteNames.profile),
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.primaryLight,
              backgroundImage: avatarUrl != null
                  ? NetworkImage(avatarUrl!)
                  : null,
              child: avatarUrl == null
                  ? Text(
                      _firstName.isNotEmpty ? _firstName[0].toUpperCase() : '?',
                      style: AppTypography.subtitle.copyWith(
                        color: AppColors.white,
                      ),
                    )
                  : null,
            ),
          ),
          BlocSelector<NotificationBloc, NotificationState, int>(
            selector: (s) => s.unreadCount,
            builder: (context, count) => _NotificationBell(
              count: count,
              onTap: () => context.pushNamed(RouteNames.notifications),
            ),
          ),
        ],
      ),
    );
  }
}
